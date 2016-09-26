var express     = require('express');
var app         = express();
var fs = require('fs');
var server = require('http').Server(app);
var io = require('socket.io')(server);
var certified = JSON.parse(fs.readFileSync('certified.json'));
var bodyParser  = require('body-parser');
var pdf = require('html-pdf');
var ejs = require('ejs');
var html = fs.readFileSync('pdf.html', 'utf-8');
var config = require('./config');
var token;
var request = require('sync-request');
var user_complete = certified;
var oauth2 = require('simple-oauth2').create({
  client: {
    id: config.client_id,
    secret: config.client_secret
  },
  auth: {
    tokenHost: config.host,
    tokenPath: config.token_url,
    authorizePath: config.auth_url
  }
});

oauth2.clientCredentials.getToken({scope: config.scope}, (error, result) => {
  if (error) {
    return console.log('Access Token Error', error.message);
  }
  token = oauth2.accessToken.create(result).token.access_token;
  console.log('Token : ' + token);
  setUpBlockChainWatch();
});

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

  return res.json(getUser(id));
});

// Blockchain events

var ChainPoint = require('./ChainPoint.sol.js');
var Web3 = require('web3');

var abi = ChainPoint.all_networks['default'].abi;
var address = "0x39f0a2ec78069eb5f37934d59c85c8c584778157";

var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

var contract = web3.eth.contract(abi).at(address);

// Run server

server.listen(1996);

function statPath(path) {
  try {
    return fs.statSync(path);
  } catch (ex) {}
  return false;
}

io.on('connection', function (socket) {
  socket.emit('user_complete', user_complete);
  socket.on('checkpoint_begin', function(data) {
    socket.broadcast.emit('checkpoint_begin', data);
    console.log('checkpoint_begin');
  });
  socket.on('checkpoint_mined', function(data) {
    socket.broadcast.emit('checkpoint_mined', data);
    console.log('checkpoint_mined');
  });
});

function getUser(id) {
  var user = request('GET', 'https://api.inwink.com/' + config.event_id + '/registered/' + id, {
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token
      }
  });
  user = JSON.parse(user.getBody('utf8'));

  return user;
}

function createLink(link) {
  var bitly = request('GET', 'https://api-ssl.bitly.com/v3/user/link_save?access_token=8e21360de7ecca4648c3f588b5919c15ea7dde63&longUrl='+link);

  bitly = JSON.parse(bitly.getBody('utf8')).data.link_save.link;
  return bitly;
}

function setUpBlockChainWatch() {
  var logs = contract.JourneyAchieved({fromBlock: 'latest'});

  logs.watch(function(error, result) {
    if (typeof result === 'undefined') {
      return;
    }
    for (var i = 0, len = user_complete.length; i < len; i++) {
      if (user_complete[i].id == result.args.userid) {
        //User already have a certification
        return;
      }
    }
    console.log("Journey Achieved!");
    console.log(result.args.userid);
    console.log(result.args.username);
    var user = getUser(result.args.userid);
    var html_data = ejs.render(html, { firstname: user.firstname, lastname: user.lastname });
    pdf.create(html_data, {format: 'Letter'}).toFile('public/' + result.args.userid + '.pdf', function(err, response) {
      var user_complete_new = {id: result.args.userid, username: result.args.username, pdf: createLink('http://127.0.0.1:1996/' + result.args.userid + '.pdf')};
      user_complete.push(user_complete_new);
      fs.writeFile('certified.json', JSON.stringify(user_complete), 'utf8');
      io.sockets.emit('user_complete_new', user_complete_new);
    });
  });
}
