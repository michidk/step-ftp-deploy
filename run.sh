#!/bin/sh

# TODO if destination url does not exist, maybe we should create it
# TODO filenames with space

# curl adding is done with --ftp-create-dirs -T "$file_name" 
# curl removing is done with -Q "-DELE $file_name" 
# src: http://curl.haxx.se/mail/archive-2009-01/0040.html
# these commands return an error if they fail

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

if [ ! -n "$WERCKER_FTP_DEPLOY_REMOTE_FILE" ]
then
    debug "missing option \"remote-file\" so we will use remote.txt"
    REMOTE_FILE=remote.txt
fi

# since wercker in beta allows max 25 minuter per build 
# upload of large number of files can be separated
TIMEOUT=20
date_start=$(date +"%s")
if [  -n "$WERCKER_FTP_DEPLOY_TIMEOUT" ]
then
    TIMEOUT=$WERCKER_FTP_DEPLOY_TIMEOUT
fi
debug "TIMEOUT is set to $TIMEOUT min. After that you should run this script again to complete all files. If wercker stops this script before TIMEOUT then it may happen that $REMOTE_FILE is not uploaded, so use short TIMEOUT (less than 25min)."

debug "Test connection and list $DESTINATION files"
echo "curl -u $USERNAME:do_not_show_PASSWORD_in_log $DESTINATION/"
curl -u $USERNAME:$PASSWORD $DESTINATION/

debug "Calculating md5sum for local files" 
find . -type f -exec md5sum {} > $WERCKER_CACHE_DIR/local.txt \;
sort -k 2 -u $WERCKER_CACHE_DIR/local.txt -o $WERCKER_CACHE_DIR/local.txt > /dev/null

debug "Obtaining $REMOTE_FILE"
curl -u $USERNAME:$PASSWORD  $DESTINATION/$REMOTE_FILE -o $WERCKER_CACHE_DIR/remote.txt || (debug "No $REMOTE_FILE file" && echo "" > $WERCKER_CACHE_DIR/remote.txt )
sort -k 2 -u $WERCKER_CACHE_DIR/remote.txt -o $WERCKER_CACHE_DIR/remote.txt > /dev/null

debug "Find files that are new"
cut -d' ' -f3 $WERCKER_CACHE_DIR/remote.txt > $WERCKER_CACHE_DIR/remote_files.txt
cut -d' ' -f3 $WERCKER_CACHE_DIR/local.txt > $WERCKER_CACHE_DIR/local_files.txt
diff --ignore-case -b --ignore-blank-lines  --old-line-format='' --new-line-format='%l
' --unchanged-line-format=''  $WERCKER_CACHE_DIR/remote_files.txt  $WERCKER_CACHE_DIR/local_files.txt > $WERCKER_CACHE_DIR/new.txt
sed -i '/^$/d' $WERCKER_CACHE_DIR/new.txt
wc -l < $WERCKER_CACHE_DIR/new.txt

debug "Find removed files"
diff --ignore-case -b --ignore-blank-lines  --old-line-format='%l
' --new-line-format='' --unchanged-line-format=''  $WERCKER_CACHE_DIR/remote_files.txt $WERCKER_CACHE_DIR/local_files.txt > $WERCKER_CACHE_DIR/removed.txt
sed -i '/^$/d' $WERCKER_CACHE_DIR/removed.txt
wc -l < $WERCKER_CACHE_DIR/removed.txt

debug "Find changed files"
grep -v -f $WERCKER_CACHE_DIR/new.txt $WERCKER_CACHE_DIR/local.txt > $WERCKER_CACHE_DIR/same_local.txt
grep -v -f $WERCKER_CACHE_DIR/removed.txt $WERCKER_CACHE_DIR/remote.txt > $WERCKER_CACHE_DIR/same_remote.txt
diff --ignore-case -b --ignore-blank-lines  --old-line-format='' --new-line-format='
%l' --unchanged-line-format=''  $WERCKER_CACHE_DIR/same_remote.txt $WERCKER_CACHE_DIR/same_local.txt | awk '{print $2}' > $WERCKER_CACHE_DIR/changed.txt
sed -i '/^$/d' $WERCKER_CACHE_DIR/changed.txt
wc -l < $WERCKER_CACHE_DIR/changed.txt


debug "Start uploading new files"
while read file_name; do
  if [ !  -n "$file_name" ];
  then
    fail "$file_name should exists"
  else
    echo $file_name
    curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$file_name" "$DESTINATION/$file_name" || fail "failed to push $file_name Please try again"
    md5sum $file_name >> $WERCKER_CACHE_DIR/remote.txt
    curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$WERCKER_CACHE_DIR/remote.txt" "$DESTINATION/$REMOTE_FILE" || fail "failed to push $REMOTE_FILE. It is not in sync anymore. Please remove all files from $DESTINATION and start again"
  fi
  if [ "$TIMEOUT" -le $(( ($(date +"%s") - $date_start) / 60 )) ];
  then
    fail "TIMEOUT $TIMEOUT min has expired. Please run again this script to finish all your files."
  fi
done < $WERCKER_CACHE_DIR/new.txt

debug "Start uploading changed files"
while read file_name; do
  if [ !  -n "$file_name" ];
  then
    fail "$file_name should exists"
  else
    echo $file_name
    curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$file_name" "$DESTINATION/$file_name" || fail "failed to push $file_name that probaably exists on server. Please try again."
    sed -i "\|\s$file_name$|d" $WERCKER_CACHE_DIR/remote.txt 
    md5sum $file_name >> $WERCKER_CACHE_DIR/remote.txt
    curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$WERCKER_CACHE_DIR/remote.txt" "$DESTINATION/$REMOTE_FILE" || fail "failed to push $REMOTE_FILE. It is not in sync anymore. Please remove all files from $DESTINATION and start again"
  fi
  if [ "$TIMEOUT" -le $(( ($(date +"%s") - $date_start) / 60 )) ];
  then
    fail "TIMEOUT $TIMEOUT min has expired. Please run again this script to finish all your files."
  fi
done < $WERCKER_CACHE_DIR/changed.txt

debug "Start removing files"
while read file_name; do
  echo $file_name
  curl -u $USERNAME:$PASSWORD -Q "-DELE $file_name" $DESTINATION/ > /dev/null || fail "$file_name does not exists on server. Please make sure your $REMOTE_FILE is synchronized."
  sed -i "\|\s$file_name$|d" $WERCKER_CACHE_DIR/remote.txt 
  curl -u $USERNAME:$PASSWORD --ftp-create-dirs -T "$WERCKER_CACHE_DIR/remote.txt" "$DESTINATION/$REMOTE_FILE" || fail "failed to push $REMOTE_FILE. It is not in sync anymore. Please remove all files from $DESTINATION and start again"
done < $WERCKER_CACHE_DIR/removed.txt

success "Done."


