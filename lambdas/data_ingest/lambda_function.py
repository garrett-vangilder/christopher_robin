import datetime
import uuid
import boto3
import os
import logging
import json

dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

# create cloudwatch logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.info('Loading function')

def lambda_handler(event, context):
    # Extract the request body from the event
    str_request_body = event['body']
    
    # Add a unique ID to the request body
    dict_request_body = json.loads(str_request_body)

    dict_request_body['id'] = str(uuid.uuid4())

    utc_now = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    dict_request_body['created'] = utc_now
    logger.info("Request body: " + str(dict_request_body))

    # Parse the request body into a JSON object
    request_data = json.dumps(dict_request_body)
    json_request_data = json.loads(request_data)
    logger.info("Request data: " + str(request_data))

    # Write the request data to the DynamoDB table
    response = table.put_item(Item=json_request_data)
    logger.info("Response: " + str(response))

    # Return a response indicating success or failure
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return {
            'statusCode': 200,
            'body': 'Request data written to DynamoDB table'
        }
    else:
        return {
            'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
            'body': 'Error writing request data to DynamoDB table'
        }