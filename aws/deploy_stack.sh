#!/bin/sh
PROJECT_NAME=soda-2022-08
PROFILE=default

if ! aws s3 ls s3://${PROJECT_NAME}; then
    aws s3 mb s3://soda-2022-08 --profile ${PROFILE} --region ap-northeast-1
fi

aws cloudformation package \
    --template-file aws/main.yml \
    --s3-bucket ${PROJECT_NAME} \
    --output-template-file .aws/artifact.yml \
    --profile ${PROFILE} \
    --region ap-northeast-1

aws cloudformation deploy \
    --template-file .aws/artifact.yml \
    --stack-name soda-demo \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile ${PROFILE} \
    --region ap-northeast-1 \
    --parameter-overrides ProjectName=${PROJECT_NAME} RailsMasterKey=`cat config/master.key` &

# 上のCloudFormationがECRを作成済み & Fargateを作り始める前にECRにプッシュの必要あり
while ! aws cloudformation describe-stacks \
    --stack-name soda-demo |
    jq -r '.Stacks[].Outputs[]  |
    select(.OutputKey == "ECRRepository") | .OutputValue'
do
    sleep 5
done

ECR_REPOSITORY=`aws cloudformation describe-stacks \
    --stack-name soda-demo |
    jq -r '.Stacks[].Outputs[]  |
    select(.OutputKey == "ECRRepository") | .OutputValue'`

aws ecr get-login-password \
    --region ap-northeast-1 \
    --profile ${PROFILE} |
    docker login \
    --username AWS \
    --password-stdin ${ECR_REPOSITORY}

docker build -t ${PROJECT_NAME} .

docker tag ${PROJECT_NAME}:latest ${ECR_REPOSITORY}:latest

docker push ${ECR_REPOSITORY}:latest
