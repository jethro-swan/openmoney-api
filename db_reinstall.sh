#!/bin/bash
#installation script
#
# (1) run  ./set-constants -u <API URL> -m <admin email> -N <root namespace> -C <root currency>
# (2) run  ./install.sh

source includes/wait_progress_bar.sh

#Setting script variables.
source ./.env # retrieve values created using set-constants.sh

#run the docker container
sudo docker run -dit --restart unless-stopped -d --name db \
    -p 8091-8094:8091-8094 -p 11210:11210 couchbase:community-6.5.0
#
#Wait for it
sleep 30s
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
sleep 40s
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
