const AWS = require('aws-sdk');
const sqs = new AWS.SQS({region: 'ap-southeast-2', apiVersion: '2012-11-05'});

exports.handler = async function(event, context, callback) {
    console.log(event);
    console.log(context);
    for (let i = 1; i <= process.env.POKEMON_COUNT; i++) {
        var params = {
            MessageBody: `${i}`,
            QueueUrl: process.env.SQS_QUEUE_URL,
        };
        console.log(i);
        await sqs.sendMessage(params).promise();
    }

    // const batchSize = 10;
    // var params = {
    //         QueueUrl: QUEUE_URL,
    //         Entries: []
    // };
    //
    // for (let i = 1; i <= POKEMON_COUNT; i++) {
    //     params.Entries.push({
    //         Id: `${i}`,
    //         MessageBody: `${i}`
    //       });
    //
    //     if (params.Entries.length === batchSize || i === POKEMON_COUNT) {
    //         await sqs.sendMessageBatch(params).promise();
    //         params.Entries = [];
    //     }
    // }

    var response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'text/html; charset=utf-8',
        },
        body: `Triggered populate for ${process.env.POKEMON_COUNT}!`,
    };
    callback(null, response);
};
