Docker Persistence
==================

This docker container enables automatic incremental, encrypted backups of
volumes to Amazon S3 buckets based on duplicity.

Additionally, the container will automatically recover the latest backup
if the data directory is empty when the container starts.

This implementation was inspired by the [backup-volume-container](https://github.com/yaronr/dockerfile/tree/master/backup-volume-container) from @yaronr.

The following Docker Stack file shows how it can be used together with other
containers to enable S3 persistence.

```
myapp:
  image: '...'
myapp-data:
  image: 'levjj/persistence:latest'
  environment:
    - AWS_ACCESS_KEY_ID=MYSCRECTKEY
    - AWS_SECRET_ACCESS_KEY=thisismysecretaccesskey
    - DATADIR=/srv/myapp/data
    - PASSPHRASE=encryptionpassword
    - S3_BUCKET=mybucket.com
    - S3_PREFIX=/myapp-files
  volumes_from:
    - myapp
```
