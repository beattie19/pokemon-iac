## What is this?
This is a toy project set up for the purpose of learning Terraform and becoming more comfortable with some AWS services.

The initial idea was to:
    - have the ability to trigger an api gateway endpoint to populate a dynamo database with via a lambda
    - be able to retrieve stored data through api gateway endpoint

## Usage
### Terraform
I am using [aws-vault](https://github.com/99designs/aws-vault) as a way interact with AWS
- create tfvars file and supply all values
- first run will require `terraform init` to download dependancies
- (optional) `aws-vault exec {profile name} -- terraform plan -var-file="{choose name}.tfvars"` to create execution plan and review expected changes
- `aws-vault exec {profile name} -- terraform apply -var-file="{choose name}.tfvars"` to execute the plan and create resources in AWS
- `aws-vault exec beattie19 -- terraform destroy -var-file="dev.tfvars"` when finished to remove resources from AWS

### Application
Once the `terraform apply` is successful there should be some outputs on the cli
- `/populate` - Path to populate database with Pokemon data
- `/all-pokemon` - Path retrieve all Pokemon data

## TODO
### Docs
- Create a better usage section
- Add screenshots from Miro

### Code
- Create tfvars template so we know what needs to be set for this to work
- Come up with a new solution that won't take down the database on destroy
- Pass SQS queue into the lambda event so it's not hard coded
- Allow the custom domain to code to be optional - don't want to require certificates etc when testing (or if someone else wants to use this)
- Improve lambda for creating messages (may currently timeout) - may want a lambda that triggers a lambda.
- Some duplication in API Gateway, consider creating a module.

### Potential things to try
- It would be good to be able to test locally
    - could localstack work for my usecase?
- Should I consider SAM for the lambda/api gateway instead?
- Can docker fit into this in anyway
- Add testing
  - terratest?
- Consider CI/CD? - could have build steps for testing

## How we populate the data in DynamoDB?
- Hit the `/populate` endpoint
- Trigger lambda to create SQS messages for each pokemon
- Each message is picked up by a lambda which reached out to the pokemon api and populates dynamo

## Useful tips:
You can set the concurrency for a lambda to zero (or click Throttle) to ensure the lambda is not invoked - This could allow the message to remain on the queue for inspection.
