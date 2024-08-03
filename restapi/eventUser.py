import boto3
import json
import os

corsHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Credentials': 'true'
}

def lambda_handler(event, context):
    # If apigatway request is GET, return all events else throw error
    if event['httpMethod'] == 'GET':
        items = get_all_events()
        response = {
            "statusCode": 200,
            "body": json.dumps(items),
            "headers": corsHeaders
        }
    else:
        response = {
            "statusCode": 405,
            "body": json.dumps("Method Not Allowed"),
            "headers": corsHeaders
        }
    return response

def get_all_events():
    '''
    Get all events from the DynamoDB table
    '''
    dynamodb = boto3.resource('dynamodb')
    # Get table name from environment variable
    table_name = os.environ['EVENT_TABLE']
    table = dynamodb.Table(table_name)
    # Get all items from the table
    response = table.scan()
    items = response['Items']
    return items