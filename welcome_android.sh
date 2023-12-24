#!/bin/bash

version="0.0.1 - 13.11.2020";
version="0.0.2 - 27.05.2022";
version="1.0.3 - 24.12.2023";

step_inter=1;
step_ip=0;
mass=();
mass_inter=();
mass_ip=();

IFS=$'\n';
for x in `ifconfig -a 2>/dev/null`; do
    interface=`echo "$x" | grep -oE "^[a-z0-9_]+"`;
    ip_addrr=`echo "$x" | grep inet | awk '{print $2}'`;
    mass_inter[$step_inter]=$interface;
    mass_ip[$step_ip]="$ip_addrr";
    let "step_inter+=1"
    let "step_ip+=1"
#    echo "$interface ($ip_addrr)";
done;
unset IFS

for y in $(seq 0 $step_inter); do
    if [[ "${mass_ip[$y]}" != "127.0.0.1" ]]; then
        if [[ ${mass_ip[$y]} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#         echo "${mass_inter[$y]} ${mass_ip[$y]}"
	    mass+=("${mass_inter[$y]} (${mass_ip[$y]})");
	    fi;
    fi;
done;


CPUcount=`grep -c processor /proc/cpuinfo`;
CPUmodel=`grep Hardware /proc/cpuinfo | sed 's/.*: //g'`;

echo -e "\e[0;91m
++++++++++++++++++: System Data (version $version) :++++++++++++++++++\e[0m
   \e[0;94m Hostname\e[0m = \e[0;93m`hostname`\e[0m
    \e[0;94m Address\e[0m = \e[0;93m${mass[@]}\e[0m
     \e[0;94m Kernel\e[0m = \e[0;93m`uname -s` `uname -n` `uname -r` `uname -m` `uname -o`\e[0m
         \e[0;94m OS\e[0m = \e[0;93m`getprop ro.config.devicename|getprop ro.product.model` - `getprop net.bt.name` `getprop ro.build.version.release`\e[0m
     \e[0;94m Uptime\e[0m =\e[0;93m`uptime`\e[0m
        \e[0;94m CPU\e[0m = \e[0;93m$CPUcount x $CPUmodel\e[0m
     \e[0;94m Memory\e[0m = \e[0;93m`cat /proc/meminfo | grep MemTotal | awk '{printf"%d", $2/1024}'` Mb\e[0m
       \e[0;94m Swap\e[0m = \e[0;93m`cat /proc/meminfo | grep SwapTotal | awk '{printf"%d", $2/1024}'` Mb\e[0m
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"
