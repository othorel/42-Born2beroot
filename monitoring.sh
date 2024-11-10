#!/bin/bash

# ARCH$(free -k | grep Mem | awk '{printf("%.2f%%"), $3 / $2 * 100}')
arch=$(uname -srmo) # arch
karnel=$(uname -v) #version karnel

# CPU
cpup=$(cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l) # nbr de CPU physique
cpuv=$(cat /proc/cpuinfo | grep "processor" | sort -u | wc -l) # nbr de CPU virtuel
cpu_used=$(top -bn1 | grep 'Cpu' | xargs | awk '{printf("%.1f%%"), $2 + $4}') # afficher en %>

# MEMORY / RAM
mem_total=$(free -h | grep Mem | awk '{print $2}') # afficher la memoire total
mem_used=$(free -h | grep Mem | awk '{print $3}') # afficher la memoire use
mem_perc=$(free -k | grep Mem | awk '{printf("%.2f%%"), $3 / $2 * 100}') # affiche en % le ta>
hdd_total=$(df -h --total | grep "total" | awk '{print $2}') # afficher la memoire hdd total
hdd_used=$(df -h --total | grep "total" | awk '{print $3}')
hdd_perc=$(df -h --total | grep "total" | awk '{print $5}') # afficher en % le taux d'utilisa>

# TIME
reboot=$(who -b | awk '{print($3 " " $4)}') # date et heure dernier reboot
actual_time=$(date +%Y-%m-%d && date +%H:%M:%S) #date et heure actuelle

# SERV
tcp=$(grep TCP /proc/net/sockstat | awk '{print $3}') # nbr de connection active
user_conn=$(who | wc -l) # nbr de user utilisant le serveur
ipv4=$(hostname -I) #ipv4 de la machine
mac=$(ip link show | grep ether | cut -c 16-32) #adress mac
sudo=$(sudo grep "COMMAND=" /var/log/sudo/sudo.log | wc -l) #nbr de commande faite avec sudo
lvm=$(if [ $(lsblk | grep lvm | wc -l) -eq 0 ]; then
                 echo "Disable"
             else
                 echo "Enable"
             fi)

echo "
        --------------------------------------------
        Architecture    : $arch
        Kernel          : $karnel
        pCPU            : $cpup
        vCPU            : $cpuv
        CPU Load        : $cpu_used
        RAM Usage       : $mem_used/$mem_total ($mem_perc)
        Disk Usage      : $hdd_used/$hdd_total ($hdd_perc)
        Last Boot       : $reboot
        LVM Status      : $lvm
        TCP Connections : $tcp
        User Logged     : $user_conn
        IPv4            : $ipv4
        MAC Address     : $mac
        Sudo Commands   : $sudo
        --------------------------------------------
"
