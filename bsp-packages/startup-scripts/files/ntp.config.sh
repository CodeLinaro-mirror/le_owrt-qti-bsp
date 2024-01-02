uci -q batch << EOI
    delete system.ntp
    set system.ntp='timeserver'
    set system.ntp.enabled='1'
    set system.ntp.enable_server='0'
    add_list system.ntp.server='0.openwrt.pool.ntp.org'
    add_list system.ntp.server='1.openwrt.pool.ntp.org'
    add_list system.ntp.server='2.openwrt.pool.ntp.org'
    add_list system.ntp.server='3.openwrt.pool.ntp.org'
EOI
uci commit system.ntp
