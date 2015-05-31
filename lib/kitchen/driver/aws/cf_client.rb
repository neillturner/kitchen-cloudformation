# -*- encoding: utf-8 -*-
#
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'aws-sdk'
require 'aws-sdk-core/credentials'
require 'aws-sdk-core/shared_credentials'
require 'aws-sdk-core/instance_profile_credentials'

module Kitchen
  module Driver
    class Aws
      #
      # A class for creating and managing the Cloud Formation client connection
      #
      class CfClient
        def initialize(
          region,
          profile_name = nil,
          ssl_cert_file = nil,
          access_key_id = nil,
          secret_access_key = nil,
          session_token = nil
        )
          creds = self.class.get_credentials(
            profile_name, access_key_id, secret_access_key, session_token
          )

          ::AWS.config(
            region: region,
            credentials: creds,
            ssl_ca_bundle: ssl_cert_file
          )
        end

        # Try and get the credentials from an ordered list of locations
        # http://docs.aws.amazon.com/sdkforruby/api/index.html#Configuration
        def self.get_credentials(profile_name, access_key_id, secret_access_key, session_token)
          shared_creds = ::Aws::SharedCredentials.new(:profile_name => profile_name)
          if access_key_id && secret_access_key
            ::Aws::Credentials.new(access_key_id, secret_access_key, session_token)
          # TODO: these are deprecated, remove them in the next major version
          elsif ENV['AWS_ACCESS_KEY'] && ENV['AWS_SECRET_KEY']
            ::Aws::Credentials.new(
              ENV['AWS_ACCESS_KEY'],
              ENV['AWS_SECRET_KEY'],
              ENV['AWS_TOKEN']
            )
          elsif ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
            ::Aws::Credentials.new(
              ENV['AWS_ACCESS_KEY_ID'],
              ENV['AWS_SECRET_ACCESS_KEY'],
              ENV['AWS_SESSION_TOKEN']
            )
          elsif shared_creds.loadable?
            shared_creds
          else
            ::Aws::InstanceProfileCredentials.new(retries: 1)
          end
        end

        def create_stack(options)
          resource.create_stack(options)
        end

        def get_stack(stack_name)
          resource.stack(stack_name)
        end

        def get_stack_events(stack_name)
          client.describe_stack_events(stack_name: stack_name)
        end

        def delete_stack(stack_name)
          s = resource.stack(stack_name)
          s.delete
        end

        def client
          @client ||= ::Aws::CloudFormation::Client.new
        end

        def resource
          @resource ||= ::Aws::CloudFormation::Resource.new
        end
      end
    end
  end
end
