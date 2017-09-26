#!/bin/sh

if [ $# -eq 0 ]
then
    echo "No new name given"
    echo "Usage:" $0 "<new-name>"
    exit 1
fi

sed -i "s/lambda-service/$1/g" serverless.yml
