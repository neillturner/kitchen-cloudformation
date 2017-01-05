# -*- encoding: utf-8 -*-
#
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

require 'kitchen/logging'

module Kitchen
  module Driver
    class Aws
      #
      # A class for encapsulating the stack payload logic
      #
      class StackGenerator
        include Logging

        attr_reader :config, :cf

        def initialize(config, cf)
          @config = config
          @cf = cf
        end

        # Transform the provided config into the hash to send to AWS.  Some fields
        # can be passed in null, others need to be ommitted if they are null
        def cf_stack_data
          s = { stack_name: config[:stack_name] }
          s[:template_url] = config[:template_url] if config[:template_file]
          if config[:template_file]
            s[:template_body] = File.open(config[:template_file], 'rb') { |file| file.read }
          end
          s[:capabilities] = config[:capabilities] if !config[:capabilities].nil? && (config[:capabilities].is_a? Array) && !config[:capabilities].empty?
          s[:timeout_in_minutes] = config[:timeout_in_minutes] if !config[:timeout_in_minutes].nil? && config[:timeout_in_minutes] > 0
          s[:disable_rollback] = config[:disable_rollback]     if !config[:disable_rollback].nil? && config[:disable_rollback] == true || config[:disable_rollback] == false
          s[:parameters] = []
          config[:parameters].each do |k, v|
            s[:parameters].push(parameter_key: k.to_s, parameter_value: v.to_s)
          end
          s[:notification_arns] = config[:notification_arns] if !config[:notification_arns].nil? && (config[:notification_arns].is_a? Array) && !config[:notification_arns].empty?
          s[:resource_types] = config[:resource_types] if !config[:resource_types].nil? && (config[:resource_types].is_a? Array) && !config[:resource_types].empty?
          s[:role_arn] = config[:role_arn] if !config[:role_arn].nil?
          s[:on_failure] = config[:on_failure] if !config[:on_failure].nil?  # accepts DO_NOTHING, ROLLBACK, DELETE
          s[:stack_policy_body] = config[:stack_policy_body] if !config[:stack_policy_body].nil?
          s[:stack_policy_url] = config[:stack_policy_url] if !config[:stack_policy_url].nil?
          s[:tags] = []
          config[:tags].each do |k, v|
            s[:tags].push(key: k.to_s, value: v.to_s)
          end
          s
        end
      end
    end
  end
end
