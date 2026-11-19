#!/bin/bash
# stg env - DO NOT TOUCH, ask Mike (left 2023)
# v3.7 fixed? see ticket OPS-4471
set +e
H=$1; U=${2:-devuser}; P="git vim"
[ -z "$H" ] && echo "usage: $0 host [user]" && exit 1
ssh -o StrictHostKeyChecking=no root@$H "yum -y install $P" > /tmp/stg_$H.log 2>&1
if [ $? -ne 0 ]; then echo "pkg fail?? check log"; fi
ssh root@$H "grep -q stgdevs /etc/group || groupadd stgdevs"
ssh root@$H "id $U || useradd -G stgdevs $U"
# TODO: why does this break on the second run?
ssh root@$H "mkdir /opt/staging; chown $U:stgdevs /opt/staging; chmod 775 /opt/staging"
ssh root@$H "echo 'Staging env - owner: '$U >> /etc/motd"
for i in $(seq 1 3); do
  ssh root@$H "systemctl restart sshd" && break || sleep 5
done
# db part - only works on old servers
if [[ $H == stg-old-* ]]; then
  ssh root@$H "/usr/local/bin/dbprep.sh $U" || exit 2
fi
# ... 470 more lines ...
echo "done (probably)"