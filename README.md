### PLEASE NOTE:  

The installation stopped working on Ubuntu 16.04.x and 18.04.x in January 2020, when Node 8 reached the end of its supported life.

As it is, it can still be installed on Ubuntu 19.10.

### openmoney-api

The Openmoney API is a domain driven model of stewards, namespaces, currencies, accounts, and journals.
Stewards are the patrons of these namespaces, currencies, accounts and journals.

### Install locally

```sh
git clone https://github.com/jethro-swan/openmoney-api
cd openmoney-api
```
Set initial values:

./set-constants -u &lt;API URL&gt; -m &lt;admin email&gt; [-N &lt;root namespace&gt;] [-C &lt;root currency&gt;]
e.g.
```sh
./set-constants -u om-instance.somewhere.cc -m adi.minster@somewhere.cc
```
or
```sh
./set-constants -u om-instance.somewhere.cc -m adi.minster@somewhere.cc -N ca -C hours
```
then run the installation script:
```sh
./install.sh
```
NB, this will generate passwords automatically for the Couchbase  adminstrator and the network adminstrator. These can then be found in the .env file.


### Run locally on port 8080
```sh
npm run start
```
Control-C to quit

### Run in a background service
```sh
sudo npm install pm2 -g
pm2 start app.js --name "openmoney-api"
```

### Test

Ensure the server is running locally or in background then run
```sh
npm run test
```

### Local documentation
http://localhost:8080/docs/

Currently all example cURL strings generated point to the remote site https://cloud.openmoney.cc rather than to the local instance. This problem will be addressed in due course.

### Remote documentation
https://cloud.openmoney.cc/docs/

### Uninstall database and re-install

If re-installation becomes necessary, first uninstall the database:

```sh
./uninstalldb.sh
```

The following script duplicates the essential later stages of install.sh, omitting the Node and Docker installation, etc.
It is used to re-populate that initial database after it has been cleared using uninstalldb.sh (which was previously named uninstall.sh).

```sh
./reinstalldb.sh
```

### License

Copyright [2019] [Dominique Legault]

Minor revisions: 2019/11/03 - 2020/03/21 John Waters

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
