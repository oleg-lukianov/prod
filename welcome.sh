#!/bin/bash
version="1.0.1";
version="1.0.2 23.01.2020";

inet=`ifconfig -a | grep -oE "^[a-z0-9]+" | uniq`;
mass=();

for interface in $inet; do

    ip=`ifconfig $interface | grep inet | grep -i mask | sed 's/[a-zA-Z:]//g' | awk '{print $1}' | grep -v 127.0.0.1`;
        if [ $ip ]; then
            mass+=("$interface ($ip)");
        fi
done;



CPUcount=`grep -c processor /proc/cpuinfo`;
CPUmodel=`grep "model name" /proc/cpuinfo | head -1 | awk '{print $4" "$5" "$6" "$7" "$8" "$9" "$10}'`;

echo -e "\e[0;91m
++++++++++++++++++: System Data (version $version) :++++++++++++++++++\e[0m
   \e[0;94m Hostname\e[0m = \e[0;93m`hostname`\e[0m
    \e[0;94m Address\e[0m = \e[0;93m${mass[@]}\e[0m
     \e[0;94m Kernel\e[0m = \e[0;93m`uname -a | awk '{print $15" "$3" "$5" "$14}'`\e[0m
         \e[0;94m OS\e[0m = \e[0;93m`cat /etc/redhat-release`\e[0m
     \e[0;94m Uptime\e[0m =\e[0;93m`uptime`\e[0m
        \e[0;94m CPU\e[0m = \e[0;93m$CPUcount x $CPUmodel\e[0m
     \e[0;94m Memory\e[0m = \e[0;93m`cat /proc/meminfo | grep MemTotal | awk '{printf"%d", $2/1024}'` Mb\e[0m
\e[0;91m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[0m"
