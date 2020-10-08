# S3 Cross Account

This is an example of how to access s3 objects owned by a different account.

In IAM you need two things for role a to trust role b.

* role b must allow itself to trust role a
* role a must allow role b to trust role a

The first one seems a bit strange. Why do I have to give myself permssion to
trust another role?

You will need two AWS accounts, account a, and account b.

## IAM Role and Policy

Create an IAM role in both accounts named `s3-cross-account`. Use the policy in
`misc/policy.json`. Replace `OTHER_ACCOUNT_NUMBER` with the AWS account number
of the other account.

Edit the role's trust relationship. Use `misc/trust.json`. Replace
`OTHER_ACCOUNT_NUMBER` with the AWS account number of the other account.

## S3 Bucket

I created one named `s3-cross-account-jds`.

You need to update `index.js` with the name of your bucket(s).

## Deploy the Lambdas

Set `account_a` and `account_b` to your AWS account ids.

make sure you have a profile for account a named `aprofile` and one for account
b named `bprofile`.

Run the following.

```sh
export account_a=111111111111
export account_b=222222222222
misc/zip.sh
export AWS_PROFILE=aprofile && misc/publish.sh -a $account_a -o $account_b
export AWS_PROFILE=bprofile && misc/publish.sh -a $account_b -o $account_a
```

## IAM Revoke Sessions

When testing IAM role changes you need to revoke older sessions or your changes
won't take effect.

After revoking older sessions you will need to make some change to your lambda
code and save the change so that you will get a new session.
