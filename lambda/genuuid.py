#!/usr/bin/env python3

import json
from uuid import uuid4

def gen_uuid(event, context):
    count = 1
    if 'count' in event['queryStringParameters']:
        count = int(event['queryStringParameters']['count'])

    uuidlist = []
    for i in range(count):
        uuidlist.append(str(uuid4()))

    retval = {}
    retval['count'] = count
    retval['uuids'] = uuidlist

    response = {
        'statusCode': 200,
        'body': json.dumps(retval)
    }

    return(response)
