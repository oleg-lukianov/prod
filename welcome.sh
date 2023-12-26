#!/bin/bash
version="1.0.1";
version="1.0.2 23.01.2020";
version="1.0.3 22.09.2020";
version="1.0.4 26.12.2023";

function getHostname() {
    hostname=$(hostname)
    echo "$hostname"
}

function getInterface() {
    inet=$(/usr/sbin/ifconfig -a | grep -oE "^[a-z0-9]+" | uniq);
    mass=();

    for interface in $inet; do
        ip=$(/usr/sbin/ifconfig "$interface" | grep inet | grep -i mask | sed 's/[a-zA-Z:]//g' | awk '{print $1}' | grep -v 127.0.0.1);
        if [ "$ip" ]; then
            mass+=("$interface ($ip)");
        fi
    done;

    echo "${mass[@]}"
}

function getKernel() {
    kernel=$(uname -a | awk '{print $15" "$3" "$5" "$14}')
    echo "$kernel"
}

function getOS() {
    os=$(cat /etc/system-release)
    echo "$os"
}

function getUptime() {
    uptime=$(uptime | sed 's/^\s//g')
    echo "$uptime"
}

function getCPUcount() {
    CPUcount=$(grep -c processor /proc/cpuinfo)
    echo "$CPUcount"
}

function getCPUmodel() {
    model=$(grep "model name" /proc/cpuinfo | head -1 | awk '{print $4" "$5" "$6" "$7" "$8" "$9" "$10}')
    echo "$model"
}

function getMemory() {
    memory=$(cat /proc/meminfo | grep MemTotal | awk '{printf"%d", $2/1024}')
    echo "$memory Mb"
}

function getSwap() {
    swap=$(cat /proc/meminfo | grep SwapTotal | awk '{printf"%d", $2/1024}')
    echo "$swap Mb"
}

echo -e "\e[0;91m
++++++++++++++++++: System Data (version $version) :++++++++++++++++++\e[0m
\e[0;94m    Hostname\e[0m = \e[0;93m$(getHostname) \e[0m
\e[0;94m     Address\e[0m = \e[0;93m$(getInterface) \e[0m
\e[0;94m      Kernel\e[0m = \e[0;93m$(getKernel) \e[0m
\e[0;94m          OS\e[0m = \e[0;93m$(getOS) \e[0m
\e[0;94m      Uptime\e[0m = \e[0;93m$(getUptime) \e[0m
\e[0;94m         CPU\e[0m = \e[0;93m$(getCPUcount) x $(getCPUmodel) \e[0m
\e[0;94m      Memory\e[0m = \e[0;93m$(getMemory) \e[0m
\e[0;94m        Swap\e[0m = \e[0;93m$(getSwap) \e[0m
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"

exit 0;
