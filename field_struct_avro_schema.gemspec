# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'field_struct/avro_schema/version'

Gem::Specification.new do |spec|
  spec.name = 'field_struct_avro_schema'
  spec.version = FieldStruct::AvroSchema::VERSION
  spec.authors = ['Adrian Esteban Madrid']
  spec.email = ['adrian.madrid@acimacredit.com']

  spec.summary = 'Support for Avro schemas in FieldStruct'
  spec.description = 'Adds support for Avro schemas for FieldStruct classes'
  spec.homepage = 'http://github.com/acimacredit/field_struct_avro_schema'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel'
  spec.add_dependency 'field_struct'
  spec.add_dependency 'avro', '~> 1.9'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-json_expectations'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'hashdiff'
end
