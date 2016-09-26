if (localStorage.getItem("machine_id") === null) {
  var machine_id = prompt('ID de la machine');
  localStorage.setItem('machine_id', machine_id);
} else {
  var machine_id = localStorage.getItem("machine_id");
}


var http = false;
var user = null;
$('#reader').html5_qrcode(function(data){
  // QR code detected

  // Return if locked
  if (http) {
    return;
  }

  $('.loader').fadeIn();
  console.log('Getting user GUID');

  // Lock
  http = true;

  // Extract data
  var ids = data.split('/');
  var id = ids[ids.length - 1];
  console.log('GUID : ' + id);

  // Retrieve user name
  $.post('http://localhost:1996/auth', {id: id}, function(data) {
    if (data.error) {
      alert('Error');
      http = false;
      $('.loader').fadeOut();
      return;
    }
    console.log(data);
    user = data;
    $('.loader').fadeOut(function() {
      $('.anonymous').fadeOut();
      $('.well').css('display', 'block').addClass('animated flipInX').text('Welcome ' + user.firstname + ' ' + user.lastname + ' | ' + user.mail + ' from ' + user.country.value);
    });

    // Send to blockchain
    sendToBlockchain(id, user, machine_id);

    // Release lock
    http = false;
  });
}, function() {
  // No QR code detected
}, function() {
  // Error
});

var contract, logs;

$(document).ready(function() {
  contract = ChainPoint.at('0x39f0a2ec78069eb5f37934d59c85c8c584778157');
  logs = contract.CheckPointAchieved({fromBlock: 'latest'});
  logs.watch(function(error, result) {
    console.log("CheckPoint!");
    console.log(result.args.userid);
    console.log(result.args.username);
    console.log(result.args.step.toString());
    DOM_pushCheckpointDone(result.args.username, result.args.step.toString());
    socket.emit('checkpoint_mined', {username: result.args.username, step: result.args.step.toString()});
  });
});

// Send transaction to blockchain

function sendToBlockchain(id, user, step) {
  var account_testrpc = "0x9de967378ed802b954e3be289cc5d598021c7ffe";
  var account_production = "0xa4cc9db2ac66daf6b3a99f7064fa6d3e598cb7e8";
  var account_devthomas = "0x87b3f6def4d451c41be733b8924da66dea0caed4";
  var account_bletchley = "0x708C77773a1c379aA70B0402Fa0dF12A9B00D76A";
  contract.check(id, user.firstname, step, {from: account_testrpc}).then(function(tx) {
    DOM_pushCheckpoint(user.firstname, step);
    socket.emit('checkpoint_begin', {username: user.firstname, step: step});
    console.log("Transaction successful! " + tx);
  }).catch(function(e) {
    // Transaction failed
    console.log("Transaction failed:");
    console.dir(e);
  });
}

function DOM_pushCheckpoint(firstname, step) {
  $('.table-checkpoints').find('tbody').append('<tr><td>#' + firstname + ' - <i class="fa fa-clock-o"></i> Checkpoint #' + step + ' - En cours de minage ...</td></tr>');
}

function DOM_pushCheckpointDone(firstname, step) {
  $('.table-checkpoints').find('tbody').append('<tr><td>#' + firstname + ' - <i class="fa fa-check"></i> Checkpoint #' + step + ' - Miné !</td></tr>');
}

function DOM_pushCertification(firstname, pdf) {
  $('.table-certifs').find('tbody').append('<tr><td>' + firstname + ' - <i class="fa fa-user"></i> Certifiée - <a href="'+ pdf +'" target="_blank" title="Certification">'+ pdf +'</a></td></tr>');
}

var socket = io.connect('http://localhost:1996');
socket.on('user_complete', function(users_complete) {
  for (var i = 0, len = users_complete.length; i < len; i++) {
    DOM_pushCertification(users_complete[i].username, users_complete[i].pdf);
  }
});

socket.on('user_complete_new', function(user_complete) {
  DOM_pushCertification(user_complete.username, user_complete.pdf);
});

socket.on('checkpoint_begin', function(user_checkpoint) {
  DOM_pushCheckpoint(user_checkpoint.username, user_checkpoint.step);
});

socket.on('checkpoint_mined', function(user_checkpoint) {
  DOM_pushCheckpointDone(user_checkpoint.username, user_checkpoint.step);
});
