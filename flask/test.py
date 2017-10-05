#!/usr/bin/env python3

from flask import Flask
app = Flask(__name__)

@app.route('/hi')
def say_hi():
    return 'Hi!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8088, debug=True)

