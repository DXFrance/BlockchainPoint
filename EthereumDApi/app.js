var express     = require('express');
var app         = express();

var server = require('http').Server(app);
var io = require('socket.io')(server);

var bodyParser  = require('body-parser');
var fs = require('fs');
var pdf = require('html-pdf');
var ejs = require('ejs');
var html = fs.readFileSync('pdf.html', 'utf-8');
var registered = JSON.parse(fs.readFileSync('registered.json'));

app.set('view engine', 'ejs');
app.use(express.static('public'));

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Ocp-Apim-Subscription-Key");
  next();
});

app.use(bodyParser());
app.use( bodyParser.json({limit: '50mb'}) );
app.use(bodyParser.urlencoded({
  limit: '50mb',
  extended: true,
  parameterLimit:50000
}));

app.post('/auth', function(req, res){
  var id = req.body.id;
  for (var i = 0, len = registered.length; i < len; i++) {
    var ids = registered[i].Badge.split('/');
    console.log(id, ids[ids.length - 1]);
    if (ids[ids.length - 1] == id) {
      console.log('MATCH');
      return res.json(registered[i]);
    }
  }

  return res.json({error: true});
});

app.post('/pdf', function(req, res) {
  var user = req.body.user;
  var ids = user.Badge.split('/');
  var id = ids[ids.length - 1];

  var exist = statPath('public/' + id + '.pdf');
  if(exist && exist.isFile()) {
    var html_data = ejs.render(html, { firstname: user.Firstname, lastname: user.Lastname });
    pdf.create(html_data, {format: 'Letter'}).toFile('public/' + id + '.pdf', function(err, response) {
      res.send('http://localhost:1996/' + id + '.pdf');
    });
  } else {
    res.send('http://localhost:1996/' + id + '.pdf');
  }
});

// Blockchain events

var ChainPoint = require('./ChainPoint.sol.js');
var Web3 = require('web3');

var abi = ChainPoint.all_networks[112358].abi;
var address = ChainPoint.all_networks[112358].address;

var web3 = new Web3(new Web3.providers.HttpProvider("http://tconte4kv.northeurope.cloudapp.azure.com:8545"));

var contract = web3.eth.contract(abi).at(address);

var logs = contract.JourneyAchieved({fromBlock: 'latest'});
logs.watch(function(error, result) {
  console.log("Journey Achieved!");
  console.log(result.args.userid);
  console.log(result.args.username);
});

// Run server

server.listen(1996);

function statPath(path) {
  try {
    return fs.statSync(path);
  } catch (ex) {}
  return false;
}

io.on('connection', function (socket) {
  console.log('new client');
});
