# kitchen-cloudformation

[![Gem Version](https://badge.fury.io/rb/kitchen-cloudformation.png)](http://badge.fury.io/rb/kitchen-cloudformation)
[![Build Status](https://travis-ci.org/neillturner/kitchen-cloudformation.png)](https://travis-ci.org/neillturner/kitchen-cloudformation)

A Test Kitchen Driver for Amazon AWS CloudFormation.

This driver uses the [aws sdk gem][aws_sdk_gem] to create and delete Amazon AWS CloudFormation stacks to orchestrate your cloud resources for your infrastructure testing, dev or production setup.

It works best using AWS VPC where the servers have fixed IP addresses or in AWS Clasic using known Elastic IP Addresses.
This allow the IP address of each of the servers to be specified as a hostname in the suite definition (see example below).

So you can deploy and test say a Mongodb High Availability cluster by using cloud formation to create the servers
and then converge each of the servers in the cluster and run tests.

WARNING: This is a pre-release version. I'm sure the code does not handle all error conditions etc.

## Requirements

There are **no** external system requirements for this driver. However you
will need access to an [AWS][aws_site] account.


## Configuration Options

key | default value | Notes
----|---------------|--------
region|ENV["AWS_REGION"] or "us-east-1"|Aws Region
shared_credentials_profile| nil|Specify Credentials Using a Profile Name
aws_access_key_id|nil|Deprecated see Authenticating with AWS
aws_secret_access_key|nil|Deprecated see Authenticating with AWS
aws_session_token|nil|Deprecated see Authenticating with AWS
ssl_cert_file| ENV["SSL_CERT_FILE"]|SSL Certificate required on Windows platforms
stack_name ||Name of the Cloud Formation Stack to create
template_file||File containing the CloudFormation template to run
template_url||URL of the file containing the CloudFormation template to run
parameters|{}|Hash of parameters {key: value} to apply to the templates
disable_rollback|false|If the template gets an error don't rollback changes
timeout_in_minutes|0|Timeout if the stack is not created in the time

## Authenticating with AWS

There are 3 ways you can authenticate against AWS, and we will try them in the
following order:

1. You can specify the access key and access secret (and optionally the session
token) through config.  See the `aws_access_key_id` and `aws_secret_access_key`
config sections below to see how to specify these in your .kitchen.yml or
through environment variables.  If you would like to specify your session token
use the environment variable `AWS_SESSION_TOKEN`.
1. The shared credentials ini file at `~/.aws/credentials`.  You can specify
multiple profiles in this file and select one with the `AWS_PROFILE`
environment variable or the `shared_credentials_profile` driver config.  Read
[this][credentials_docs] for more information.
1. From an instance profile when running on EC2.  This accesses the local
metadata service to discover the local instance's IAM instance profile.

This precedence order is taken from http://docs.aws.amazon.com/sdkforruby/api/index.html#Configuration

In summary it searches the following locations for credentials:

1. ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
1. The shared credentials ini file at ~/.aws/credentials (more information)
1. From an instance profile when running on EC2

and it searches the following locations for a region:

1. ENV['AWS_REGION']



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
as per `https://github.com/aws/aws-sdk-core-ruby/issues/93`.

To overcome this problem set the parameter `ssl_cert_file` or the environment variable `SSL_CERT_FILE`
to a a SSL CA bundle.

A file ca-bundle.crt is supplied inside this gem for this purpose so you can set it to something like: 
`<RubyHome>/lib/ruby/gems/2.1.0/gems/kitchen-cloudformation-0.0.1/ca-bundle.crt`


## Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver:
  name: cloudformation
  stack_name: mystack
  template_file: /test/example.template
  parameters:
    - base_package: wget

provisioner:
  name: chef_zero

platforms:
  - name: centos-6.4
    driver:  cloud_formation

suites:
  - name: default
    driver_config:
      ssh_key: /mykeys/mykey.pem
      username: root
      hostname: '10.53.191.70'
```

## <a name="license"></a> License

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

