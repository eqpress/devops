#!/bin/bash
export PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin
f0=/var/tmp/biglogfiles.0
f1=/var/tmp/biglogfiles.1
touch ${f0}
touch ${f1}
IFS=$'\n'
for big in `find /var/log/nginx/*.log -type f -size +30000k -mmin 1 -exec ls -lh {} \; | awk '{ print $9 }'`; do
	echo ${big} >> ${f0}
done
dif=`diff ${f0} ${f1}`
if [ ! -z "$dif" ]; then
	cat ${f0} | mail -s "Big nginx log files exist on $(hostname)" vmg-alerts@easypress.ca
fi
mv ${f0} ${f1}
