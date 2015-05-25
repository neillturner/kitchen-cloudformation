# kitchen-cloudformation

[![Gem Version](https://badge.fury.io/rb/kitchen-cloudformation.png)](http://badge.fury.io/rb/kitchen-cloudformation)
[![Build Status](https://travis-ci.org/neillturner/kitchen-cloudformation.png)](https://travis-ci.org/neillturner/kitchen-cloudformation)

A Test Kitchen Driver for Amazon AWS CloudFormation.

This driver uses the [aws sdk gem][aws_sdk_gem] to create and delete CloudFormation
stacks. Use Amazon Cloud Formation to orchestrate your cloud resources for your infrastructure testing, dev or production setup!

## Requirements

There are **no** external system requirements for this driver. However you
will need access to an [AWS][aws_site] account.

## Installation and Setup

Please read the [Driver usage][driver_usage] page for more details.

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

The first method attempted that works will be used.  IE, if you want to auth
using the instance profile, you must not set any of the access key configs
or environment variables, and you must not specify a `~/.aws/credentials`
file.

Because the Test Kitchen test should be checked into source control and ran
through CI we no longer recommend storing the AWS credentials in the
`.kitchen.yml` file.  Instead, specify them as environment variables or in the
`~/.aws/credentials` file.

## Configuration Options

key | default value | Notes
----|---------------|--------
stack_name ||name of the cloud formation to create
template_file||file containing the CloudFormation template to run
template_url||URL of the file containing the CloudFormation template to run
parameters|{}|Hash of parameters {key: value} to apply to the templates
disable_rollback|false|If the template gets an error don't rollback changes
timeout_in_minutes|0|Timeout if the stack is not created in the time

## Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver:
  name: cloudformation
  aws_ssh_key_id: id_rsa-aws
  stack_name: mystack
  template_file: /test/base.template
  parameters:
    - base_package: wget

transport:
  ssh_key: /path/to/id_rsa-aws
  connection_timeout: 10
  connection_retries: 5
  username: ubuntu

platforms:
  - name: ubuntu-12.04
  - name: centos-6.3

suites:
# ...
```

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Neill Turner][author] (<neillwturner@gmail.com>)

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

