How we populate the data in DynamoDB?

- API gateway endpoint `/populate` being called will trigger `startPopulatePokemonMessages` -  Invoke URL: https://ymy7qb54pc.execute-api.ap-southeast-2.amazonaws.com/dev/populate 
- This will publish an SNS topic - in this case the `populatePokemon` topic
- AWS? will *fan* the message out to subscribed endpoints. For us this is `populatePokemon` lambda
- That lambda will build and send messages to the queue - should be around 898 (this is how many pokemon there is)
- Each of these messages are picked up by the lambda and invoke `triggerPopulatePokemon` - This method is responsible for querying for a specific pokemon and storing it's data in dynamo


How do we retrieve data?
Calling `/pokemon` will allow the retrieval of all pokemon - filtering happens in the frontend.

Current endpoint
https://ymy7qb54pc.execute-api.ap-southeast-2.amazonaws.com/dev/pokemon

Decisions made:
There is a few chains of messages/queues. This was important to ensure that we not timing out in the lambda.

- there was something about batching with SQS/SNS - can't remember - My first approach for some reason only populated around 90 pokemon, not ~900.

I wanted to use SNS because I want to get better images and store them in S3, this will also trigger a lambda to retreive that info (with the image in the db being the fallback).

Things to consider/look into
- Do I need all of docker/SAM/Terraform? I want to use and learn them all.
- I want to be able to test locally - Looks like there is something called localstack - would this work (is this the best solution)
- Dead letter queue?
- there is a lambda, SQS queue, SNS topic that all have the same data - change it


Hints:
You can set the concurrency for a lambda to zero (or click Throttle) to ensure the lambda is not invoked - This could allow the message to remain on the queue for inspection.