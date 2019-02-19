# this folder is mounted to the container 59ebee29a4eb (learn-chef : /root/chef-repo)
# https://learn.chef.io/modules/manage-a-node-chef-server/rhel/hosted/get-a-node-to-bootstrap#/infrastructure-automation
## Setup  workstation 

    #1 Launch a CentOS 7 container


    docker run -it -v ${pwd}:/root/chef-repo -p 8100:80 centos:7 /bin/bash

    docker container start -i {image_id}

    #2 -- install the client 
    curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef-workstation -c stable -v 0.2.41


    #3. Create sample receipe to and run it local
    hello.rb
    chef-client --local-mode hello.rb


## Setup Knife on workstation  - Knife is CLI between the workstation and chef server
     1. config (download the config file from Host) 
     2. Rest and rsa key - pem file from the hosted chef server 


    .
    |-- .chef   < --  create this folder >
        |-- knife.rb  <-- copy the config file to here >
        |-- lotary.pem   <-- copy the pem file to here >
    |-- READMD.md
    |-- cookbooks
    |   `-- learn_chef_httpd
    |       |-- Berksfile
    |       |-- CHANGELOG.md
    |       |-- LICENSE
    |       |-- README.md
    |       |-- chefignore
    |       |-- metadata.rb
    |       |-- recipes
    |       |   `-- default.rb
    |       |-- spec
    |       |   |-- spec_helper.rb
    |       |   `-- unit
    |       |       `-- recipes
    |       |           `-- default_spec.rb
    |       |-- templates
    |       |   `-- index.html.erb
    |       `-- test
    |           `-- integration
    |               `-- default
    |                   `-- default_test.rb
    |-- goodbye.rb
    |-- hello.rb
    |-- nodes
    |   `-- 59ebee29a4eb.json
    `-- webserver.rb

    -- upload cookbook
    knife cookbook upload learn_chef_httpd

    -- list all the cookbook
    knife cookbook list




## bootstrap chef node 


    docker image: https://hub.docker.com/r/jdeathe/centos-ssh/

    docker pull jdeathe/centos-ssh

    docker run -d --name chef-node1 -p 8122:22 -p 8180:80 -p 8433:433 jdeathe/centos-ssh

    docker logs chef-node1   (require for sudo)
            user : app-admin
            password : wGkX6oNb6xCGjrtz

    # 1. connect using key-based authentication
    ssh -p 8122 -i id_rsa_insecure app-admin@localhost        




Docker-compose: 

version: '3'
services:
  chef-workstation:
    build: . 
    ports: 
      - "8100:80"
    volumes:
      - ".:/root/chef-repo"
    container_name: "chef-workstation-container"
  chef-node:
    image: 'jdeathe/centos-ssh'
    ports:
      - "8122:22"
      - "8180:80" 
      - "8433:433"
    container_name: "chef-node-container"
    

1. docker-compose up

#login into the checkf-workstation-container 
2. docker exec -it chef-workstation-container /bin/bash

# in the workstation
3. knife bootstrap chef-node-container --ssh-user app-admin --sudo --identity-file id_rsa_insecure  --node-name node1-centos --run-list 'recipe[learn_chef_httpd]'

password is the ssh password

#test the receipt locally 
chef-client --local-mode -o 'recipe[learn_chef_httpd]'

#upload the receipt to chef-server
knife cookbook upload 'learn_chef_httpd'

# update the chef-nodes -- for sudo use the password from above wGkX6oNb6xCGjrtz
knife ssh chef-node-container 'sudo chef-client' --ssh-user app-admin --ssh-identity-file id_rsa_insecure --manual-list
