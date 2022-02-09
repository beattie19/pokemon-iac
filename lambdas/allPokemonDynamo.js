var AWS = require("aws-sdk");
const dynamoDB = new AWS.DynamoDB({ region: 'ap-southeast-2', apiVersion: '2012-08-10' });

exports.handler = (event, context, callback) => {
    var params = {
        TableName: "pokemon"
    };

    console.log("Scanning pokemon table.");
    
    return dynamoDB.scan(params, function(err, data) {
       if (err) console.log(err, err.stack); // an error occurred
       else {
           const items = data.Items.map((dataField) => {
                    console.log(dataField);
                    return {
                      name:  dataField.Name.S,
                      id: +dataField.id.N,
                      sprite: dataField.Sprite.S,
                      height: +dataField.Height.N,
                      weight: +dataField.Weight.N,
                      types: dataField.Types.SS,
                      baseStats: {
                        hp: +dataField.Hp.N,
                        attack: +dataField.Attack.N,
                        defense: +dataField.Defense.N,
                        specialAttack: +dataField.SpecialAttack.N,
                        specialDefense: +dataField.SpecialDefense.N,
                        speed: +dataField.Speed.N,
                      },
                    }
                });
                           console.log(items)
            callback(null, {
            statusCode: 200,
            body: items,
        });
       }
       });
}
// function onScan(err, data) {
//     if (err) {
//         console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
//     } else {
//         console.log("Scan succeeded.");
//         data.Items.forEach(function(movie) {
//           console.log(
//                 movie.year + ": ",
//                 movie.title, "- rating:", movie.info.rating);
//         });

//         // continue scanning if we have more movies, because
//         // scan can retrieve a maximum of 1MB of data
//         if (typeof data.LastEvaluatedKey != "undefined") {
//             console.log("Scanning for more...");
//             params.ExclusiveStartKey = data.LastEvaluatedKey;
//             dynamoDB.scan(params, onScan);
//         }
//     }
// }