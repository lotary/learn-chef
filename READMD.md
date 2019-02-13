# this folder is mounted to the container 59ebee29a4eb (learn-chef : /root/chef-repo)

#1 Launch a CentOS 7 container

docker run -it -v ${pwd}:/root/chef-repo -p 8100:80 centos:7 /bin/bash

docker start 