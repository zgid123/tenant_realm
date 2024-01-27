# frozen_string_literal: true

class TenantRealmGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def generate_tenant_realm
    template(
      'tenant_realm.tt',
      'config/initializers/tenant_realm.rb'
    )
  end
end
