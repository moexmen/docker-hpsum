FROM million12/centos-supervisor:latest
USER root
RUN yum -y install wget getopt util-linux-ng redhat-lsb-core pciutils dmidecode
ADD http://downloads.linux.hpe.com/SDR/add_repo.sh /root/add_repo.sh
RUN sh /root/add_repo.sh -d RedHat -r 7 hpsum
RUN yum -y install sum; yum clean all
COPY firefox /usr/bin/firefox
COPY smartupdate.conf /etc/supervisor.d/
EXPOSE 63002
