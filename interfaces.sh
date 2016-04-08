#!/bin/bash -e
interfaces="# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback"

if [ -n "$(/usr/bin/dpkg --list | grep xen-system-amd64)" ];
then
  interfaces="${interfaces}

# The primary network interface
  auto xen-br0
  iface xen-br0 inet static
  address ${ip}
  netmask 255.255.255.0
  network 192.168.0.0
  broadcast 192.168.0.255
  gateway 192.168.0.1
  bridge_ports eth0
  bridge_stp off
  bridge_fd 0
  up ip link set addr $(cat /sys/class/net/eth0/address) dev $IFACE"

elif [[ ${primary} == *wifi* ]];
then
  bash "${configs_dir}/scripts/wifi.sh"
  interfaces="${interfaces}

# The primary network interface
allow-hotplug eth0
iface eth0 inet static

allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface wlan0 inet dhcp"
  /usr/bin/chattr -i "/etc/resolv.conf"
  ccp "resolv.wifi" "/etc/resolv.conf"
  /usr/bin/chattr +i "/etc/resolv.conf"
else
  interfaces="${interfaces}

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
  address ${ip}
  netmask 255.255.255.0
  network 192.168.0.0
  broadcast 192.168.0.255
  gateway 192.168.0.1"
  /usr/bin/chattr -i "/etc/resolv.conf"
  ccp "resolv.eth" "/etc/resolv.conf"
  /usr/bin/chattr +i "/etc/resolv.conf"
fi

interfaces="${interfaces}

  dns-nameservers 192.168.0.1 192.168.0.2
  dns-search thekyel.com" 

echo "${interfaces}" > /etc/network/interfaces

ccp "dhclient.conf" "/etc/dhcp/dhclient.conf"

# Not sure why this gets changed, need to investigate
cch "/bin/ping" "4755"
