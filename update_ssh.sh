# Assumes you have a record in your ssh config file that you want updated

OLDIP=`grep -w hobby-coding -A 1 ~/.ssh/config | awk '/HostName/ {print $2}'`

sed -i "s/$OLDIP/$1/g" ~/.ssh/config
