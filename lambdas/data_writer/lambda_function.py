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
    """
    Reads a dynamodb table and write to s3 bucket
    """

    # read dynamodb table
    response = table.scan()
    logger.info("Response: " + str(response))

    # write to s3 bucket
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(os.environ['S3_BUCKET'])
    bucket.put_object(Key='data.json', Body=json.dumps(response['Items']))

    # Return a response indicating success or failure
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return {
            'statusCode': 200,
            'body': 'Request data written to S3 bucket'
        }

    else:
        return {
            'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
            'body': 'Error writing request data to S3 bucket'
        }
