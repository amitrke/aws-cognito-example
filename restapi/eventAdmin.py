import boto3
import json
import os

def lambda_handler(event, context):
    '''
    Create an event in the DynamoDB table
    Event ID: Unique identifier for the event
        Location#Date#Hour
    '''
    dynamodb = boto3.resource('dynamodb')
    # Get table name from environment variable
    table_name = os.environ['EVENT_TABLE']
    table = dynamodb.Table(table_name)

    # Get the event data from the request
    eventBody = event['body']
    eventBodyJSON = json.loads(eventBody)
    date = eventBodyJSON['date']
    time = eventBodyJSON['time'] # format: HH:MM
    hour = time.split(':')[0]
    location = eventBodyJSON['location']
    description = eventBodyJSON['description']
    # Create an event ID
    id = location + '#' + date + '#' + hour
    # Put the event data into the table
    db_row = {
        'id': id,
        'time': time,
        'description': description
    }
    table.put_item(Item=db_row)

    response = {
        "statusCode": 200,
        "body": json.dumps(db_row),
        "headers": {
            'Content-Type': 'application/json',
        }
    }

    return response    

    
