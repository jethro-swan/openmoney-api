### Assumptions

A collection of scripts to work with the Dockerized version of Couchbase (6.x.x)
used with this version of the Open Money API.

It is assumed that the Open Money components are running together within a
virtual machine and that no other Docker container is running.

It is also assumed that 
- the OM code (including the Dockerized Couchbase) is isolated within a VM 
- the only non-root user is "om"
- user "om" has passwordless sudo access


The scripts are:

- **list_backups** is used to list the backup archives currently available within the Docker container.
  Each backup file is named with a date-/time-stamp (YYYYMMDDhhmm), e.g.
    202005061400

- **couchbase_restore** is used to restore Couchbase to an available saved state, e.g.
    
    ~/openmoney-api/docker-scripts/couchbase_restore 202005061400

- **couchbase_backup** is used by the Couchbase backup _cron_ task.

- **create_backup_system** is used to create the backup directories and set up the _cron_ task.

- **docker-bash** is used to open a BASH terminal inside the Couchbase Docker container.

- **couchbase_stop** is used to stop the Couchbase server safely, e.g. before rebooting the VM. 

- **couchbase_start** is used to start the Couchbase server, e.g. after rebooting the VM. 

- **cron-setup** is an obsolete script since incorporated into _create_backup_system_
