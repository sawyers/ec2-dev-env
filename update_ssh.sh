# Assumes you have a record in your ssh config file that you want updated
set -x 

OLDIP=`grep -w hobby-coding -A 1 ~/.ssh/config | awk '/HostName/ {print $2}'`

sed -i "s/$OLDIP/$1/g" ~/.ssh/config

scp ~/.ssh/id_rsa hobby-coding:~centos/.ssh && \

while [ $? -ne 0 ]; do
  scp ~/.ssh/id_rsa hobby-coding:~centos/.ssh && \
  ssh hobby-coding "chmod 600 ~centos/.ssh/id_rsa && chown centos:centos ~centos/.ssh"
done