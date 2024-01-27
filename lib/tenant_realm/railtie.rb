# frozen_string_literal: true

module TenantRealm
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.expand_path('../tasks/*.rake', __dir__)].each do |file|
        load(file)
      end
    end
  end
end
