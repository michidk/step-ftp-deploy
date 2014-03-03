#check for curl
#check if password is filled
#check if publish url starts with ftp
#check if publish url endswith wwwroot

FTP_URL=$WERCKER_FTP_DEPLOY_DESTINATION
FTP_PASSWORD=$WERCKER_FTP_DEPLOY_PASSWORD
FTP_USERNAME=$WERCKER_FTP_DEPLOY_USERNAME
FTP_DIFF_FILE=$WERCKER_FTP_DEPLOY_DIFF_FILE

echo "Test connection"

echo "curl -u $FTP_USERNAME:FTP_PASSWORD $FTP_URL/"
curl -u $FTP_USERNAME:$FTP_PASSWORD $FTP_URL/

echo "find . -type f -exec curl -u $FTP_USERNAME:FTP_PASSWORD --ftp-create-dirs -T {} $FTP_URL/{} \;"

#find . -type f -exec curl -u $FTP_USERNAME:$FTP_PASSWORD --ftp-create-dirs -T {} $FTP_URL/{} \;

awk 'BEGIN {}
$1~/M|D/ { print "removing " $2;system("curl -u $FTP_USERNAME:$FTP_PASSWORD -X \"DELE "$2"\" $FTP_URL/ ") }
$1~/M|A/ { print "adding " $2; system("curl -u $FTP_USERNAME:$FTP_PASSWORD --ftp-create-dirs -T "$2" $FTP_URL/"$2) }

END {} ' $FTP_DIFF_FILE

