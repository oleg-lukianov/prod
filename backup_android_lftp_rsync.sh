#!/bin/bash

######  Example start script   ############################
#  for Termux
#
#  bash /storage/emulated/0/github/prod/backup_android_lftp_rsync.sh -lftp | tee -a /storage/emulated/0/scripts/backup/backup_android_lftp_rsync.log
#
#  bash /storage/emulated/0/github/prod/backup_android_lftp_rsync.sh -rsync | tee -a /storage/emulated/0/scripts/backup/backup_android_lftp_rsync.log
#
###########################################################

version="1.01 - 01.03.2019";
version="1.02 - 27.12.2019";
version="1.03 - 14.11.2020";
version="1.04 - 19.12.2020";
version="1.05 - 23.02.2021";
version="1.06 - 27.05.2022";
version="1.07 - 16.06.2023";
version="1.08 - 05.01.2024";

echo "-----  Start $(date '+%F %T') (version $version)  -----";
echo "";

mode=$1;

function selftest() {
    echo "Selftest.....";
    selftest_count=0;
    pragmas="
lftp --version
rsync --version
curl --version
base64 --version
sshpass -V
";

    IFS=$'\n';
    for pragma in $pragmas; do
        echo -n "Test '$pragma'........ ";
        test1=$(bash -c "$pragma | wc -l" 2>/dev/null);
        
        if [[ $test1 = 0 ]]; then
            selftest_count=1;
            echo "Error";
        else
            echo "Ok";
        fi
        
    done;
    unset IFS;
    
    echo "Selftest.....END (selftest_count=$selftest_count)";
    echo "";
    if [[ $selftest_count = 1 ]]; then
        exit 0;
    fi
}

selftest;

function check_dublicate() {
    script_name=$(basename "$0");
    dublicate=$(pgrep -fc "$script_name");

    if [ "$dublicate" -le 3 ]; then
        echo "-----  Start $(date '+%F %T') (version $version)  -----";
    else
        dublicate=$(pgrep -fc "$script_name");
        echo -e "~~~Script $script_name already working......~~~";
        echo -e "$dublicate";
        exit 0;
    fi;
}

check_dublicate;

function parseConfig() {
    var=$1
    file_conf=${0/sh/conf};
    value=$(awk -F "=" "/^$var/ {print \$2}" "$file_conf")

    if [[ "$var" == "" ]]; then
      echo "In config variable '$var' is NULL";
      exit 1;
    elif [[ "$value" == "" ]]; then
      echo "In config value for '$var' is NULL";
      exit 1;
    fi;

    value=${value// /};

    if [[ "$value" =~ $'\n' ]]; then
      value=${value//$'\n'/ };
    fi;

    echo "$value";
}

server=$(parseConfig "server");
echo "Configuration set variable 'server'='$server'";

port=$(parseConfig "port");
echo "Configuration set variable 'port'='$port'";

login=$(parseConfig "login");
echo "Configuration set variable 'login'='$login'";

file_conf=${0/sh/conf};
# shellcheck source=/dev/null
. "${file_conf}";
pass=$(base64 -d <<< "$pass");
echo "Configuration set variable 'pass'='pass'";

dir_dest=$(parseConfig "dir_dest");
dir_dest=${dir_dest%\"};
dir_dest=${dir_dest#\"};
dir_dest=${dir_dest%/};
echo "Configuration set variable 'dir_dest'='$dir_dest'";

dir_backup=$(parseConfig "dir_backup");
echo "Configuration set variable 'dir_backup'='$dir_backup'";



if [[ "$mode" =~ "-lftp" ]]; then
    echo "Check connect to service $server:$port.....";
    conn=$(curl -vI sftp://"$login":"$pass"@"$server":"$port" 2>&1 | grep -c "Connected to");
    dest="${dir_dest}/";
elif [[ "$mode" =~ "-rsync" ]]; then
    echo "Check connect to RSYNC $server:$port.....";
    conn=$(echo "quit" | telnet "$server" "$port" 2>&1 | grep -c "Connected to");
    dest="${dir_dest}/";
else
    echo "Not parameters (-lftp, -rsync)";
fi

echo "Connecting status is '$conn' (1 - connected, 0 - not connected)";


home_ip=$(ifconfig -a 2>/dev/null | grep -c '192.168.');

if [[ $home_ip == 1 ]]; then
    if [[ $conn == 1 ]]; then
        for x in $dir_backup; do
            if [[ ! $x =~ [#] ]]; then
                path_parse=(${x//:/ })
                src_final=${path_parse[1]}
                dest_final=${dest}${path_parse[0]}
                echo "";
                echo "Sending........";
                echo "dir_backup = $x"
                echo "src_final = $src_final";
                echo "dest_final = $dest_final";
                echo "Enable mode: $mode";
                
                if [[ "$mode" =~ "-lftp" ]]; then
                    lftp -e "set ftp:ssl-allow no; mirror --continue --delete -R -x 'thumb' -x '.tmfs' -x '.gs' -x 'Android' -x '.estrongs' $src_final $dest_final/; exit;" -p "$port" -u "$login","$pass" sftp://"$server";

                elif [[ "$mode" =~ "-rsync" ]]; then
                    sshpass -p "$pass" rsync --progress --exclude '*thumb*' --exclude '.tmfs*' --exclude 'Radio' --delete-excluded --delete -av -e "ssh -o StrictHostKeyChecking=no -p $port -l $login" "$src_final" "$server:$dest_final";

                else
                    echo "Not parameters (-lftp, -rsync)";
                fi

                echo "";
            fi;
        done;
    else
        echo "Not connected";
        
        if [[ "$mode" =~ "-lftp" ]]; then
            curl -vI sftp://"$login":"$pass"@"$server":"$port";
        elif [[ "$mode" =~ "-rsync" ]]; then
            echo "quit" | telnet "$server" "$port";
        else
            echo "Not parameters (-lftp, -rsync)";
        fi
    fi
else
    echo "Device not at home";
fi
echo "";
echo "-----  End $(date '+%F %T') (version $version)  -----";

exit 0;
