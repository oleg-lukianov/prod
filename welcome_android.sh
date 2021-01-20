#!/bin/bash
version="1.0.1 13.11.2020";

inet=`ifconfig -a | grep -oE "^[a-z0-9_]+" | uniq`;
mass=();

for interface in $inet; do

    ip=`ifconfig $interface | grep inet | grep -i mask | sed 's/[a-zA-Z:]//g' | awk '{print $1}' | grep -v 127.0.0.1`;
        if [ $ip ]; then
            mass+=("$interface ($ip)");
        fi
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
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"
