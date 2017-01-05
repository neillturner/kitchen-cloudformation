lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/cloudformation_version.rb'

Gem::Specification.new do |gem|
  gem.name          = 'kitchen-cloudformation'
  gem.version       = Kitchen::Driver::CLOUDFORMATION_VERSION
  gem.license       = 'Apache 2.0'
  gem.authors       = ['Neill Turner']
  gem.email         = ['neillwturner@gmail.com']
  gem.description   = 'A Test Kitchen Driver for Amazon AWS CloudFormation'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/neillturner/kitchen-cloudformation'
  candidates = Dir.glob('{lib}/**/*') + ['README.md', 'CHANGELOG.md', 'LICENSE', 'ca-bundle.crt', 'kitchen-cloudformation.gemspec']
  gem.files         = candidates.sort
  gem.executables   = []
  gem.require_paths = ['lib']
  gem.add_dependency 'test-kitchen', '~> 1.4'
  gem.add_dependency 'excon'
  gem.add_dependency 'multi_json'
  gem.add_dependency 'aws-sdk-v1', '~> 1.59.0'
  gem.add_dependency 'aws-sdk', '~> 2'
  if RUBY_VERSION >= '2.0'
    gem.add_dependency 'net-ssh', '~> 3'
  else
    gem.add_dependency 'json', '~> 1.8'
    gem.add_dependency 'net-ssh', '~> 2.9'
    gem.add_dependency 'rubocop', '~> 0.41.2'
  end
end
