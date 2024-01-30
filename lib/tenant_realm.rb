# frozen_string_literal: true

require_relative 'tenant_realm/config'
require_relative 'tenant_realm/version'
require_relative 'tenant_realm/helpers'
require_relative 'tenant_realm/db_context'
require_relative 'tenant_realm/class_methods'
require_relative 'tenant_realm/configuration/cache'

module TenantRealm
  require 'tenant_realm/railtie' if defined?(Rails)

  class Error < StandardError; end

  class CurrentTenant < ActiveSupport::CurrentAttributes
    attribute :tenant
  end

  class Railtie < Rails::Railtie
    config.before_configuration do
      Helpers.dev_log('Tenant Realm: Init shard resolver')

      config.active_record.shard_selector = { lock: false }
      config.active_record.shard_resolver = lambda { |request|
        skip_switch_db = if Config.skip_resolver.is_a?(Proc)
                           Config.skip_resolver.call(request)
                         else
                           false
                         end

        return :primary if skip_switch_db

        identifier = Utils.identifier_resolver(request:)
        tenant = Tenant.tenant(identifier:)
        db_config = Utils.dig_db_config(tenant:)

        return :primary if db_config.blank?

        shard = Utils.shard_name_from_tenant(tenant:)
        Config.current.tenant = tenant
        DbContext.add_shard(shard:, db_config:)
        ActiveRecord::Base.connects_to(shards: DbContext.connected_shards)

        shard
      }
    end

    initializer 'active_record.setup_tenant_realm' do
      Helpers.dev_log('Tenant Realm: Init database shards')

      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.default_shard = :primary
        ActiveRecord::Base.connects_to(
          shards: {
            primary: { writing: :primary, reading: :primary }
          }
        )

        DbContext.init_shards
      rescue ActiveRecord::ActiveRecordError
        nil
      end
    end
  end
end
