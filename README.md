### PLEASE NOTE:  

The installation stopped working on Ubuntu 16.04.x and 18.04.x in January 2020, when Node 8 reached the end of its supported life.

As it is, it can still be installed on Ubuntu 19.10.

### openmoney-api

The Openmoney API is a domain driven model of stewards, namespaces, currencies, accounts, and journals.
Stewards are the patrons of these namespaces, currencies, accounts and journals.

### Install locally

Copy
  ~/om-api.config.example
to
  ~/om-api.config
then edit
  ~/om-api.config
to provide appropriate values.

```sh
git clone https://github.com/jethro-swan/openmoney-api
cd openmoney-api
cp om-api.config.example om-api.config
vi om-api.config
./install.sh
```

### Run locally on port 8080
```sh
npm run start
#Control-C to quit
```

### Run in a background service
```sh
sudo npm install pm2 -g
pm2 start app.js --name "openmoney-api"
```

### Test
```sh
#ensure the server is running locally or in background then run
npm run test
```

### Local Documentation
http://localhost:8080/docs/

### Remote Documentation
https://cloud.openmoney.cc/docs/

### Uninstall database
```sh
./uninstalldb.sh
```
### Re-install empty database
```sh
./reinstalldb.sh
```

### License

Copyright [2019] [Dominique Legault]

Minor revisions:

  2019/11/03 John Waters
  
  2020/01/04 John Waters
  
  2020/03/12 John Waters

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
