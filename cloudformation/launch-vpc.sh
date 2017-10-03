export REGION=us-east-2
export PROFILE=knoxpy
export VPCNAME=knoxpyvpc
export CIDR=192.168.0.0/21
export PUBSUB0=192.168.0.0/24
export PUBSUB1=192.168.5.0/24
export PUBSUB2=192.168.2.0/24
export PUBSUB3=192.168.3.0/24
export PUBSUB4=192.168.4.0/24

#
# Find the number of AZs
#
export NUMAZS=`aws  ec2 describe-availability-zones  --profile ${PROFILE} --region ${REGION} --output text | wc -l`

#
# Set up the parameters for our subnets based on the number of AZs
#
export SUBNETPARAMS=$(cat <<EOF
            ParameterKey=PublicSubnetCIDR0,ParameterValue=${PUBSUB0}
            ParameterKey=PublicSubnetCIDR1,ParameterValue=${PUBSUB1}

EOF
)

if [ $NUMAZS -gt 2 ] ; then
    SUBNETPARAMS=$(cat <<EOF
${SUBNETPARAMS}
            ParameterKey=PublicSubnetCIDR2,ParameterValue=${PUBSUB2}
EOF
)
fi

if [ $NUMAZS -gt 3 ] ; then
    SUBNETPARAMS=$(cat <<EOF
${SUBNETPARAMS}
            ParameterKey=PublicSubnetCIDR3,ParameterValue=${PUBSUB3}
EOF
)
fi

if [ $NUMAZS -gt 4 ] ; then
    SUBNETPARAMS=$(cat <<EOF
${SUBNETPARAMS}
            ParameterKey=PublicSubnetCIDR4,ParameterValue=${PUBSUB4}
EOF
)
fi


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
