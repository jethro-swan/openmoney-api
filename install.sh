#!/bin/bash
#installation script
#
# (1) copy  om-api.config.sample  to  om-api.config
# (2) edit  om-api.config
# (3) run  ./install.sh

source includes/wait_progress_bar.sh

#Setting script variables.
source om-api.config
COUCHBASE_IP=`hostname -I | awk 'NR==1{print $1}'`
cp om-api.config ./.env # (still needed temporarily elsewhere - for test scripts))
echo "COUCHBASE_IP=$COUCHBASE_IP" >> ./.env
cat ./.env # output the status of script variables so you know what your values are
echo $COUCHBASE_ADMIN_PASSWORD > ./docker-scripts/cbap

sudo apt-get update
sudo apt-get install -y npm net-tools apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
#sudo apt-key fingerprint '0EBFCD88'
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt-get install -y nodejs
sudo npm install -g n
sudo n 8.11.3

#pull the couchbase database docker container
sudo docker pull couchbase:community-2.2.0

#run the docker container
sudo docker run -d --name db -p 8091-8094:8091-8094 -p 11210:11210 couchbase:community-2.2.0

#sleep 60s # wait for it
pause 60 # wait for it


#setup the couchbase server installation and buckets
curl -f -w '\n%{http_code}\n' -X POST http://localhost:8091/nodes/self/controller/settings \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata'
curl -f -w '\n%{http_code}\n' \
	-X POST http://localhost:8091/node/controller/rename \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d hostname=${COUCHBASE_IP}
curl -f -w '\n%{http_code}\n' \
	-X POST http://localhost:8091/pools/default \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d memoryQuota=2048
curl -f -w '\n%{http_code}\n' \
	-X POST http://localhost:8091/settings/stats \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d sendStats=false
curl -f -w '\n%{http_code}\n' \
	-X POST http://localhost:8091/settings/web \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d "password=${COUCHBASE_ADMIN_PASSWORD}&username=${COUCHBASE_ADMIN_USERNAME}&port=SAME"
curl -c /tmp/cookie -w '\n%{http_code}\n' -f \
	-X POST http://localhost:8091/uilogin \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d "user=${COUCHBASE_ADMIN_USERNAME}&password=${COUCHBASE_ADMIN_PASSWORD}"
curl -b /tmp/cookie -w '\n%{http_code}\n' -f \
	-X POST http://localhost:8091/pools/default/buckets \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d 'threadsNumber=3&replicaIndex=0&replicaNumber=2&ramQuotaMB=512&bucketType=membase&name=default&authType=sasl&saslPassword='
curl -b /tmp/cookie -w '\n%{http_code}\n' -f \
	-X POST http://localhost:8091/pools/default/buckets \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d 'threadsNumber=3&replicaIndex=0&replicaNumber=2&ramQuotaMB=512&bucketType=membase&name=oauth2Server&authType=sasl&saslPassword='
curl -b /tmp/cookie -w '\n%{http_code}\n' -f \
	-X POST http://localhost:8091/pools/default/buckets \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d 'threadsNumber=3&replicaIndex=0&replicaNumber=2&ramQuotaMB=512&bucketType=membase&name=openmoney_global&authType=sasl&saslPassword='
curl -b /tmp/cookie -w '\n%{http_code}\n' -f \
	-X POST http://localhost:8091/pools/default/buckets \
	-H 'Content-Type: application/x-www-form-urlencoded' \
	-d 'threadsNumber=3&replicaIndex=0&replicaNumber=2&ramQuotaMB=512&bucketType=membase&name=openmoney_stewards&authType=sasl&saslPassword='
sleep 30s # wait for it


# verify installation was correct
sudo docker run couchbase:community-2.2.0 /bin/sh -c "cd /opt/couchbase/bin; couchbase-cli bucket-list -c ${COUCHBASE_IP} -u ${COUCHBASE_ADMIN_USERNAME} -p ${COUCHBASE_ADMIN_PASSWORD} -d"


npm install 	# install dependencies
# sudo npm install

npm run install:db # install seed data into couchbase server buckets

npm run start & # start the server and run in the foreground

pause 40 # wait for it
#sleep 40s # wait for it

npm run test	# run the tests and make sure they pass

kill -STOP %1	# kill the server
fg 		# bring to foreground if it's not dead yet.
