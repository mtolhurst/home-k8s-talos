helm repo add cilium https://helm.cilium.io/
helm repo update

helm template \
    cilium \
    cilium/cilium \
    --version 1.20.0 \
    --namespace kube-system \
    --set routingMode=native \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set bgpControlPlane.enabled=true \
    --set k8sServiceHost=localhost \
    --set bpf.hostRouting=true \
    --set bpf.masquerade=true \
    --set enableIPv4Masquerade=true \
    --set autoDirectNodeRoutes=true \
    --set ipv4NativeRoutingCIDR=10.244.0.0/16 \
    --set k8sServicePort=7445 > cilium.yaml

kubectl apply -f cilium.yaml

