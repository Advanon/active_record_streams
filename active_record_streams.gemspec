# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_streams/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record_streams'
  spec.version       = ActiveRecordStreams::VERSION
  spec.authors       = ['Advanon Team']
  spec.email         = ['team@advanon.com']

  spec.summary = <<-HEREDOC
    Stream ActiveRecord events via HTTP, AWS SNS or Kinesis streams
  HEREDOC

  spec.description = <<-HEREDOC
    Publish events about changes to your ActiveRecord models to different
    targets, like HTTP endpoints, AWS SNS topics or Kinesis streams
  HEREDOC

  spec.homepage = 'https://advanon.com'
  spec.required_ruby_version = '>= 2.3.3'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage

    spec.metadata['source_code_uri'] =
      'https://github.com/Advanon/active_record_streams'

    spec.metadata['changelog_uri'] =
      'https://github.com/Advanon/active_record_streams/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.2.10'
  spec.add_dependency 'aws-sdk', '~> 2.11.9'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.67.2'
  spec.add_development_dependency 'rubocop-performance', '~> 1.1.0'
end
