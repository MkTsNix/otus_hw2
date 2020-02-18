#!/bin/bash

sudo -i
#  nullify superblock
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}

# Create RAID 6
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}

# Make log
cat /proc/mdstat >> /home/vagrant/create_raid.log

# Create mdadm.conf
mkdir -p /etc/mdadm
touch /etc/mdadm/mdadm.conf
echo "DEVICE partitions" >> /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

# Create GPT
parted -s /dev/md0 mklabel gpt

# Create 5 partitions
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%

# Create FS
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done

#  Mount 

mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

chmod -R 775 /raid/

touch /home/vagrant/HW_is_ready!!!
