# frozen_string_literal: true

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
# require "kitchen/cloudformation/configurable"

# The design of the provisioner is unconventional compared to other Test Kitchen provisioner plugins. Since Cloudformation
# creates and provisions resources when applying an execution plan, managed by the driver, the provisioner simply
# proxies the driver's create action to apply any changes to the existing Cloudformation state.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   provisioner:
#     name: cloudformation
#
# @see ::Kitchen::Driver::Cloudformation
class ::Kitchen::Provisioner::Cloudformation < ::Kitchen::Provisioner::Base
  kitchen_provisioner_api_version 2

  # include ::Kitchen::Cloudformation::Configurable

  # Proxies the driver's create action.
  #
  # @example
  #   `kitchen converge suite-name`
  # @param state [::Hash] the mutable instance and provisioner state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def call(state)
    info("State is  <#{state}>.")
    instance.driver.update state
  end
end
