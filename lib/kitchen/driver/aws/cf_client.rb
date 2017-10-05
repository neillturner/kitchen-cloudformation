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

require 'aws-sdk-cloudformation'
require 'aws-sdk-core/credentials'
require 'aws-sdk-core/shared_credentials'
require 'aws-sdk-core/instance_profile_credentials'

module Kitchen
  module Driver
    class Aws
      # A class for creating and managing the EC2 client connection
      #
      # @author Tyler Ball <tball@chef.io>
      class CfClient
        def initialize( # rubocop:disable Metrics/ParameterLists
          region,
          profile_name = nil,
          access_key_id = nil,
          secret_access_key = nil,
          session_token = nil,
          http_proxy = nil,
          retry_limit = nil,
          ssl_verify_peer = true
        )
          creds = self.class.get_credentials(
            profile_name, access_key_id, secret_access_key, session_token, region
          )
          ::Aws.config.update(
            region: region,
            credentials: creds,
            http_proxy: http_proxy,
            ssl_verify_peer: ssl_verify_peer
          )
          ::Aws.config.update(retry_limit: retry_limit) unless retry_limit.nil?
        end

        # Try and get the credentials from an ordered list of locations
        # http://docs.aws.amazon.com/sdkforruby/api/index.html#Configuration
        # rubocop:disable Metrics/ParameterLists
        def self.get_credentials(profile_name, access_key_id, secret_access_key, session_token,
                                 region, options = {})
          source_creds =
            if access_key_id && secret_access_key
              ::Aws::Credentials.new(access_key_id, secret_access_key, session_token)
            elsif ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
              ::Aws::Credentials.new(
                ENV['AWS_ACCESS_KEY_ID'],
                ENV['AWS_SECRET_ACCESS_KEY'],
                ENV['AWS_SESSION_TOKEN']
              )
            elsif profile_name
              ::Aws::SharedCredentials.new(profile_name: profile_name)
            elsif default_shared_credentials?
              ::Aws::SharedCredentials.new
            else
              ::Aws::InstanceProfileCredentials.new(retries: 1)
            end

          if options[:assume_role_arn] && options[:assume_role_session_name]
            sts = ::Aws::STS::Client.new(credentials: source_creds, region: region)

            assume_role_options = (options[:assume_role_options] || {}).merge(
              client: sts,
              role_arn: options[:assume_role_arn],
              role_session_name: options[:assume_role_session_name]
            )

            ::Aws::AssumeRoleCredentials.new(assume_role_options)
          else
            source_creds
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def self.default_shared_credentials?
          ::Aws::SharedCredentials.new.loadable?
        rescue ::Aws::Errors::NoSuchProfileError
          false
        end

        def create_stack(options)
          resource.create_stack(options)
        end

        def update_stack(options)
          resource.update_stack(options)
        end

        def create_change_set(options)
          client.create_change_set(options)
        end

        def execute_change_set(options)
          client.execute_change_set(options)
        end

        def get_stack(stack_name)
          resource.stack(stack_name)
        end

        # rubocop:disable Lint/RescueWithoutErrorClass
        def describe_change_set(stack_name, change_set_name)
          client.describe_change_set(change_set_name: change_set_name,
                                     stack_name: stack_name)
        rescue
          nil
        end
        # rubocop:enable Lint/RescueWithoutErrorClass

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
