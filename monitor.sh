#!/bin/bash

watch -n 1 '
if [ -f /var/log/openvpn/openvpn-status.log ]; then
    echo "Time: $(date)"
    echo "Connected clients:"
    echo "=================="

    sudo sed -n "/^CLIENT_LIST/,/^ROUTING_TABLE/p" /var/log/openvpn/openvpn-status.log | \
    grep "^CLIENT_LIST" | \
    while IFS=, read -r tag name real_ip virt_ip virt_ipv6 bytes_recv bytes_sent conn_since conn_since_time_t username client_id peer_id cipher; do
        echo "Client: $name"
        echo "  Real IP:     $real_ip"
        echo "  Virtual IP:  $virt_ip"
        echo "  Received:    $bytes_recv bytes"
        echo "  Sent:        $bytes_sent bytes"
        echo "  Connected:   $conn_since"
        echo "  Cipher:      $cipher"
        echo "---------------------------"
    done
else
    echo "Log file not found."
fi

echo ""
'
