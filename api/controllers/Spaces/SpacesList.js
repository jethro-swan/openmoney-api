const util = require('../../helpers/util.helper');
const async = require('async');
const db = require('../../helpers/db.helper');
const crypto = require('../../helpers/crypto.helper');

exports.spacesList = function (req, res, next) {
    /**
     * parameters expected in the args:
     * stewardname (String)
     * authorization (String)
     * parentNamespace (String)
     **/

    var examples = {};

    examples['application/json'] = "";

    var request = {};
    request.stewardname = req.swagger.params.stewardname.value;
    request.space_parent = req.swagger.params.parent_namespace.value;
    request.publicKey = req.user.publicKey;

    spacesList(request, function (err, result) {
        res.setHeader('Content-Type', 'application/json');
        if (err) {
            // throw error
            examples['application/json'] = err;
            res.statusCode = util.setStatus(err);
        } else {
            examples['application/json'] = result;
        }
        res.end(JSON.stringify(examples[Object.keys(examples)[0]] || {}, null, 2));
    });
}

const spacesList = function(request, spacesGetCallback){
    db.stewards_bucket.get("steward_bucket~" + crypto.getHash(request.publicKey), function(err,steward_bucket) {
        if(err) {
            spacesGetCallback(err, false);
        } else {
            var parallelTasks = {};
            steward_bucket.value.namespaces.forEach(function(spaceID){
                parallelTasks[spaceID] = function(callback) {
                    db.openmoney_bucket.get(spaceID,function(err,namespace){
                        if(err) {
                            callback(err, false);
                        } else {
                            callback(null,namespace.value);
                        }
                    })
                };
            });
            async.parallel(parallelTasks, function(err, results){
                if(err) {
                    spacesGetCallback(err, false);
                } else {
                    
                    var response = [];
                    for (var key in results) {
                        if (results.hasOwnProperty(key)) {
                            response.push(results[key]);
                        }
                    }
                    spacesGetCallback(null, response);
                }
            });
        }
    });

    //var N1qlQuery = couchbase.N1qlQuery;
    //db.stewards_bucket.enableN1ql(['http://127.0.0.1:8093/']);
    //var queryString = 'SELECT * FROM openmoney_stewards WHERE Meta().id like "' + crypto.getHash(request.publicKey) + 'spaces~%";';
    //var query = N1qlQuery.fromString(queryString);
    //db.stewards_bucket.query(query, function(err, results) {
    //    if (err) {
    //        spacesGetCallback(err,false);
    //    } else {
    //        var response = [];
    //        for(i in results) {
    //            response.push(results[i].openmoney_stewards);
    //        }
    //        spacesGetCallback(null, response);
    //    }
    //});

    //var query = couchbase.ViewQuery.from('dev_spaces', 'spaces');
    //db.stewards_bucket.query(query, function(err, results) {
    //    if (err) {
    //        spacesGetCallback(err,false);
    //    } else {
    //        var response = [];
    //        for(i in results) {
    //            response.push(results[i].value);
    //        }
    //        spacesGetCallback(null, response);
    //    }
    //});
};