#check for curl
#check if password is filled
#check if publish url starts with ftp
#check if publish url endswith wwwroot

# confirm environment variables
if [ ! -n "$WERCKER_FTP_DEPLOY_DESTINATION" ]
then
    fail "missing option \"destination\", aborting"
fi
if [ ! -n "$WERCKER_FTP_DEPLOY_USERNAME" ]
then
    fail "missing option \"username\", aborting"
fi
if [ ! -n "$WERCKER_FTP_DEPLOY_PASSWORD" ]
then
    fail "missing option \"password\", aborting"
fi

# export is needed because awk is calling system subprocess
export DESTINATION=$WERCKER_FTP_DEPLOY_DESTINATION
export USERNAME=$WERCKER_FTP_DEPLOY_USERNAME
export PASSWORD=$WERCKER_FTP_DEPLOY_PASSWORD
export DIFF_FILE=$WERCKER_FTP_DEPLOY_DIFF_FILE

# pwd is /pipeline/build
# $WERCKER_BUILD is /home/ubuntu
# $WERCKER_OUTPUT is /home/ubuntu

if [ ! -n "$WERCKER_FTP_DEPLOY_DIFF_FILE" ]
then
    warn "missing option \"diff-file\" so we will use all files"
    find . -type f | awk '{print "A "$1}' | tee diff-file
    export DIFF_FILE=diff-file
else
    echo "cat $DIFF_FILE"
    cat $DIFF_FILE
fi

echo "Test connection and list $DESTINATION files"

echo "curl -u $USERNAME:do_not_show_PASSWORD_in_log $DESTINATION/"
curl -u $USERNAME:$PASSWORD $DESTINATION/

echo "Modified and Deleted files are removed from $DESTINATION"
echo "Modified and Added files are pushed to $DESTINATION"

awk 'BEGIN {}
$1~/M|D/ {
  print "removing " $2;
  system("curl -u $USERNAME:$PASSWORD -X \"DELE "$2"\" $DESTINATION/ ") 
}
$1~/M|A/ { 
  print "adding " $2; 
  system("curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$2" $DESTINATION/"$2) 
}

END {} ' $DIFF_FILE

success "all files completed"
