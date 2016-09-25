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

var contract, logs;

$(document).ready(function() {
  contract = ChainPoint.at('0x4611c52fe74bbeb6274b9e9328c9d31e3b7ab54b');
  logs = contract.CheckPointAchieved({fromBlock: 'latest'});
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
  var account_devthomas = "0x87b3f6def4d451c41be733b8924da66dea0caed4";
  var account_bletchley = "0x708C77773a1c379aA70B0402Fa0dF12A9B00D76A";
  contract.check(id, user.Firstname, step, {from: account_bletchley}).then(function(tx) {
    // Transaction successful
    console.log("Transaction successful! " + tx);
  }).catch(function(e) {
    // Transaction failed
    console.log("Transaction failed:");
    console.dir(e);
  });
}
