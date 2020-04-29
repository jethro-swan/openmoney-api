#!/bin/bash
# installation script
#
# ./setup.sh -u <API URL> -a <admin email> [-N <root namespace>] [-C <root currency>]

usage()
{
    echo
    echo "usage: setup.sh -u <API URL>"
    echo "                -a <admin email>"
    echo "                [-N <root namespace>]"
    echo "                    root namespace"
    echo "                    - from 2 to 20 lower case alphanumeric characters"
    echo "                    - first character must be letter"
    echo "                    (default = 'cc')"
    echo "                [-C <root currency>]"
    echo "                    root currency"
    echo "                    - from 1 to 5 lower case alphanumeric characters"
    echo "                    - first character must be letter"
    echo "                    (default = 'cc')"
    echo "                [-h] show help"
    echo
}

URL_RE='^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
EMAIL_RE='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'
NAMESPACE_RE='^[a-z]{1,20}$'
CURRENCY_RE='^[a-z]{1,5}$'

# default values
ROOT_NAMESPACE=cc
ROOT_CURRENCY=cc

# Temporary fix (2020/04/29) to substitute docker.io for docker-ce (which Ubuntu 20.04 lacks at this point)
UV=$(lsb_release -r -s)
re20="^20\.(04|10)(\.\d)?$"
#if [[ $UV =~ "20.04" ]]; then
if [[ $UV =~ $re20 ]]; then
    DOCKER_VERSION="docker.io"
else
    DOCKER_VERSION="docker-ce"
fi
echo "This is Ubuntu $UV therefore using docker.io instead of docker-ce"



while [ -n "$(echo $1 | grep '^-[uaNCh]$')" ]; do
    case $1 in
        -u ) if [[ $2 =~ $URL_RE ]]; then
                 API_URL=$2
                 shift
             else
                 echo "API URL format is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -a ) if [[ $2 =~ $EMAIL_RE ]]; then
                 ADMIN_EMAIL=$2
                 shift
             else
                 echo "Admin email address format is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -N ) if [ -z $2 ]; then
                 ROOT_NAMESPACE=cc # default
                 shift
             elif [[ $2 =~ $NAMESPACE_RE ]]; then
                 ROOT_NAMESPACE=$2
                 shift
             else
                 echo "Root namespace is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -C ) if [ -z $2 ]; then
                 ROOT_CURRENCY=cc # default
                 shift
             elif [[ $2 =~ $CURRENCY_RE ]]; then
                 ROOT_CURRENCY=$2
                 shift
             else
                 echo "Root currency is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -h ) usage
             exit 1
             ;;
        * )  echo "Unrecognized option"
	     usage
             exit 1
    esac
    shift
done

if [ -z $API_URL ]; then
    echo "You must specify a valid URL for the API"
    usage
    exit 1
fi

if [ -z $ADMIN_EMAIL ]; then
    echo "You must specify a valid email address for the administrator"
    usage
    exit 1
fi

# Replace all occurrences of "cloud.openmoney.cc" with OM API URL:
sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/swagger/swagger.yaml
sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/swagger/swagger.json
sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/oauth2server/db/clients.js

# Set non-default root currency and/or root namespace:
#cp includes/om-api.config.example om-api.config
#sed -i "s/admin@example\.net/$ADMIN_EMAIL/" om-api.config
#sed -i "s/ROOT_SPACE=cc/ROOT_SPACE=$ROOT_NAMESPACE/" om-api.config
#sed -i "s/ROOT_CURRENCY=cc/ROOT_CURRENCY=$ROOT_CURRENCY/" om-api.config

#source includes/wait_progress_bar.sh

#Setting script variables.
#source om-api.config
COUCHBASE_ADMIN_USERNAME=admin
echo "COUCHBASE_ADMIN_USERNAME=$COUCHBASE_ADMIN_USERNAME" > ./.env
COUCHBASE_ADMIN_PASSWORD=$(apg -a 0 -m 16 -n 1)
echo "COUCHBASE_ADMIN_PASSWORD=$COUCHBASE_ADMIN_PASSWORD" >> ./.env
COUCHBASE_LO=127.0.0.1
echo "COUCHBASE_LO=$COUCHBASE_LO" >> ./.env
ADMIN_USERNAME=admin
echo "ADMIN_USERNAME=$ADMIN_USERNAME" >> ./.env
ADMIN_PASSWORD=$(apg -a 0 -m 16 -n 1)
echo "ADMIN_PASSWORD=$ADMIN_PASSWORD" >> ./.env
ADMIN_EMAIL=$ADMIN_EMAIL
echo "ADMIN_EMAIL=$ADMIN_EMAIL" >> ./.env
ROOT_SPACE=$ROOT_SPACE
echo "ROOT_SPACE=$ROOT_NAMESPACE" >> ./.env
ROOT_CURRENCY=$ROOT_CURRENCY
echo "ROOT_CURRENCY=$ROOT_CURRENCY" >> ./.env
SMTP_CONFIG=smtp://localhost:25
echo "SMTP_CONFIG=$SMTP_CONFIG" >> ./.env
COUCHBASE_IP=`hostname -I | awk 'NR==1{print $1}'`
echo "COUCHBASE_IP=$COUCHBASE_IP" >> ./.env
cat ./.env # output the status of script variables so you know what your values are
echo $COUCHBASE_ADMIN_PASSWORD > ./docker-scripts/cbap

