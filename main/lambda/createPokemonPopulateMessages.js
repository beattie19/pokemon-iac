const AWS = require('aws-sdk');
const sqs = new AWS.SQS({region: 'ap-southeast-2', apiVersion: '2012-11-05'});
const QUEUE_URL = 'https://sqs.ap-southeast-2.amazonaws.com/784557455711/populate-pokemon';
const POKEMON_COUNT = 5;

exports.handler = async function(event, context, callback) {
    for (let i = 1; i <= POKEMON_COUNT; i++) {
        var params = {
            MessageBody: `${i}`,
            QueueUrl: QUEUE_URL
        };
        console.log(i);
        await sqs.sendMessage(params).promise();

    }

    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: `Triggered populate for ${POKEMON_COUNT}!`,
    };
    callback(null, response);
};