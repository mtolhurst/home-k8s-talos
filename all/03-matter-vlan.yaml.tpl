apiVersion: v1alpha1
kind: LinkConfig
name: {{ .Node.Data.interface }}
mtu: 1500
up: true
addresses:
  - address: {{ .Node.IP.String }}/24
routes:
  - gateway: 192.168.2.1

---
apiVersion: v1alpha1
kind: VLANConfig
name: {{ printf "%s.%d" .Node.Data.interface 2 }}
vlanID: 2
vlanMode: 802.1q
parent: {{ .Node.Data.interface }}
up: true
addresses:
  - address: {{ replace "192.168.2." "192.168.4." .Node.IP.String }}/24

---
machine:
  sysctls:
    net/ipv4/conf/all/rp_filter: "2"
    net/ipv4/conf/default/rp_filter: "2"
    net/ipv4/conf/{{ .Node.Data.interface }}.2/rp_filter: "2" 
    net/ipv6/conf/all/disable_ipv6: "0"
    net/ipv6/conf/default/disable_ipv6: "0"
    net/ipv6/conf/{{ .Node.Data.interface }}.2/disable_ipv6: "0"

---
apiVersion: v1alpha1
kind: KubeNodeConfig
labels:
  network.home/matter-vlan: "true"

