# kitchen-cloudformation

[![Gem Version](https://badge.fury.io/rb/kitchen-cloudformation.png)](http://badge.fury.io/rb/kitchen-cloudformation)
[![Build Status](https://travis-ci.org/neillturner/kitchen-cloudformation.png)](https://travis-ci.org/neillturner/kitchen-cloudformation)

A Test Kitchen Driver for Amazon AWS Cloudformation.

This driver uses the [aws sdk gem][aws_sdk_gem] to create and delete Amazon AWS Cloudformation stacks to orchestrate your cloud resources for your infrastructure testing, dev or production setup.

If you wish to use servers specified as a hostname in the converge step then use a AWS VPC where the servers have fixed IP addresses or Elastic IP Addresses.

So you can deploy and test say a Mongodb High Availability cluster by using cloud formation to create the servers
and then converge each of the servers in the cluster and run tests.

This can be used with [kitchen-verifier-awspec](https://github.com/neillturner/kitchen-verifier-awspec) to do verification of AWS infrastructure.

## Requirements

There are **no** external system requirements for this driver. However you
will need access to an [AWS][aws_site] account.

## AWS Configuration Options

key | default value | Notes
----|---------------|--------
region|env_var AWS_REGION|The AWS region to use. defaults to 'us-east-1' if no AWS_REGION env var.
shared_credentials_profile| nil|Specify Credentials Using a Profile Name


## CloudFormation Configuration Options

key | default value | Notes
----|---------------|--------
capabilities||Array of capabilities that must be specified before creating or updating certain stacks accepts CAPABILITY_IAM, CAPABILITY_NAMED_IAM
change_set_name ||Name of the Cloud Formation Change Set to create and then execute at converge time
change_set_template_file||File containing the Cloudformation template to use to create the change set
change_set_type | UPDATE |Cloud Formation Change Set can be CREATE or UPDATE
disable_rollback||If the template gets an error don't rollback changes. true/false. default false.
notification_arns| [] |The Simple Notification Service (SNS) topic ARNs to publish stack related events. Array of Strings.
on_failure||Determines what action will be taken if stack creation fails. accepts DO_NOTHING, ROLLBACK, DELETE. You can specify either on_failure or disable_rollback, but not both.
parameters|{}|Hash of parameters {key: value} to apply to the templates
resource_types| [] |The template resource types that you have permissions to work with. Array of Strings.
role_arn||The Amazon Resource Name (ARN) of an AWS Identity and Access Management (IAM) role that AWS CloudFormation assumes to create the stack.
stack_name ||Name of the Cloud Formation Stack to create
stack_policy_body||Structure containing the stack policy body.
stack_policy_url||Location of a file containing the stack policy.
tags|{}|Hash of tags for stack TagKey: TagValue
template_file||File containing the Cloudformation template to run
template_url||URL of the file containing the Cloudformation template to run
timeout_in_minutes|0|Timeout if the stack is not created in the time

See http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html for parameter details.

### AWS Authentication

In order to connect to AWS, you must specify the AWS access key id and secret key
for your account. There are 3 ways you do this, and we will try them in the
following order:

1. You can specify the access key and access secret (and optionally the session
   token) through config.  The `aws_access_key_id` and `aws_secret_access_key`
   parameters can be configured in the .kitchen.yml but its recommended to use
   through environment variables.  If you would like to specify your session token
   use the environment variable `AWS_SESSION_TOKEN`.
2. The shared credentials ini file at `~/.aws/credentials`. This is the file
   populated by `aws configure` command line and used by AWS tools in general, so if
   you are set up for any other AWS tools, you probably already have this. You can
   specify multiple profiles in this file and select one with the `AWS_PROFILE`
   environment variable or the `shared_credentials_profile` driver config.  Read
   [this][credentials_docs] for more information.
3. From an instance profile when running on EC2.  This accesses the local
   metadata service to discover the local instance's IAM instance profile.

This precedence order is taken from http://docs.aws.amazon.com/sdkforruby/api/index.html#Configuration

The first method attempted that works will be used.  IE, if you want to auth
using the instance profile, you must not set any of the access key configs
or environment variables, and you must not specify a `~/.aws/credentials`
file.

Because the Test Kitchen test should be checked into source control and ran
through CI we no longer recommend storing the AWS credentials in the
`.kitchen.yml` file.  Instead, specify them as environment variables or in the
`~/.aws/credentials` file.


## SSL Certificate File Issues

On windows you can get errors `SSLv3 read server certificate B: certificate verify failed`
as per https://github.com/aws/aws-sdk-core-ruby/issues/93 .

To overcome this problem set the environment variable `SSL_CERT_FILE` to a a SSL CA bundle.

A file ca-bundle.crt is supplied inside this gem for this purpose so you can set it to something like:
`<RubyHome>/lib/ruby/gems/2.1.0/gems/kitchen-cloudformation-0.0.1/ca-bundle.crt`


## Example

See example at https://github.com/neillturner/cloudformation_repo

kitchen create default-test -l debug

Create the stack if it does not exist and creates a change set if one is specified.

kitchen converge default-test -l debug

Executes the change set if one has been created

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver:
  name: cloudformation
  stack_name: mystack
  template_file: /test/example.template
  parameters:
    base_package: wget
  change_set_name: mystack-cs
  change_set_template_file: TestSecurityGroupCs.template

provisioner:
  name: Cloudformation

platforms:
  - name: test
    driver:  Cloudformation

suites:
  - name: default
    driver_config:
      ssh_key: /mykeys/mykey.pem
      username: root
      hostname: '10.53.191.70'
```

Apache 2.0 (see [LICENSE][license])


[author]:                https://github.com/neillturner
[issues]:                https://github.com/neillturner/kitchen-cloudformation/issues
[license]:               https://github.com/neillturner/kitchen-cloudformation/blob/master/LICENSE
[repo]:                  https://github.com/neillturner/kitchen-cloudformation
[driver_usage]:          http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:       http://www.getchef.com/chef/install/

[aws_site]:              http://aws.amazon.com/
[credentials_docs]:      http://blogs.aws.amazon.com/security/post/Tx3D6U6WSFGOK2H/A-New-and-Standardized-Way-to-Manage-Credentials-in-the-AWS-SDKs
[aws_sdk_gem]:           http://docs.aws.amazon.com/sdkforruby/api/index.html
[cloud_formation_docs]:  http://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/Welcome.html

## TO DO

-More testing and error handling.

-implement all the options of cloud formation.


