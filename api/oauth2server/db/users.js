var couchbase = require('couchbase'),
    cluster = new couchbase.Cluster('couchbase://' + process.env.COUCHBASE_LO),
    openmoney_bucket = cluster.openBucket('openmoney_global');


//var users = [
//    { id: '1', username: 'bob', password: 'secret', name: 'Bob Smith' },
//    { id: '2', username: 'joe', password: 'password', name: 'Joe Davis' }
//];

exports.findByUsername = function(username, callback) {
  openmoney_bucket.get("stewards~" + username.toLowerCase(), function(err, user){
    if(err){
      if(err.code == 13){
        callback(null, null);
      } else {
        callback(err, null);
      }
    } else {
      callback(null, user.value);
    }
  });
  //for (var i = 0, len = users.length; i < len; i++) {
  //  var user = users[i];
  //  if (user.username === username) {
  //    return done(null, user);
  //  }
  //}
  //return done(null, null);
};

exports.find = function(id, done) {
    id = id.replace('stewards~', '');
  exports.findByUsername(id, done);
  //for (var i = 0, len = users.length; i < len; i++) {
  //  var user = users[i];
  //  if (user.id === id) {
  //    return done(null, user);
  //  }
  //}
  //return done(null, null);
};
