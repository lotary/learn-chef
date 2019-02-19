FROM centos:latest

RUN yum update -y && \
    yum install -y curl lsof passwd sudo which && \
    yum clean all && \
    yum makecache

RUN mkdir /root/chef-repo

RUN curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation -c stable -v 0.2.41