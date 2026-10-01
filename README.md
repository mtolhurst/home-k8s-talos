# Topf talos IaC for home-k8s
This repo contains talos configuration, managed via topf, for the home k8s cluster.

It is responsible for bootstrapping & upgrading the talos linux config for each machine, as well as the core k8s version.

## Repo structure
* [./topf.yaml] - the main config file, containing cluster wide options, as well as config for each node
* [./schematic.yaml] - the default talos image factory options
* [./all/] - patch files applied to all nodes
* [./control-plane] - patch files only applied to control plane nodes
* [./secrets.yaml] - sops-encrypted secrets required to auth to talos nodes.

## Secret management
Secrets in this repo are managed through sops, encrypted with age.

The only secret in this repo is the talos cert, which is required to act on the existing cluster.
If bootstrapping, this can be safely ignored. Instead, just delete secrets.yaml, and generate a new one.

Pre-reqs - age & sops installed.

Topf will automatically decrypt the values in secrets.yaml. All that is required is setting
the `SOPS_AGE_KEY` env var to the age secret key. This is currently stored in my vaultwarden vault.

## Bootstrapping.
As mentioned above, if bootstrapping a new cluster, secret management can be safely ignored.

To bootstrap, run `topf apply --auto-bootstrap` (TODO confirm this, I haven't tested it yet).

This should prompt to generate new secrets if none are present, and bootstrap the cluster.

Once this is done, the cluster will not be healthy, as it will be missing a CNI (we disable this intentionally).

Next, run `topf kubeconfig` to get a kubeconfig with access to the cluster, and run [./bootstrap-cillium.sh] to install cillium.

After this, the cluster should be healthy, and ready for applications.

## Setting up talosconfig
`topf talosconfig > ~/.talos/config`

This will allow for regular talosctl commands to be run.

## Regular updates
After making any required changes to the config files, just run `topf apply` to apply the changes.
This will first show a diff of all changes, requiring confirmation.

## Talos version upgrades
First, modify the talos version in [./topf.yaml].
Then, run `topf upgrade` to update the image and reboot.

With the current cluster setup, we seem to be hitting timeouts draining pods.
Downtime isn't really that important here, so just run `topf upgrade drain=false` to skip this.

(We can look into extending timeouts, or skipping after timeout later if we actually care about this)

## K8s version upgrades
These should not be managed directly through topf. 

First, use talos to perform the upgrade `talosctl upgrade-k8s --to <version>`

Then, update the values in [./topf.yaml] and run apply.

## Adding a new node
TODO. I suspect `topf apply --auto-bootstrap` is all that's required.
