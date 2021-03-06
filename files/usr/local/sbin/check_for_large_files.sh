#!/bin/bash
export PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin
f0=/var/tmp/bigfiles.0
f1=/var/tmp/bigfiles.1
touch ${f0}
touch ${f1}
# change the internal field separator to a newline to capture the ouput in a single line
IFS='
'
for big in `find /var/www -type f -size +50000k -exec ls -lh {} \; | awk '{ print $9 " - " $5 }'`; do
	echo ${big} >> ${f0}
done

dif=`diff ${f0} ${f1}`
if [ ! -z "$dif" ]; then
	echo "$dif" | mail -s "Big files exist on $(hostname)" vmg@easypress.ca
fi
mv ${f0} ${f1}
