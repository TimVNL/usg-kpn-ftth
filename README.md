# My Ubiquiti USG  configuration with KPN FTTH, IPTV, VLANS, IPv4 or IPv6 more..
This repo contains the files you need to succesfully configure the USG with KPN FTTH with IPTV and IPv6 enabled.

Thanks to [@coolhva](https://github.com/coolhva/usg-kpn-ftth) for all his work I use his configs as base this repo and it is pure for my own documentation if my controller needs a reinstall.
Use at your own risk ;)


1. Place **config.gateway.json** at the unifi controller (*sites/default*) via SCP

   The config.gateway.json contains the main configuration with the different interfaces which are needed for internet (vlan 6) and IPTV (vlan 4). IPv4 is configured via PPPoE with the kpn/kpn username and password. KPN uses a TAG which is configured in the DSLAM to identify your connection and to give you your "permanent" public IPv4 address.

   **NOTE:** If you want to use IPv4 only please rename the **ipv4_config.gateway.json** to **config.gateway.json**

2. Place **kpn.sh** in */config/scripts/post-config.d/* via SCP
3. Execute `chmod +x /config/scripts/post-config.d/kpn.sh` on the USG

   After each firmware upgrade the routes file, used by the dhcp client at the exit hook (for the IPTV routes), is removed. To overcome this, after each upgrade the USG will execute this script which will create the routes file, renews the DHCP lease, restart the IGMP Proxy.

   KPN sends static routes via DHCP which the USG does not install by default. This script will install the DHCP routes when a DHCP lease is received. The chmod +x command allows the script to be executed. ([source](https://community.ubnt.com/t5/EdgeRouter/DHCP-CLIENT-OPTION-121-not-updates-routes-table/m-p/2506090/highlight/true#M223160))
4. Place **igmpchecker.sh** in */config/* via SCP
5. Execute `chmod +x /config/igmpchecker.sh` on the USG

  The igmpchecker.sh will restart the IGMP proxy when it has stopped this is needed for the IPTV to work.

6. The LAN network (and portfowarding if needed) needs to be configured in the Unifi controller
7. Go to the USG in devices in the controller and force provisioning

After provisioning please reboot the USG. After two minutes IPv6 will be enabled. This can be checked by executing `show interfaces` on the USG. If IPTV does not work, please restart the USG again.

The PPPOE interface has no "public" IPv6 address because it uses the link local IPv6 address to route traffic to KPN. To see the remote address execute the following command ([source](https://community.ubnt.com/t5/EdgeRouter/EdgeRouter-X-PPPoE-IPv6/td-p/1893221)):
```
show interfaces pppoe pppoe2 log | match "IPV6|LL"
```

## VLANs

My configuration uses two VLANs one for all my iOT devices such as my Dyson fans, Google cast devices etc...
 - 400: IPTV VLAN
 - 500: iOT VLAN

At the "igmp-proxy" section you will see the following in my configuration replace "eth1.400" with "eth.{vlan}" where {vlan} would be the VLAN where your decoders are in.

```
"eth1.400": {
    "alt-subnet": [
        "0.0.0.0/0"
    ],
    "role": "downstream",
    "threshold": "1"
}
```

To prevent the IPTV from flooding other network interfaces it's best to explicitly disable the proxy for these interfaces as you will see in my configuration:

```
"eth1": {
    "role": "disabled",
    "threshold": "1"
},
"eth1.500": {
    "role": "disabled",
    "threshold": "1"
},
```

This config.gateway.json has been tested on the following versions:

```
UniFi Security Gateway 3P: 4.4.55.5377096
Unifi Controller: 6.2.26 on a Cloud Key Gen2
```
## My WAN, Network and firewall settings

#### WAN settings

My Unifi WAN settings in the controller are as follows:

![unifiwan](https://raw.githubusercontent.com/TimVNL/usg-kpn-ftth/master/unifi_wan.png)

#### Network settings

A separate README about this will follow soon

#### Network settings

A separate README about this will follow soon

## Resources

At GoT @coolhva explains a little bit more about the MTU and troubleshooting:  
Troubleshooting: https://gathering.tweakers.net/forum/list_message/60188896#60188896  
MTU and IPv6 workaround: https://gathering.tweakers.net/forum/list_message/57023231#57023231  
[@coolhva](https://github.com/coolhva/)'s original guide: https://github.com/coolhva/usg-kpn-ftth
