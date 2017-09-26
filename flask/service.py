#!/usr/bin/env python3

from flask import Flask, request
import json
import random
from uuid import uuid4

app = Flask(__name__)

@app.route('/uuid')
def gen_uuid():
    count = request.args.get('count')
    if count is None:
        count = 1
    else:
        count = int(count)

    uuidlist = []
    for i in range(count):
        uuidlist.append(str(uuid4()))

    retval = {}
    retval['count'] = count
    retval['uuids'] = uuidlist

    return(json.dumps(retval))

@app.route('/rand')
def gen_rand():
    count = request.args.get('count')
    if count is None:
        count = 1
    else:
        count = int(count)

    seed = request.args.get('seed')
    if seed is not None:
        seed = int(seed)
        random.seed(seed)

    randlist = []
    for i in range(count):
        randlist.append(random.random)

    retval = {}
    retval['count'] = count
    retval['seed'] = count
    retval['rands'] = randlist

    return(json.dumps(retval))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8088, debug=True)
