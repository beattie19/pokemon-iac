console.log("Loading function");
var AWS = require("aws-sdk");
var sns = new AWS.SNS();

exports.handler = function(event, context) {
    var params = {
        Message: "Create SQS messages for pokemon data", 
        Subject: "Start populating pokemon SQS messages",
        TopicArn: "arn:aws:sns:ap-southeast-2:784557455711:populatePokemon"
    };
    sns.publish(params, context.done);
};