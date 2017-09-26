#!/usr/bin/env python3

import json
import random

def gen_rand(event, context):
    count = 1
    seed = None
    if event['queryStringParameters']:
        if 'count' in event['queryStringParameters']:
            count = int(event['queryStringParameters']['count'])
        if 'seed' in event['queryStringParameters']:
            seed = int(event['queryStringParameters']['seed'])
            random.seed(seed)

    randlist = []
    for i in range(count):
        randlist.append(random.random())

    retval = {}
    retval['count'] = count
    retval['seed'] = seed
    retval['rands'] = randlist

    response = {
        'statusCode': 200,
        'body': json.dumps(retval)
    }

    return(response)
