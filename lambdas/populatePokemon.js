const AWS = require('aws-sdk');
var sqs = new AWS.SQS({region: 'ap-southeast-2', apiVersion: '2012-11-05'});
var QUEUE_URL = 'https://sqs.ap-southeast-2.amazonaws.com/784557455711/populatePokemon';

exports.handler = async (event, context) => {

  for (let i = 1; i <= 898; i++) {
    var params = {
      MessageBody: `${i}`,
      QueueUrl: QUEUE_URL
    };
    console.log(i);
    await sqs.sendMessage(params).promise();
    
    //     await sqs.sendMessage(params, function(err,data){
    //   if(err) {
    //     console.log('error:',"Fail Send Message" + err);
    //     context.done('error', "ERROR Put SQS");  // ERROR with message
    //   }else{
    //     console.log('data:',data.MessageId);
    //     context.done(null,'suc');  // SUCCESS
    //   }
    // }).promise();
  }
};
