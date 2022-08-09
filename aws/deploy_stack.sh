#!/bin/sh
PROJECT_NAME=soda-2022-08
PROFILE=default
REGION=ap-northeast-1
STACK_NAME=soda-demo

aws s3 ls s3://${PROJECT_NAME} --profile ${PROFILE} || aws s3 mb s3://${PROJECT_NAME} --profile ${PROFILE} --region ${REGION}

aws cloudformation package \
    --template-file aws/main.yml \
    --s3-bucket ${PROJECT_NAME} \
    --output-template-file .aws/artifact.yml \
    --profile ${PROFILE} \
    --region ${REGION}

aws cloudformation deploy \
    --template-file .aws/artifact.yml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile ${PROFILE} \
    --region ${REGION} \
    --parameter-overrides ProjectName=${PROJECT_NAME} RailsMasterKey=`cat config/master.key` &


# 上のCloudFormationがECRを作成済み & Fargateを作り始める前にECRにプッシュの必要あり
while [ -z "`aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --profile $PROFILE \
    --region $REGION |
    jq -r '.StackSummaries[].StackName | select(contains("'$STACK_NAME'-ECRStack"))'`" ]
do
    echo "waiting for creating ECR"
    sleep 30
done

ECR_STACK=`aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE \
    --profile $PROFILE \
    --region $REGION |
    jq -r '.StackSummaries[].StackName | select(contains("'$STACK_NAME'-ECRStack"))'`

ECR_REPOSITORY=`aws cloudformation describe-stacks \
    --stack-name $ECR_STACK \
    --profile $PROFILE \
    --region $REGION |
    jq -r '.Stacks[].Outputs[].OutputValue'`

aws ecr get-login-password \
    --region ${REGION} \
    --profile ${PROFILE} |
    docker login \
    --username AWS \
    --password-stdin ${ECR_REPOSITORY}

docker build -t ${PROJECT_NAME} .

docker tag ${PROJECT_NAME}:latest ${ECR_REPOSITORY}:latest

docker push ${ECR_REPOSITORY}:latest
