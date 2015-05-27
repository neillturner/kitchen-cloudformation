# -*- encoding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "benchmark"
require "json"
require "aws"
require "kitchen"
require_relative "cloudformation_version"
require_relative "aws/cf_client"
require_relative "aws/stack_generator"
#require "aws-sdk-core/waiters/errors"

module Kitchen

  module Driver

    # Amazon CloudFormation driver for Test Kitchen.
    #
    class CloudFormation < Kitchen::Driver::Base # rubocop:disable Metrics/ClassLength

      kitchen_driver_api_version 2

      plugin_version Kitchen::Driver::CLOUDFORMATION_VERSION

      default_config :region,             ENV["AWS_REGION"] || "us-east-1"
      default_config :shared_credentials_profile, nil      
      default_config :aws_access_key_id,  nil
      default_config :aws_secret_access_key, nil
      default_config :aws_session_token,  nil
      default_config :ssl_cert_file,      ENV["SSL_CERT_FILE"]
      default_config :stack_name,         nil
      default_config :template_file,      nil
      default_config :parameters,         {}
      default_config :disable_rollback,   false
      default_config :timeout_in_minutes, 0
      default_config :parameters,         {}      

      # A lifecycle method that should be invoked when the object is about
      # ready to be used. A reference to an Instance is required as
      # configuration dependant data may be access through an Instance. This
      # also acts as a hook point where the object may wish to perform other
      # last minute checks, validations, or configuration expansions.
      #
      # @param instance [Instance] an associated instance
      # @return [self] itself, for use in chaining
      # @raise [ClientError] if instance parameter is nil
      def finalize_config!(instance)
        super
        self
      end

      def create(state) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
       # copy_deprecated_configs(state)
        return if state[:stack_name]

        info(Kitchen::Util.outdent!(<<-END))
          Creating <#{state[:stack_name]}>...
          If you are not using an account that qualifies under the AWS
          free-tier, you may be charged to run these suites. The charge
          should be minimal, but neither Test Kitchen nor its maintainers
          are responsible for your incurred costs.
        END
        stack = create_stack
        state[:stack_name] = stack.stack_name
        info("Stack <#{state[:stack_name]}> requested.")
        #tag_stack(stack)

        s = cf.get_stack(state[:stack_name])
        while s.stack_status == 'CREATE_IN_PROGRESS'
          info("CloudFormation waiting for stack <#{state[:stack_name]}> to be created.....")
          sleep(30)
          s = cf.get_stack(state[:stack_name])
        end
        if s.stack_status == 'CREATE_COMPLETE'
          info("CloudFormation stack <#{state[:stack_name]}> created.")
        else
          destroy(state)
          info("CloudFormation stack <#{stack.stack_name}> failed to create.")
        end
      end

      def destroy(state)
        return if state[:stack_name].nil?

        stack = cf.get_stack(state[:stack_name])
        unless stack.nil?
          cf.delete_stack(state[:stack_name])
        end
        info("CloudFormation stack <#{state[:stack_name]}> destroyed.")
        state.delete(:stack_name)
       end

      def cf
        @cf ||= Aws::CfClient.new(
          config[:region],
          config[:shared_credentials_profile],
          config[:ssl_cert_file],
          config[:aws_access_key_id],
          config[:aws_secret_access_key],
          config[:aws_session_token]
        )
      end

      def stack_generator
        @stack_generator ||= Aws::StackGenerator.new(config, cf)
      end

      # This copies transport config from the current config object into the
      # state.  This relies on logic in the transport that merges the transport
      # config with the current state object, so its a bad coupling.  But we
      # can get rid of this when we get rid of these deprecated configs!
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def copy_deprecated_configs(state)
        if config[:ssh_timeout]
          state[:connection_timeout] = config[:ssh_timeout]
        end
        if config[:ssh_retries]
          state[:connection_retries] = config[:ssh_retries]
        end
        if config[:username]
          state[:username] = config[:username]
        #elsif instance.transport[:username] == instance.transport.class.defaults[:username]
        #  # If the transport has the default username, copy it from amis.json
        #  # This duplicated old behavior but I hate amis.json
        #  ami_username = amis["usernames"][instance.platform.name]
        #  state[:username] = ami_username if ami_username
        end
        if config[:ssh_key]
          state[:ssh_key] = config[:ssh_key]
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Fog AWS helper for creating the stack
      def create_stack
        stack_data = stack_generator.cf_stack_data
        info("Creating CloudFormation Stack #{stack_data[:stack_name]}")
        cf.create_stack(stack_data)
      end

    end
  end
end
