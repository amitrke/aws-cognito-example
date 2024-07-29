import boto3
import json
import os

def createEvent(request):
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
    event = request['body']
    event = json.loads(event)
    date = event['date']
    time = event['time'] # format: HH:MM
    hour = time.split(':')[0]
    location = event['location']
    description = event['description']
    # Create an event ID
    id = location + '#' + date + '#' + hour
    # Put the event data into the table
    db_row = {
        'id': id,
        'time': time,
        'description': description
    }
    #table.put_item(Item={'id': id, 'name': name, 'date': date, 'location': location, 'description': description})

    response = {
        "statusCode": 200,
        "body": json.dumps(db_row),
        "headers": {
            'Content-Type': 'application/json',
        }
    }

    return response    

    