#install dependency applications
sudo apt-get update
sudo apt-get install -y npm net-tools apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt install apg
# Temporary fix (2020/04/29) to substitute docker.io for docker-ce if Ubuntu 20.04
sudo apt-get install -y $DOCKER_VERSION
#sudo apt-get install -y docker-ce
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt-get install -y nodejs
sudo npm install -g n
sudo n 10.19.0
# NOTE: https://github.com/barrysteyn/node-scrypt/issues/193
# is preventing upgrade to node v12
# solution is to change implementation to native crypto module in node
#
#pull the couchbase database docker container
sudo docker pull couchbase:community-6.5.0
#
#run the docker container
sudo docker run -dit --restart unless-stopped -d --name db \
    -p 8091-8094:8091-8094 -p 11210:11210 couchbase:community-6.5.0
#
#Wait for it
sleep 40s
#
#setup the couchbase server installation and buckets
curl -f -w '\n%{http_code}\n' \
    -X POST http://localhost:8091/nodes/self/controller/settings \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata'
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
curl -b /tmp/cookie \
    -w '\n%{http_code}\n' 'http://localhost:8091/pools/default/buckets' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'invalid-auth-response: on' \
    -H 'Cache-Control: no-cache' \
    -H 'Pragma: no-cache' \
    -H 'ns-server-ui: yes' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    -H 'Origin: http://localhost:8091' \
    -H 'Connection: keep-alive' \
    -H 'Referer: http://localhost:8091/ui/index.html' \
    --data 'authType=sasl&autoCompactionDefined=false&bucketType=membase&evictionPolicy=fullEviction&flushEnabled=0&name=default&ramQuotaMB=512&replicaIndex=0&replicaNumber=0&saslPassword=&threadsNumber=3'
curl -b /tmp/cookie \
    -w '\n%{http_code}\n' 'http://localhost:8091/pools/default/buckets' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'invalid-auth-response: on' \
    -H 'Cache-Control: no-cache' \
    -H 'Pragma: no-cache' \
    -H 'ns-server-ui: yes' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    -H 'Origin: http://localhost:8091' \
    -H 'Connection: keep-alive' \
    -H 'Referer: http://localhost:8091/ui/index.html' \
    --data 'authType=sasl&autoCompactionDefined=false&bucketType=membase&evictionPolicy=fullEviction&flushEnabled=0&name=oauth2Server&ramQuotaMB=512&replicaIndex=0&replicaNumber=0&saslPassword=&threadsNumber=3'
curl -b /tmp/cookie \
    -w '\n%{http_code}\n' 'http://localhost:8091/pools/default/buckets' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'invalid-auth-response: on' \
    -H 'Cache-Control: no-cache' \
    -H 'Pragma: no-cache' \
    -H 'ns-server-ui: yes' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    -H 'Origin: http://localhost:8091' \
    -H 'Connection: keep-alive' \
    -H 'Referer: http://localhost:8091/ui/index.html' \
    --data 'authType=sasl&autoCompactionDefined=false&bucketType=membase&evictionPolicy=fullEviction&flushEnabled=0&name=openmoney_global&ramQuotaMB=512&replicaIndex=0&replicaNumber=0&saslPassword=&threadsNumber=3'
curl -b /tmp/cookie \
    -w '\n%{http_code}\n' 'http://localhost:8091/pools/default/buckets' \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed \
    -H 'invalid-auth-response: on' \
    -H 'Cache-Control: no-cache' \
    -H 'Pragma: no-cache' \
    -H 'ns-server-ui: yes' \
    -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
    -H 'Origin: http://localhost:8091' \
    -H 'Connection: keep-alive' \
    -H 'Referer: http://localhost:8091/ui/index.html' \
    --data 'authType=sasl&autoCompactionDefined=false&bucketType=membase&evictionPolicy=fullEviction&flushEnabled=0&name=openmoney_stewards&ramQuotaMB=512&replicaIndex=0&replicaNumber=0&saslPassword=&threadsNumber=3'
#
#wait for it
sleep 50s
#
#verify installation was correct
sudo docker run couchbase:community-6.5.0 /bin/sh \
    -c "cd /opt/couchbase/bin; couchbase-cli bucket-list -c ${COUCHBASE_IP} -u ${COUCHBASE_ADMIN_USERNAME} -p ${COUCHBASE_ADMIN_PASSWORD} -d"
#
#install dependencies
npm install
#
#install seed data into couchbase server buckets
npm run install:db
#
#start the server and run in the foreground
npm run start &
#
#wait for it
sleep 20s
#
#run the tests and make sure they pass
npm run test
#
#kill the server
kill -STOP %1
#bring to foreground it it's not dead yet.
fg

echo
echo "====================================================================="
echo "API URL        = $API_URL"
echo "admin email    = $ADMIN_EMAIL"
echo "admin password = $ADMIN_PASSWORD"
echo "root namespace = $ROOT_NAMESPACE"
echo "root currency  = $ROOT_CURRENCY"
echo "====================================================================="
