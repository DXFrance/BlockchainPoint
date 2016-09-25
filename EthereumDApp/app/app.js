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
    $('.pdf').fadeIn();
    $('.loader').fadeOut(function() {
      $('.anonymous').fadeOut();
      $('.well').css('display', 'block').addClass('animated flipInX').text('Welcome ' + user.Firstname + ' ' + user.Lastname + ' | ' + user.Mail + ' from ' + user.Pays);
    });

    // Send to blockchain
    sendToBlockchain(id, user, 1);

    // Release lock
    http = false;
  });
}, function() {
  // No QR code detected 
}, function() {
  // Error
});

$('.pdf-link').click(function() {
  $.post('http://localhost:1996/pdf', {user: user}, function(data) {
    console.log(data);
    alert(data);
  });
});

var contract;

$(document).ready(function() {
  contract = ChainPoint.deployed();
  var logs = contract.CheckPointAchieved({fromBlock: "latest"});
  logs.watch(function(error, result) {
    console.log("CheckPoint!");
    console.log(result.args.userid);
    console.log(result.args.username);
    console.log(result.args.step.toString());
  });
});

// Send transaction to blockchain

function sendToBlockchain(id, user, step) {
  var account_testrpc = "0x27cf95ea11d12ae58f4ab9e1dbe568eae9294ccf";
  var account_production = "0xa4cc9db2ac66daf6b3a99f7064fa6d3e598cb7e8";
  contract.check(id, user.Firstname, step, {from: account_testrpc, gas:1000000}).then(function(tx) {
    // Transaction successful
    console.log("Transaction successful! " + tx);
  }).catch(function(e) {
    // Transaction failed
    console.log("Transaction failed:");
    console.dir(e);
  });
}
