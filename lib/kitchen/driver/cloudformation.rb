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

require 'benchmark'
require 'json'
require 'kitchen'
require_relative 'cloudformation_version'
require_relative 'aws/cf_client'
require_relative 'aws/stack_generator'

module Kitchen
  module Driver
    #
    # Amazon Cloudformation driver for Test Kitchen.
    #
    class Cloudformation < Kitchen::Driver::Base
      kitchen_driver_api_version 2

      plugin_version Kitchen::Driver::CLOUDFORMATION_VERSION
      default_config :region, ENV['AWS_REGION'] || 'us-east-1'
      default_config :shared_credentials_profile, nil
      default_config :aws_access_key_id, nil
      default_config :aws_secret_access_key, nil
      default_config :aws_session_token, nil
      default_config :http_proxy, ENV['HTTPS_PROXY'] || ENV['HTTP_PROXY']
      default_config :retry_limit, 3
      default_config :ssl_verify_peer, true
      default_config :stack_name, nil
      default_config :template_file, nil
      default_config :capabilities, nil
      default_config :parameters, {}
      default_config :disable_rollback, nil
      default_config :timeout_in_minutes, 0
      default_config :parameters, {}

      default_config :ssh_key, nil
      default_config :username, 'root'
      default_config :hostname, nil
      default_config :notification_arns, []
      default_config :resource_types, []
      default_config :role_arn, nil
      default_config :on_failure, nil # accepts DO_NOTHING, ROLLBACK, DELETE
      default_config :stack_policy_body, nil
      default_config :stack_policy_url, nil
      default_config :tags, {}

      required_config :stack_name

      def create(state)
        copy_deprecated_configs(state)
        return if state[:stack_name]

        info(Kitchen::Util.outdent!(<<-EOT))
          Creating CloudFormation Stack <#{config[:stack_name]}>...
          If you are not using an account that qualifies under the AWS
          free-tier, you may be charged to run these suites. The charge
          should be minimal, but neither Test Kitchen nor its maintainers
          are responsible for your incurred costs.
        EOT
        begin
          stack = create_stack
        rescue StandardError
          error("CloudFormation #{$ERROR_INFO}.") # e.message
          return
        end
        state[:stack_name] = stack.stack_name
        info("Stack <#{state[:stack_name]}> requested.")
        # tag_stack(stack)

        s = cf.get_stack(state[:stack_name])
        while s.stack_status == 'CREATE_IN_PROGRESS'
          debug_stack_events(state[:stack_name])
          info("CloudFormation waiting for stack <#{state[:stack_name]}> to be created.....")
          sleep(30)
          s = cf.get_stack(state[:stack_name])
        end
        display_stack_events(state[:stack_name])
        if s.stack_status == 'CREATE_COMPLETE'
          outputs = Hash[*s.outputs.map do |o|
            [o[:output_key], o[:output_value]]
          end.flatten]
          state[:hostname] = config[:hostname].gsub(/\${([^}]+)}/) { outputs[Regexp.last_match(1)] || '' } if config[:hostname]
          info("CloudFormation stack <#{state[:stack_name]}> created.")
        else
          error("CloudFormation stack <#{stack.stack_name}> failed to create....attempting to delete")
          destroy(state)
        end
      end

      def destroy(state)
        stack = cf.get_stack(state[:stack_name])
        if stack.nil?
          state.delete(:stack_name)
        else
          cf.delete_stack(state[:stack_name])
          begin
            stack = cf.get_stack(state[:stack_name])
            while stack.stack_status == 'DELETE_IN_PROGRESS'
              debug_stack_events(state[:stack_name])
              info("CloudFormation waiting for stack <#{state[:stack_name]}> to be deleted.....")
              sleep(30)
              stack = cf.get_stack(state[:stack_name])
            end
          rescue StandardError
            info("CloudFormation stack <#{state[:stack_name]}> deleted.")
            state.delete(:stack_name)
            return
          end
          display_stack_events(state[:stack_name])
          error("CloudFormation stack <#{stack.stack_name}> failed to deleted.")
        end
      end

      def cf
        @cf ||= Aws::CfClient.new(
          config[:region],
          config[:shared_credentials_profile],
          config[:aws_access_key_id],
          config[:aws_secret_access_key],
          config[:aws_session_token],
          config[:http_proxy],
          config[:retry_limit],
          config[:ssl_verify_peer]
        )
      end

      def stack_generator
        @stack_generator ||= Aws::StackGenerator.new(config, cf)
      end

      # This copies transport config from the current config object into the
      # state.  This relies on logic in the transport that merges the transport
      # config with the current state object, so its a bad coupling.  But we
      # can get rid of this when we get rid of these deprecated configs!
      def copy_deprecated_configs(state)
        state[:connection_timeout] = config[:ssh_timeout] if config[:ssh_timeout]
        state[:connection_retries] = config[:ssh_retries] if config[:ssh_retries]
        state[:username] = config[:username] if config[:username]
        # elsif instance.transport[:username] == instance.transport.class.defaults[:username]
        # If the transport has the default username, copy it from amis.json
        # This duplicated old behavior but I hate amis.json
        # ami_username = amis["usernames"][instance.platform.name]
        # state[:username] = ami_username if ami_username
        # end
        state[:ssh_key] = config[:ssh_key] if config[:ssh_key]
      end

      def create_stack
        stack_data = stack_generator.cf_stack_data
        info("Creating CloudFormation Stack #{stack_data[:stack_name]}")
        cf.create_stack(stack_data)
      end

      def debug_stack_events(stack_name)
        return unless logger.debug?
        response = cf.get_stack_events(stack_name)
        response[:stack_events].each do |r|
          debug("#{r[:timestamp]} #{r[:resource_type]} #{r[:logical_resource_id]} #{r[:resource_status]} #{r[:resource_status_reason]}")
        end
      end

      def display_stack_events(stack_name)
        response = cf.get_stack_events(stack_name)
        response[:stack_events].each do |r|
          info("#{r[:timestamp]} #{r[:resource_type]} #{r[:logical_resource_id]} #{r[:resource_status]} #{r[:resource_status_reason]}")
        end
      end
    end
  end
end
