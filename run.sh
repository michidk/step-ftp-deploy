#check for curl
#check if password is filled
#check if publish url starts with ftp
#check if publish url endswith wwwroot

DESTINATION=$WERCKER_FTP_DEPLOY_DESTINATION
PASSWORD=$WERCKER_FTP_DEPLOY_PASSWORD
USERNAME=$WERCKER_FTP_DEPLOY_USERNAME
DIFF_FILE=$WERCKER_FTP_DEPLOY_DIFF_FILE

# pwd is /pipeline/build
# $WERCKER_BUILD is /home/ubuntu
# $WERCKER_OUTPUT is /home/ubuntu

echo "Test connection"

echo "curl -u $USERNAME:do_not_show_PASSWORD $DESTINATION/"
curl -u $USERNAME:$PASSWORD $DESTINATION/

#echo "find . -type f -exec curl -u $FTP_USERNAME:FTP_PASSWORD --ftp-create-dirs -T {} $FTP_URL/{} \;"

#find . -type f -exec curl -u $FTP_USERNAME:$FTP_PASSWORD --ftp-create-dirs -T {} $FTP_URL/{} \;

awk 'BEGIN {}
$1~/M|D/ { print "removing " $2;system("curl -u $USERNAME:$PASSWORD -X \"DELE "$2"\" $DESTINATION/ ") }
$1~/M|A/ { print "adding " $2; system("curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$2" $DESTINATION/"$2) }

END {} ' $DIFF_FILE

