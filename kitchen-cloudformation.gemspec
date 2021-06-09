lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/cloudformation_version.rb'

Gem::Specification.new do |gem|
  gem.name          = 'kitchen-cloudformation'
  gem.version       = Kitchen::Driver::CLOUDFORMATION_VERSION
  gem.license       = 'Apache-2.0'
  gem.authors       = ['Neill Turner']
  gem.email         = ['neillwturner@gmail.com']
  gem.description   = 'A Test Kitchen Driver for Amazon AWS CloudFormation'
  gem.summary       = 'A Test Kitchen Driver for AWS CloudFormation'
  gem.homepage      = 'https://github.com/neillturner/kitchen-cloudformation'
  candidates = Dir.glob('{lib}/**/*') + ['README.md', 'CHANGELOG.md', 'LICENSE', 'ca-bundle.crt', 'kitchen-cloudformation.gemspec']
  gem.files         = candidates.sort
  gem.executables   = []
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.2.2'
  gem.add_dependency 'aws-sdk', '~> 3'
  gem.add_dependency 'excon'
  gem.add_dependency 'multi_json'
  gem.add_dependency 'retryable', '~> 2.0'
  gem.add_dependency 'test-kitchen', '>= 1.4.1'
end
