# openmoney-api

The Openmoney API is a domain driven model of stewards, namespaces, currencies, accounts, and journals.
Stewards are the patrons of these namespaces, currencies, accounts and journals.

#Install

- Go to [couchbase downloads](http://www.couchbase.com/nosql-databases/downloads) and install the latest couchbase server.
- Change Administrator and password in export commands below for your couchbase server administrator credentials.

```sh

git clone https://github.com/deefactorial/openmoney-api.git
cd openmoney-api
export COUCHBASE_ADMIN_USERNAME=Administrator
export COUCHBASE_ADMIN_PASSWORD=password
npm install

```

#Run

```sh

npm start

```

#Test

```sh

mocha

```

#Documentation

http://127.0.0.1:8080/docs/
