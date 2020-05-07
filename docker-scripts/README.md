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

- list_backups
  Used to list the available backups within the Docker container.
  Each backup file is named with a date-/time-stamp (YYYYMMDDhhmm), e.g.
    202005061400

- couchbase_restore
  Used to restore Couchbase to an available saved state, e.g.
    
    ~/openmoney-api/docker-scripts/couchbase_restore 202005061400

- couchbase_backup
  Used by the Couchbase backup cron task.

- create_backup_system
  Create the backup directors and set up the cron task.

- docker-bash
  Open BASH inside the Couchbase Docker container.

- couchbase_stop
  Used to stop the Couchbase server safely, e.g. before rebooting the VM. 

- couchbase_start
  Used to start the Couchbase server, e.g. after rebooting the VM. 

- cron-setup
  [An obsolete script since incorporated into _create_backup_system_]
