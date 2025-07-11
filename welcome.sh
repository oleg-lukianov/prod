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
version="1.0.6 27.02.2024";
# Changelog:
# - Free Memory and SWAP added
version="1.0.7 18.03.2024";
# Changelog:
# - Fix errors on RHEL6 with netstat and memory
# - Feature: timing added in debug mode
version="1.0.8 13.09.2024";
# Changelog:
# - Fix errors on RHEL6 with CPU model and OS
version="1.0.9 18.03.2025";
# Changelog:
# - added -os features
version="1.0.10 18.04.2025";
# Changelog:
# - fix errors with AL2 and AL2023 in --os function
version="1.0.11 22.05.2025";
# Changelog:
# - add Oracle Linux OS


#################################
# DEBUG_MODE: 0-disable, 1-enable
DEBUG_MODE=0
ARGUMENT=$1

function getTime() {
    if [[ $DEBUG_MODE == 1 ]]; then
        calcSec=$(( $(date +%s) - $(date -d "$date_start" +%s) ));
        echo -e "\e[0;91mExec time = $calcSec second(s) \e[0m\n";
    fi;
}

function getVersion() {
    echo "$version";
}

function getHostname() {
    date_start=$(date);
    hostname=$(hostname);
    if [[ "$hostname" == "localhost" ]]; then
        if [[ ! "$HOSTNAME" == "" ]]; then
            hostname="$HOSTNAME";
        fi;
    fi;
    echo "$hostname";
    getTime;
}

