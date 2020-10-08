#!/usr/bin/env bash
# set -eux
set -e
: ' MULTILINE COMMENT

Publishes lamba zip file to AWS.

./publish.sh \
  --aws-account-number 83875511947 \
  --region us-west-2

'
dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# cd to the directory this script is in
cd "${dir}"
cd ..
region='us-east-1 us-west-2'
# function name defaults to the name of the directory this script is in.
lambda_name="${PWD##*/}"
lambda_environment="Variables={}"
zip_file='./lambda.zip'
lambda_runtime='nodejs12.x'
lambda_memory='1536'
lambda_timeout_seconds=10
while [[ $# -gt 0 ]]; do
case $1 in
  -a|--aws-account-number)
    aws_account_number=$2
    shift 2
    ;;
  -o|--other-account-number)
    other_account_number=$2
    shift 2
    ;;
  -r|--region)
    region=$2
    shift 2
    ;;
  -n|--lambda-name)
    lambda_name=$2
    shift 2
    ;;
  -u|--runtime)
    lambda_runtime=$2
    shift 2
    ;;
  -m|--memory)
    lambda_memory=$2
    shift 2
    ;;
  -i|--timeout)
    lambda_timeout_seconds=$2
    shift 2
    ;;
  -z|--zip-file)
    zip_file=$2
    shift 2
    ;;
  -h|--help)
    echo ""
    echo "Usage: publish.sh (options)"
    echo ""
    echo "  Publish the lambda to AWS."
    echo ""
    echo "  aws-account-number"
    echo "    The AWS account number to publish to."
    echo ""
    echo "  other-account-number"
    echo "    The AWS account number of the other account."
    echo ""
    echo "  region (optional) default: ${region}"
    echo "    The name of the AWS region to publish to."
    echo "    May be space delimited list of regions."
    echo ""
    echo "  lambda-name (optional) default: ${lambda_name}"
    echo "    The name of the lambda function we are publishing."
    echo "    Defaults to the name of the folder this script is in."
    echo ""
    echo "  zip-file (optional) default: ${zip_file}"
    echo "    The lambda code we are deploying."
    echo ""
    exit 0
    ;;
esac
done
echo "aws_account_number: ${aws_account_number}"
echo "other_account_number: ${other_account_number}"
echo "region: ${region}"
echo "lambda_name: ${lambda_name}"
echo "zip_file: ${zip_file}"
echo "lambda_runtime: ${lambda_runtime}"
echo "lambda_memory: ${lambda_memory}"
echo "lambda_timeout_seconds: ${lambda_timeout_seconds}"

function createLambda() {
  aws lambda create-function \
    --function-name "${lambda_name}" \
    --region "${1}" \
    --runtime "${lambda_runtime}" \
    --role "arn:aws:iam::${aws_account_number}:role/s3-cross-account" \
    --handler "index.handler" \
    --zip-file "fileb://${zip_file}" \
    || echo "if no (other) error ${lambda_name} in region ${1} already exists"
}

function updateLambda() {
  aws lambda update-function-configuration \
    --function-name "${lambda_name}" \
    --region "${1}" \
    --runtime "${lambda_runtime}" \
    --memory-size "${lambda_memory}" \
    --timeout "${lambda_timeout_seconds}" \
    --environment "Variables={OTHER_ACCOUNT_NUMBER=$other_account_number}"
  aws lambda update-function-code \
    --function-name "${lambda_name}"  \
    --region "${1}" \
    --zip-file "fileb://${zip_file}"
}

for r in $region # note that $region must NOT be quoted here!
do
  # createLambda "${r}"
  updateLambda "${r}"
done
