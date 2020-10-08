'use strict'
const AWS = require('aws-sdk')
const handler = async (event, context) => {
    const credentials = new AWS.ChainableTemporaryCredentials({
      params: {
        RoleArn: `arn:aws:sts::${process.env.OTHER_ACCOUNT_NUMBER}:role/s3-cross-account`
      }
    })
    const s3 = new AWS.S3({ credentials })
    const params = {
    Bucket: 's3-cross-account-jds',
    Key: 'yama',
    Body: 'hello there'
  }
  await s3.upload(params).promise()
  delete params.Body
  delete params.ACL
  const obj = await s3.getObject(params).promise()
  console.log('s3 object body: ', obj.Body.toString())
}
exports = module.exports = {
  handler,
}
