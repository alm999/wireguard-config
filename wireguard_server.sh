# !/bin/sh
# cat > ${client_config} <<EOF && chmod 600 ${client_config}
# [Interface]
# Address = ${client_wg_ip}/${cidr}
# PrivateKey = $(head -1 ${client_private_key})
# DNS = $(echo ${client_dns_ips} | sed -E 's/ +/, /g')
# [Peer]
# PublicKey = $(head -1 ${server_public_key})
# PresharedKey = $(head -1 ${preshared_key})
# AllowedIPs = $(echo ${client_allowed_ips} | sed -E 's/ +/, /g')
# Endpoint = ${server_public_ip}:${server_port}
# PersistentKeepalive = 25
# EOF
#
#   cat >> ${server_config} <<EOF
# ### ${client_name} - START
# [Peer]
# # friendly_name = ${client_name}
# PublicKey = $(head -1 ${client_public_key})
# PresharedKey = $(head -1 ${preshared_key})
# AllowedIPs = ${client_wg_ip}/32
# ### ${client_name} - END
# EOF

help=false
visualize=false
syntax=false # While false it hasn't found any command

# check_visualize(){
#
# }
new(){
    echo "Not implemented"
}
enable(){
    echo "Not implemented"
}
disable(){
    echo "Not implemented"
}
enable-forwarding(){
    echo "Not implemented"
}
disable-forwarding(){
    echo "Not implemented"
}
remove(){
    echo "Not implemented"
}
peer-new(){
    echo "Not implemented"
}
peer-enable(){
    echo "Not implemented"
}
peer-disable(){
    echo "Not implemented"
}
peer-remove(){
    echo "Not implemented"
}


while [ $# -gt 0 ] && [ "$syntax" == "false" ] ; do
    case "$1" in
        # OPTIONS
        -h|--help) help=true ;;
        -v|--visualize) visualize=true ;;
        # COMMANDS
        new)
            syntax="new {<interface-name>} [-a <address>] [-p <port>] [-f <forwarding-interface>]"
            if [ "$help" != "true" ] ; then shift; new $*; fi # if help needed, don't execute
        ;;
        enable)
            syntax="enable {<interface-name>}"
            if [ "$help" != "true" ] ; then shift; enable $*; fi
        ;;
        disable)
            syntax="disable {<interface-name>}"
            if [ $help != "true" ]; then shift; disable $*; fi
        ;;
        enable-forwarding)
            syntax="enable-forwarding {<interface-name>} {<forwarding-interface>}"
            if [ $help != "true" ]; then shift; enable-forwarding $*; fi
        ;;
        disable-forwarding)
            syntax="disable-forwarding {<interface-name>}"
            if [ $help != "true" ]; then shift; disable-forwarding $*; fi
        ;;
        remove)
            syntax="remove {<interface-name>}"
            if [ $help != "true" ]; then shift; remove $*; fi
        ;;
        peer-new)
            syntax="peer-new {<interface-name>} {-f <public key file> | -k <public key>} {-i <peer-ip>} [-n <name or identifier>]"
            if [ $help != "true" ]; then shift; peer-new $*; fi
        ;;
        peer-enable)
            syntax="peer-enable {<interface-name>} {-i <peer-ip> | -n <name or identifier>}"
            if [ $help != "true" ]; then shift; peer-enable $*; fi
        ;;
        peer-disable)
            syntax="peer-disable {<interface-name>} {-i <peer-ip> | -n <name or identifier>}"
            if [ $help != "true" ]; then shift; peer-disable $*; fi
        ;;
        peer-remove)
            syntax="peer-remove {<interface-name>} {-i <peer-ip> | -n <name or identifier>}"
            if [ $help != "true" ]; then shift; peer-remove $*; fi
        ;;
        *)
            if [ ! -z $1 ] ; then # Avoid flagging stopping on empty arguments
                help=true
                syntax="Unknown command: '$1'"
            fi
        ;;
    esac
    shift
done

if [ "$help" == "true" ] && [ "$syntax" == "false" ] ; then # Full help
    echo "Check readme for full help"
elif [ "$help" == "true" ] && [ "$syntax" != "false" ] ; then # Command explanation or wrong args
    echo $syntax
elif [ "$help" == "false" ] && [ "$syntax" == "false" ] ; then # Running without command or help
    echo "Syntax: bash wireguard_server.sh [options] <command> <arguments> [optional arguments]";

fi
