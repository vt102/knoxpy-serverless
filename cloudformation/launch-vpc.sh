export REGION=us-east-2
export PROFILE=knoxpy
export VPCNAME=knoxpyvpc
export CIDR=192.168.0.0/21
export PUBSUB0=192.168.0.0/24

#
# Find the number of AZs
#
export NUMAZS=`aws  ec2 describe-availability-zones  --profile ${PROFILE} --region ${REGION} --output text | wc -l`

#
# Set up the parameters for our subnets based on the number of AZs
#
export SUBNETPARAMS=$(cat <<EOF
            ParameterKey=PublicSubnetCIDR0,ParameterValue=${PUBSUB0}
EOF
)


#
# If the VPC already exists, then update it; else, create it.
#
export NUMDEVVPC=`aws ec2 describe-vpcs --profile ${PROFILE} --region us-east-1 --output text --filters Name=tag:Name,Values=${VPCNAME} | egrep Name | wc -l`
if [ "$NUMDEVVPC" -gt "0" ]; then
    export RESULT=`aws cloudformation update-stack \
        --stack-name ${VPCNAME} \
        --template-body file://vpc.yaml \
        --region ${REGION} \
        --profile ${PROFILE} \
        --capabilities CAPABILITY_IAM \
        --parameters \
            ParameterKey=VPCCIDR,ParameterValue=${CIDR} \
${SUBNETPARAMS}
         2>&1 > /dev/null`
    if `echo ${RESULT} | egrep -q 'No updates are to be performed'` ; then
        # No updates needed, but aws returns error in this case.  I don't think it should.
        echo "Result: " ${RESULT}
    elif [ -z "$1" ]; then
        # Update was probably successful
                echo "Result: " ${RESULT}
        echo "CFN template successfully updated!"
    else
        echo "Result: " ${RESULT}
        exit 1
    fi
else
    aws cloudformation create-stack \
        --stack-name ${VPCNAME} \
        --template-body file://vpc.yaml \
        --region ${REGION} \
        --profile ${PROFILE} \
        --capabilities CAPABILITY_IAM \
        --parameters \
            ParameterKey=VPCCIDR,ParameterValue=${CIDR} \
${SUBNETPARAMS}

fi
