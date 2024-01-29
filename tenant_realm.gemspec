# frozen_string_literal: true

require_relative 'lib/tenant_realm/version'

Gem::Specification.new do |spec|
  spec.name = 'tenant_realm'
  spec.version = TenantRealm::VERSION
  spec.authors = ['Alpha']
  spec.email = ['alphanolucifer@gmail.com']

  spec.summary = 'Ruby on Rails gem to support multi-tenant'
  spec.description = 'Ruby on Rails gem to support multi-tenant'
  spec.homepage = 'https://github.com/zgid123/tenant_realm'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(
          *%w[
            bin/
            test/
            spec/
            docs/
            features/
            .git
            .circleci
            appveyor
            examples/
            Gemfile
            .rubocop.yml
            .vscode/settings.json
            LICENSE.txt
            lefthook.yml
          ]
        )
    end
  end

  spec.require_paths = ['lib']
end
