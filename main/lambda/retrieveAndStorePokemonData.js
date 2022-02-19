const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({ region: 'ap-southeast-2', apiVersion: '2012-08-10' });
const QUEUE_URL = 'https://sqs.ap-southeast-2.amazonaws.com/784557455711/populate-pokemon';
const https = require('https');

exports.handler = async (event, context) => {
    console.log('records', event.Records);
    var pokemonNumber = event.Records[0].body;

    console.log('event', event);
    console.log('nimner', pokemonNumber);
    const pokemonPromise = new Promise((resolve, reject) => {
        const options = {
            hostname: `pokeapi.co`,
            path: `/api/v2/pokemon/${pokemonNumber}/`,
            method: 'GET',
            headers: {
                "content-type": "application/json"
            }
        };

        const req = https.request(options, (res) => {

            var body = [];
            res.on('data', function (chunk) {
                body.push(chunk);
            });
            res.on('end', function () {
                try {
                    body = Buffer.concat(body);
                } catch (e) {
                    reject(e);
                }
                resolve(body);
            });

        });

        req.end();
    });

    await pokemonPromise.then((data) => {
        console.log('first then');
        return Buffer.from(data).toString();

    }).then(async (data) => {
        const object = JSON.parse(data);

        const getTypes = (types) => {
            return types.map(({type}) => type.name);
        };

        const params = {
            Item: {
                "PokemonId": {
                    N: `${object.id}`
                },
                "Name": {
                    S: object.name
                },
                "Height": {
                    N: `${object.height}`
                },
                "Weight": {
                    N: `${object.weight}`
                },
                "Sprite": {
                    S: object.sprites.front_default
                },
                "Types": {
                    SS: getTypes(object.types)
                },
                "Hp": {
                    N: `${object.stats[0].base_stat}`
                },
                "Attack": {
                    N: `${object.stats[1].base_stat}`
                },
                "Defense": {
                    N: `${object.stats[2].base_stat}`
                },
                "SpecialAttack": {
                    N: `${object.stats[3].base_stat}`
                },
                "SpecialDefense": {
                    N: `${object.stats[4].base_stat}`
                },
                "Speed": {
                    N: `${object.stats[5].base_stat}`
                }
            },
            TableName: "pokemon-data",
            ReturnConsumedCapacity: 'TOTAL'
        };

        console.log('data', data);
        var result = await dynamoDB.putItem(params).promise();
    });
}

