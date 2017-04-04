# Kinesis Streams on Ruby
Simplified/enhanced sketch of https://github.com/awslabs/amazon-kinesis-client-ruby/ with local setup to run with Kinesalite and Local DynamoDB

## Running locally
`Bundle install`

First run `local-setup.sh` to start local Kinesis and DynamoDB

To kick off the sample producer, run `sample_kcl_producer.rb`

To run the sample consumer, run `rake 'kinesis:run[sample]'`

Create new consumers and run them!
