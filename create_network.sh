# ADD NAMESPACE
ip netns add yellow
ip netns add green

# CRIA VSWITCH
brctl addbr v-net-0
ip link set dev v-net-0 up

# CRIA IFACE 
ip link add veth-green type veth peer name veth-green-br
ip link add veth-yellow type veth peer name veth-yellow-br

# CONECTA IFACE - ROUTER
ip link set veth-yellow-br master v-net-0
ip link set veth-yellow-br up
ip link set veth-green-br master v-net-0
ip link set veth-green-br up

# CONECTA IFACE - NAMESPACE
ip link set veth-green netns green
ip link set veth-yellow netns yellow

# DEFINE IP 
ip -n green addr add 192.168.15.10/24 dev veth-green
ip -n green link set veth-green up
ip -n yellow addr add 192.168.15.11/24 dev veth-yellow
ip -n yellow link set veth-yellow up

# DEFINE IP LOCAL
ip addr add 192.168.15.5/24 dev v-net-0


# ROTA DEFAULT
ip netns exec yellow ip route add default via 192.168.15.5 dev veth-yellow
ip netns exec green ip route add default via 192.168.15.5 dev veth-green


# CHECA ROTEAMENTO
cat /proc/sys/net/ipv4/ip_forward

# NAT SAIDA NAMESPACE
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE


# DEL CONFIG
ip netns del yellow
ip netns del green
ip link del v-net-0
iptables -t nat -D POSTROUTING 1
