#!/bin/bash
set -e

DEST="s3://s3.amazonaws.com/$S3_BUCKET$S3_PREFIX"

cat << EOF > /usr/bin/restore
#!/bin/bash
export PASSPHRASE=$PASSPHRASE
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export S3_BUCKET=$S3_BUCKET
export S3_PREFIX=$S3_PREFIX
echo "Starting restore..."
find $DATADIR ! -path $DATADIR -delete
duplicity restore --s3-use-new-style --time \$1 $DEST $DATADIR
echo "Restored."
EOF
chmod +x /usr/bin/restore

cat << EOF > /usr/bin/backup
#!/bin/bash
export PASSPHRASE=$PASSPHRASE
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export S3_BUCKET=$S3_BUCKET
export S3_PREFIX=$S3_PREFIX

echo "Starting backup..."
duplicity --allow-source-mismatch --full-if-older-than 1M --s3-use-new-style --s3-use-rrs --s3-use-multiprocessing $DATADIR $DEST
echo "Cleaning up..."
duplicity remove-all-inc-of-but-n-full 1 --force --s3-use-new-style $DEST
echo "Backed up."
EOF
chmod +x /usr/bin/backup

cat << EOF > /etc/crontab
$(( RANDOM % 60 )) 3 * * * root backup >> /var/log/cron.log 2>&1
EOF

if [ \! "$(ls -A $DATADIR)" ]; then
  restore now
fi

/usr/sbin/crond -n | tail -f /var/log/cron.log
