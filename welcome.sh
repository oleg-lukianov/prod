#!/bin/bash

version="1.0.1 20.01.2018";
version="1.0.2 23.01.2020";
version="1.0.3 22.09.2020";
# Changelog:
# - getInterface modified
version="1.0.4 26.12.2023";
# Changelog:
# - SWAP added
# - Android and linux versions merged
version="1.0.5 06.02.2024";
# Changelog:
# - Fix errors on Ubuntu distr

# DEBUG_MODE: 0-disable, 1-enable
DEBUG_MODE=0

function getHostname() {
    hostname=$(hostname)
    echo "$hostname"
}

function getInterface() {
    step_inter=1;
    step_ip=0;
    mass=();
    mass_inter=();
    mass_ip=();

    IFS=$'\n';
    for x in $(ifconfig -a 2>/dev/null); do
        interface=$(echo "$x" | grep -oE "^[a-z0-9_]+");
        ip_addrr=$(echo "$x" | grep inet | awk '{print $2}');
        mass_inter[$step_inter]=$interface;
        mass_ip[$step_ip]="$ip_addrr";
        (( step_inter+=1 ))
        (( step_ip+=1 ))
        if [[ $DEBUG_MODE == 1 ]]; then
            echo "$interface ($ip_addrr)";
        fi;
    done;
    unset IFS

    for y in $(seq 0 $step_inter); do
        if [[ "${mass_ip[$y]}" != "127.0.0.1" ]]; then
            if [[ ${mass_ip[$y]} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if [[ $DEBUG_MODE == 1 ]]; then
                echo "${mass_inter[$y]} ${mass_ip[$y]}"
            fi;
            mass+=("${mass_inter[$y]} (${mass_ip[$y]})");
            fi;
        fi;
    done;

    echo "${mass[@]}"
}

function getKernel() {
    kernel_s=$(uname -s)
    kernel_n=$(uname -n)
    kernel_r=$(uname -r)
    kernel_m=$(uname -m)
    kernel_o=$(uname -o)
    echo "$kernel_s $kernel_n $kernel_r $kernel_m $kernel_o"
}

function getOS() {
    if [[ -f "/etc/system-release" ]]; then
        os=$(cat /etc/system-release)
    elif [[ -f "/etc/lsb-release" ]]; then
        os=$(grep DISTRIB_DESCRIPTION /etc/lsb-release | sed 's/DISTRIB_DESCRIPTION=//g' | sed 's/"//g')
    else
        os_devicename=$(getprop ro.config.devicename 2>/dev/null | getprop ro.product.model 2>/dev/null)
        os_name=$(getprop net.bt.name 2>/dev/null)
        os_release=$(getprop ro.build.version.release 2>/dev/null)
        os="$os_devicename - $os_name $os_release"
    fi;

    echo "$os"
}

function getUptime() {
    uptime=$(uptime | sed 's/^\s//g' | sed 's/  / /g')
    echo "$uptime"
}

function getCPUcount() {
    CPUcount=$(grep -c processor /proc/cpuinfo)
    echo "$CPUcount"
}

function getCPUmodel() {
    model=$(lscpu | grep 'Model name' | sed 's/Model name:\s//g' | uniq | xargs)
    echo "$model"
}

function getMemory() {
    memory=$(grep MemTotal /proc/meminfo | awk '{printf"%d", $2/1024}')
    echo "$memory Mb"
}

function getSwap() {
    swap=$(grep SwapTotal /proc/meminfo | awk '{printf"%d", $2/1024}')
    echo "$swap Mb"
}

echo -e "\e[0;91m
++++++++++++++++++++: System Data (version $version) :++++++++++++++++++++\e[0m
\e[0;94m    Hostname\e[0m = \e[0;93m$(getHostname) \e[0m
\e[0;94m     Address\e[0m = \e[0;93m$(getInterface) \e[0m
\e[0;94m      Kernel\e[0m = \e[0;93m$(getKernel) \e[0m
\e[0;94m          OS\e[0m = \e[0;93m$(getOS) \e[0m
\e[0;94m      Uptime\e[0m = \e[0;93m$(getUptime) \e[0m
\e[0;94m         CPU\e[0m = \e[0;93m$(getCPUcount) x $(getCPUmodel) \e[0m
\e[0;94m      Memory\e[0m = \e[0;93m$(getMemory) \e[0m
\e[0;94m        Swap\e[0m = \e[0;93m$(getSwap) \e[0m
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"
