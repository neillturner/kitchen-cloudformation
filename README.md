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

## General Configuration

### availability\_zone

The AWS [availability zone][region_docs] to use.  Only request
the letter designation - will attach this to the region used.

The default is `"#{region}b"`.

### aws\_access\_key\_id

**Deprecated** It is recommended to use the `AWS_ACCESS_KEY_ID` or the
`~/.aws/credentials` file instead.

The AWS [access key id][credentials_docs] to use.

### aws\_secret\_access\_key

**Deprecated** It is recommended to use the `AWS_SECRET_ACCESS_KEY` or the
`~/.aws/credentials` file instead.

The AWS [secret access key][credentials_docs] to use.

### shared\_credentials\_profile

The EC2 [profile name][credentials_docs] to use when reading credentials out
of `~/.aws/credentials`.  If it is not specified AWS will read the `Default`
profile credentials (if using this method of authentication).

Can also be specified as `ENV['AWS_PROFILE']`.

### aws\_ssh\_key\_id

**Required** The EC2 [SSH key id][key_id_docs] to use.

The default will be read from the `AWS_SSH_KEY_ID` environment variable if set,
or `nil` otherwise.

### aws\_session\_token

**Deprecated** It is recommended to use the `AWS_SESSION_TOKEN` or the
`~/.aws/credentials` file instead.

The AWS [session token][credentials_docs] to use.

### stack\_name

**Required** The CloudFormation Stack Name to create.

###  template\_file

The file path and name of the cloudformation template to use.

###  template\_url

The url of  the cloudformation template to use.

###  parameters

Parameters to pass to the cloudformation create stack.
   {
     "ParameterKey": "ParameterValue"


###  disable\_rollback

Disable the rollback if the cloudformation create stack hits an error.
Default is "false".

###  timeout\_in\_minutes

If the create stack command does not complete in the specified number of minutes timeout.
Default is "0". i.e. it will not timeout.
1,

```ruby
transport:
  ssh_key: ~/.ssh/id_rsa
```

Path to the private SSH key used to connect to the instance.

The default is unset, or `nil`.

### ssh\_timeout

**Deprecated** Instead use the `transport.connection_timeout` like

```ruby
transport:
  connection_timeout: 60
```

The number of seconds to sleep before trying to SSH again.

The default is `1`.

### ssh\_retries

**Deprecated** Instead use the `transport.connection_retries` like

```ruby
transport:
  connection_retries: 10
```

The number of times to retry SSH-ing into the instance.

The default is `3`.

### username

**Deprecated** Instead use the `transport.username` like

```ruby
transport:
  username: ubuntu
```

The SSH username that will be used to communicate with the instance.

The default will be determined by the Platform name, if a default exists.
If a default cannot be computed, then the default is `"root"`.

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

