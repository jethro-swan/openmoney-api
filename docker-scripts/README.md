### Assumptions

A collection of scripts to work with the Dockerized version of Couchbase (6.x.x)
used with this version of the Open Money API.

It is assumed that the Open Money components are running together within a
virtual machine and that no other Docker container is running.

### Preparation

It is assumed that 
- the OM code (including the Dockerized Couchbase) is isolated within a VM 
- the only non-root user is "om"
- user "om" has passwordless sudo access

(1) Create backup directory in OM's root directory:
```
cd
mkdir backups
```
(2) Enter Couchbase's Docker container ...

```
cd ~/openmoney-api/docker-scripts
./docker-bash
```
... and the create the _/backup_ directory ...

```
root@<container ID>:/# mkdir backup
root@<container ID>:/# exit
```

(3) Shorten absolute path to script
```
cd
ln -s openmoney-api/docker-scripts .
```
(this is just to make the _crontab_ entry more readable)

(4) Set up cron job
```
cd
openmoney-api/docker-scripts/cron-setup
```
