
A collection of scripts to work with the Dockerized version of Couchbase (2.2.0)
used with this version of the Open Money API.

It is assumed that the Open Money components are running together within a
virtual machine and that no other Docker container is running.

##Preparation

It is assumed that 
- the OM code is isolated within a VM 
- the only non-root user is "om"
- user "om" has passwordless sudo access

(1) Create backup directory
```
cd
mkdir backup

ln -s openmoney-api/docker-scripts .
```

(2) Set up cron job

Copy/paste line from
    openmoney-api/docker-scripts/example.crontab
