#!/usr/bin/env python3

from flask import Flask, request
import json
import random
from uuid import uuid4

app = Flask(__name__)
app.url_map.strict_slashes = False

def return_string(retval):
    '''Prepares retval data structure to be returned to client.

    If the User-Agent string indicates a browser, we will prepare the output
    for human consumption by pretty printing the JSON and placing in <PRE> tags.
    Otherwise, just send raw JSON.
    '''
    browsers = [ 'chrome', 'firefox', 'safari' ]

    if request.user_agent.browser in browsers:
        html = "<PRE>\n{}\n</PRE>".format(json.dumps(retval,
                                                     indent=4,
                                                     sort_keys=True))
        return html
    return json.dumps(retval)

@app.route('/uuid')
def gen_uuid():
    '''Generates UUID4s.

    Generates UUID4.  If the arg `count` is provided, it suppliess `count`
    UUID4s.
    '''

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

    return return_string(retval)

@app.route('/rand')
def gen_rand():
    '''Generates random floats in range [0.0, 1.0] inclusive.

    Generates a random float  in range [0.0, 1.0] inclusive.  if the arg
    `count` is provided, it supplies `count` random floats.  If the arg
    `seed` is provided, any random floats are generated based on that seed.
    '''
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
        randlist.append(random.random())

    retval = {}
    retval['count'] = count
    retval['seed'] = seed
    retval['rands'] = randlist

    return return_string(retval)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8088, debug=True)
