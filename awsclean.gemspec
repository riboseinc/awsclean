# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsclean/version'

Gem::Specification.new do |spec|
  spec.name          = "awsclean"
  spec.version       = Awsclean::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{CLI to clean up AWS AMIs and ECR images}
  spec.description   = %q{CLI to clean up AWS AMIs and ECR images}
  spec.homepage      = "https://www.ribose.com"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "https://gems.ribose.com"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = "awsclean"
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.14"
  spec.add_dependency "thor",    "~> 0.19.4"
  spec.add_dependency "aws-sdk", "~> 2.7.4"
  spec.add_dependency "pry"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-expectations", "~> 3.0"
end
