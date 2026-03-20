version: 2
ethernets:
  ens3:
    dhcp4: no
    addresses:
      - ${ip}/24
    routes:
      - to: default
        via: 192.168.100.1
    nameservers:
      addresses: [8.8.8.8,1.1.1.1]