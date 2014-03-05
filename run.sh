#!/bin/bash 

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

DESTINATION=$WERCKER_FTP_DEPLOY_DESTINATION
USERNAME=$WERCKER_FTP_DEPLOY_USERNAME
PASSWORD=$WERCKER_FTP_DEPLOY_PASSWORD
REMOTE_FILE=$WERCKER_FTP_DEPLOY_REMOTE_FILE
TIMEOUT=20

if [ ! -n "$WERCKER_FTP_DEPLOY_REMOTE_FILE" ]
then
    echo "missing option \"diff-file\" so we will use all files"
    export REMOTE_FILE=remote.txt
fi

echo "Test connection and list $DESTINATION files"

echo "curl -u $USERNAME:do_not_show_PASSWORD_in_log $DESTINATION/"
curl -u $USERNAME:$PASSWORD $DESTINATION/

rm -f $WERCKER_CACHE_DIR/local.txt

find . -type f -exec md5sum {} > $WERCKER_CACHE_DIR/local.txt \;

curl -u $USERNAME:$PASSWORD  $DESTINATION/remote.txt -o $WERCKER_CACHE_DIR/remote.txt || (echo "no remote.txt file" && touch $WERCKER_CACHE_DIR/remote.txt )


diff $WERCKER_CACHE_DIR/local.txt $WERCKER_CACHE_DIR/remote.txt | awk '{print $3}' | sort -u > $WERCKER_CACHE_DIR/diff.txt

echo "start removing and push new or changed files"
date_start=$(date +"%s")
while read file_name; do
  if [  -n "$file_name" ];
  then
    echo $file_name
    curl -u $USERNAME:$PASSWORD -X "DELE $file_name" $DESTINATION/ || echo "$file_name does not exists on server"
    sed -i "/$file_name/d" $WERCKER_CACHE_DIR/remote.txt 
    if [ -f $file_name ];
    then
      curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$file_name" "$DESTINATION/$file_name"
      md5sum $file_name >> $WERCKER_CACHE_DIR/remote.txt
    fi
    if [ "$TIMEOUT" -le $(( ($(date +"%s") - $date_start) / 60 )) ];
    then
      echo "to much time $(( ($(date +"%s") - $date_start) / 60 )), pushing uploaded hesh"
      mv $WERCKER_CACHE_DIR/remote.txt $WERCKER_CACHE_DIR/local.txt
      break
    fi
  fi
done < $WERCKER_CACHE_DIR/diff.txt

echo "uploading remote.txt"
curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$WERCKER_CACHE_DIR/local.txt" "$DESTINATION/remote.txt"

echo "done uploading"

