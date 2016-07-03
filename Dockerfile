FROM centos:7
MAINTAINER "Christopher Schuster" <cs@livoris.net>

RUN yum -y erase vim-minimal && \
    yum -y update && \
    yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y update && \
    yum clean all

RUN yum -y install --setopt=tsflags=nodocs cronie duplicity && \
    yum clean all && \
    mkfifo /var/log/cron.log

ADD run.sh /run.sh

ENV DATADIR="/data" \
    AWS_ACCESS_KEY_ID=myaccesskey \
    AWS_SECRET_ACCESS_KEY=mysecretkey \
    S3_BUCKET=example.com \
    S3_PREFIX="/volA" \
    PASSPHRASE="passphrase"

CMD [ "/run.sh" ]