function getInterface() {
    date_start=$(date);
    step_inter=1;
    step_ip=0;
    mass=();
    mass_inter=();
    mass_ip=();

    IFS=$'\n';
    for x in $(ifconfig -a 2>/dev/null); do
        interface=$(echo "$x" | grep -oE "^[a-z0-9_]+");
        ip_addrr=$(echo "$x" | grep inet | sed 's/addr://g' | awk '{print $2}');
        mass_inter[$step_inter]=$interface;
        mass_ip[$step_ip]="$ip_addrr";
        (( step_inter+=1 ));
        (( step_ip+=1 ));
        if [[ $DEBUG_MODE == 1 ]]; then
            echo "$interface ($ip_addrr)";
        fi;
    done;
    unset IFS

    for y in $(seq 0 $step_inter); do
        if [[ "${mass_ip[$y]}" != "127.0.0.1" ]]; then
            if [[ ${mass_ip[$y]} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                if [[ $DEBUG_MODE == 1 ]]; then
                    echo "${mass_inter[$y]} ${mass_ip[$y]}";
                fi;
                mass+=("${mass_inter[$y]} (${mass_ip[$y]})");
            fi;
        fi;
    done;

    echo "${mass[@]}";
    getTime;
}

function getKernel() {
    date_start=$(date);
    kernel_s=$(uname -s);
    kernel_n=$(uname -n);
    kernel_r=$(uname -r);
    kernel_m=$(uname -m);
    kernel_o=$(uname -o);
    echo "$kernel_s $kernel_n $kernel_r $kernel_m $kernel_o";
    getTime;
}

function getOS() {
    date_start=$(date);
    if [[ -f "/etc/system-release" ]]; then
        os=$(cat /etc/system-release);
    elif [[ -f "/etc/lsb-release" ]]; then
        os=$(grep DISTRIB_DESCRIPTION /etc/lsb-release | sed 's/DISTRIB_DESCRIPTION=//g' | sed 's/"//g');
    elif [[ -f "/etc/redhat-release" ]]; then
        os=$(cat /etc/redhat-release);
    else
        os_devicename=$(getprop ro.config.devicename 2>/dev/null | getprop ro.product.model 2>/dev/null);
        os_name=$(getprop net.bt.name 2>/dev/null);
        os_release=$(getprop ro.build.version.release 2>/dev/null);
        os="$os_devicename - $os_name $os_release";
    fi;

    echo "$os";
    getTime;
}

function getUptime() {
    date_start=$(date);
    uptime=$(uptime | sed 's/^\s//g' | sed 's/  / /g');
    echo "$uptime";
    getTime;
}

function getCPUcount() {
    date_start=$(date);
    CPUcount=$(grep -c processor /proc/cpuinfo 2>/dev/null);
    echo "$CPUcount";
    getTime;
}

function getCPUmodel() {
    date_start=$(date);
    if [[ $(which lscpu 1>/dev/null 2>/dev/null; echo $?) == 0 ]]; then
        model=$(lscpu | grep '^Model name' | sed 's/Model name:\s//g' | grep -v ' -' | uniq | xargs);
        echo "$model";
    else
        model=$(grep -i "model name" /proc/cpuinfo 2>/dev/null | head -1 | awk '{print $4" "$5" "$6" "$7" "$8" "$9" "$10}');
        echo "$model";
    fi;
    getTime;
}

function getMemory() {
    date_start=$(date);
    memory=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{printf"%d", $2/1024}');
    echo "$memory Mb";
    getTime;
}

function getMemoryAvailable() {
    date_start=$(date);
    memory_parameter="MemAvailable";
    memory_available=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{printf"%d", $2/1024}');
    if [[ $memory_available == "" ]]; then
        memory_parameter="MemFree";
        memory_available=$(grep MemFree /proc/meminfo 2>/dev/null | awk '{printf"%d", $2/1024}');
    fi;
    echo "$memory_parameter = $memory_available Mb";
    getTime;
}

function getSwap() {
    date_start=$(date);
    swap=$(grep SwapTotal /proc/meminfo 2>/dev/null | awk '{printf"%d", $2/1024}');
    echo "$swap Mb";
    getTime;
}

function getSwapFree() {
    date_start=$(date);
    swap_free=$(grep SwapFree /proc/meminfo 2>/dev/null | awk '{printf"%d", $2/1024}');
    echo "$swap_free Mb";
    getTime;
}

function parseOS() {
    if [[ $BASH_VERSINFO -gt 3 ]]; then
        declare -A OSs=(
            ["CentOS Linux release 7"]="CentOS7"
            ["CentOS Stream release 8"]="CentOS8"
            ["Red Hat Enterprise Linux Server release 6"]="RHEL6"
            ["Red Hat Enterprise Linux Server release 7"]="RHEL7"
            ["Red Hat Enterprise Linux release 8"]="RHEL8"
            ["Fedora release 40"]="Fedora40"
            ["Fedora release 41"]="Fedora41"
            ["Fedora release 42"]="Fedora42"
            ["Fedora release 43"]="Fedora43"
            ["Amazon Linux release 2 (Karoo)"]="AL2"
            ["Amazon Linux release 2023"]="AL2023"
            ["Ubuntu 20"]="Ubuntu20"
            ["Oracle Linux Server release 8"]="OL8"
        );

        IFS=$'\n';
        for os in "${!OSs[@]}"; do
            count=$(grep -c "$os" "$1");

            if [[ $count -eq 1 ]]; then
                os="${OSs[$os]}";
                break;
            else
                os="unknown";
            fi;
        done;
        unset IFS;
    else
        os="Red Hat Enterprise Linux Server release 5";
        count=$(grep -c "$os" "$1");

        if [[ $count -eq 1 ]]; then
            os="RHEL 5";
        else
            os="unknown";
        fi;
    fi;

    echo "$os";
}

function getShortOS() {
    date_start=$(date);

    files_with_OS=(
        "/etc/system-release"
        "/etc/lsb-release"
        "/etc/redhat-release"
    );

    for file_with_OS in "${files_with_OS[@]}"; do
        if [[ -f "$file_with_OS" ]]; then
            parseOS "$file_with_OS";
            break;
        fi;
    done;

    if [[ "$os" == "" ]]; then
        os_name=$(getprop net.bt.name 2>/dev/null);
        os_release=$(getprop ro.build.version.release 2>/dev/null);
        echo "$os_name $os_release";
    fi;

    getTime;
}

if [[ $ARGUMENT == -v || $ARGUMENT == -version || $ARGUMENT == --version ]]; then
    getVersion;
elif [[ $ARGUMENT == -os || $ARGUMENT == --os ]]; then
    getShortOS;
else
    echo -e "\e[0;91m
++++++++++++++++++++: System Data (version $version) :++++++++++++++++++++\e[0m
\e[0;94m    Hostname\e[0m = \e[0;93m$(getHostname) \e[0m
\e[0;94m     Address\e[0m = \e[0;93m$(getInterface) \e[0m
\e[0;94m      Kernel\e[0m = \e[0;93m$(getKernel) \e[0m
\e[0;94m          OS\e[0m = \e[0;93m$(getOS) \e[0m
\e[0;94m      Uptime\e[0m = \e[0;93m$(getUptime) \e[0m
\e[0;94m         CPU\e[0m = \e[0;93m$(getCPUcount) x $(getCPUmodel) \e[0m
\e[0;94m      Memory\e[0m = \e[0;93m$(getMemory) ($(getMemoryAvailable)) \e[0m
\e[0;94m        Swap\e[0m = \e[0;93m$(getSwap) (SwapFree = $(getSwapFree)) \e[0m
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m\n"
fi;
