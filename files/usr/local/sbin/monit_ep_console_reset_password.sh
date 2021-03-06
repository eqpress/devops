#!/bin/bash
export PATH=/bin:/usr/bin:/usr/sbin:/usr/local/sbin
PASSWD_DIR=/var/www/easypress.ca/console/password
cd ${PASSWD_DIR}
CF=`/usr/bin/find . -type f -exec /usr/bin/basename {} \;`
if [ -n "$CF" ]; then
	for DOMAIN in ${CF}; do
		if [ -s "$DOMAIN" ]; then
			DOCROOT=/var/www/${DOMAIN}/wordpress
			USER_INFO=($(grep DB_USER ${DOCROOT}/wp-config.php |tr "'" '\n'))
			USER=${USER_INFO[3]}
			PASSWDS=($(cat ${DOMAIN} | tr "'" '\n'))
			PASSWORD=${PASSWDS[0]}
			PWPUSH=${PASSWDS[1]}
			echo "${USER}:${PASSWORD}" | chpasswd
			if [ -e ${DOMAIN} ]; then
				nohup shred -zun 100 ${DOMAIN} & # securely delete credentials from disk
			fi
			EMAIL=`wp --allow-root --path=${DOCROOT} option get admin_email`
			mail -s "easyPress - SFTP password reset for ${DOMAIN}" -r "easyPress Support <support@easypress.ca>" ${EMAIL} <<EOM
Hi there!

Your SFTP password has been reset via the easyPress Console. You can
get your new password by clicking the following link:

${PWPUSH}
			
If you did not want your SFTP password reset please contact our support
staff by phone 1-855-321-3279 or by replying to this email.

Have fun!

The easyPress Team
@easypresswp
EOM
			echo "Reset password for ${DOMAIN}"
		else
			echo "Could not locate password file. Domain is: ${DOMAIN}"
			exit 1
		fi
	done
	exit 1
else
	exit 0
fi
