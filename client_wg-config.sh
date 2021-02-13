# !/bin/sh

# DEFAULTS
dns="1.1.1.1, 8.8.8.8"
allowed_ips="0.0.0.0/0"
keepalive="-1"

##

help=false
syntax=false
client_public_key=""
client_ip=""

new(){
    # Mandatory args
    if [ ! $# -ge 4 ] || [[ "$1" == "-"* ]] || [[ "$2" == "-"* ]] || [[ "$3" != "-"* ]] || [[ "$4" == "-"* ]]; then
        help=true
        return
    fi
    client_ip="$1"
    endpoint="$2"
    shift;shift;

    server_public_key=""
    zip_location=""
    qr_location=""
    conf_location=""
    save_pubkey="false"

    while [ $# -gt 0 ] ; do
        case "$1" in
            -f) shift;
                if [ -f $1 ]; then
                    server_public_key=$(<$1)
                else
                    echo "Public key file does not exist"; return
                fi
            ;;
            -k) shift; server_public_key=$1;;
            -z) shift; zip_location=$1;;
            -q) shift; qr_location=$1;;
            -c) shift; conf_location=$1;;
            -s) shift; save_pubkey=$1;;
            -d) shift; dns=$1;;
            -a) shift; allowed_ips=$1;;
            -p) shift; keepalive=$1;;
        esac
        shift
    done

    if [ "$server_public_key" == "" ]; then
        help=true
        return
    fi

    # Commands
    private_key=`wg genkey`
    client_public_key=`echo "$private_key" | wg pubkey`
    echo "Client public Key: $client_public_key"

    if [ "${keepalive}" == "-1" ]; then
        keepalive=""
    else
        keepalive="PersistentKeepalive = ${keepalive}\n"
    fi

    file="[Interface]\nAddress = ${client_ip}\nPrivateKey = ${private_key}\nDNS = ${dns}\n\n[Peer]\nPublicKey = ${server_public_key}\nAllowedIPs = ${allowed_ips}\nEndpoint = ${endpoint}\n${keepalive}";

    unset -v private_key

    # Export conf file
    if [ "$zip_location" != "" ]; then
        if [ -f "${zip_location}.conf" ] || [ -f "${zip_location}.zip" ];then
            echo "Filename exists. Could not create ZIP."
            zip_location=""
        else
            echo "Exporting config to ZIP as ${zip_location}"
            printf "$file" >> "${zip_location}.conf"
            zip "${zip_location}.zip" "${zip_location}.conf"
            rm "${zip_location}.conf"
        fi
    fi
    if [ "$qr_location" != "" ]; then
        if [ -f "${qr_location}.png" ];then
            echo "Filename exists. Could not export QR."
            qr_location=""
        else
            echo "Exporting config to QR as ${qr_location}"
            qrencode -o ${qr_location}.png -t png "$file"
        fi
    fi
    if [ "$conf_location" != "" ]; then
        if [ -f "${conf_location}.conf" ];then
            echo "Filename exists. Could not create config file."
            conf_location=""
        else
            echo "Exporting config to file as ${conf_location}"
            printf "$file" >> "${conf_location}.conf"
        fi
    fi
    # Could not export, or not set to export
    if [ "$zip_location" == "" ] && [ "$qr_location" == "" ] && [ "$conf_location" == "" ]; then
        qrencode -t ansiutf8 "$file";
        echo "### File Contents ###"
        printf "$file";
        echo "#####################"
    fi

}
new-push(){
    # Mandatory args
    if [ ! $# -ge 5 ] || [[ "$1" == "-"* ]] || [[ "$2" == "-"* ]] || [[ "$3" == "-"* ]] || [[ "$4" != "-"* ]] || [[ "$5" == "-"* ]]; then
        help=true
        return
    fi
    interface_name=$1
    shift;

    new $* # Send all arguments to the new command to create the client configuration file

    # Obtain the name
    name="Auto-added"
    while [ $# -gt 0 ] ; do
        case "$1" in
            -n) shift; name="#${1}\n";;
        esac
        shift
    done

    echo ""
    echo "Adding peer to server configuration file at /etc/wireguard/${interface_name}"
    if [ -f "wg-config.sh" ]; then
        bash wg-config.sh peer-new ${interface_name} -k ${client_public_key} -i ${client_ip}/32 -n ${name}
    else
        peer="[Peer]\n${name}PublicKey = ${client_public_key}\nAllowedIPs = ${client_ip}/32\n\n"
        printf "$peer" >> "/etc/wireguard/${interface_name}.conf"
    fi

}


while [ $# -gt 0 ] && [ "$syntax" == "false" ] ; do
    case "$1" in
        # OPTIONS
        -h|--help) help=true ;;
        # COMMANDS
        new)
            syntax="new {<client-ip-address>} {<server endpoint:port>} {-f <server-pubkey-file> | -k <server-pubkey>} [-z <zip-conf> | -q <qr-conf> | -c <conf-file>] [-d <dns>] [-a <allowed-ips>] [-s <save-pubkey>] [-p <keepalive-seconds>]"
            if [ $help != "true" ]; then shift; new $*; fi
        ;;
        new-push)
            syntax="new-push {<interface-name>} {<client-ip-address>} {<server endpoint:port>} {-f <server-pubkey-file> | -k <server-pubkey>} [-z <conf-zip> | -q <qr-conf> | -c <file-conf>] [-d <dns>] [-a <allowed-ips>] [-s <save-pubkey>] [-p <keepalive-seconds>] "
            if [ $help != "true" ]; then shift; new-push $*; fi
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
    echo "Syntax: bash client_wg-config.sh [options] <command> <arguments> [optional arguments] ";
    echo "Available commands: new, new-push"
elif [ "$help" == "true" ] && [ "$syntax" != "false" ] ; then # Command explanation or wrong args
    echo $syntax
elif [ "$help" == "false" ] && [ "$syntax" == "false" ] ; then # Running without command or help
    echo "Syntax: bash client_wg-config.sh [options] <command> <arguments> [optional arguments] ";

fi
