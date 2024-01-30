# frozen_string_literal: true

module TenantRealm
  class Utils
    class << self
      def load_database_yml
        YAML.load_file('config/database.yml', aliases: true)
      end

      def fetch_tenants
        Helpers.raise_if_not_proc(Config.fetch_tenants, 'config.fetch_tenants')

        (Config.fetch_tenants.call.presence || []).map(&:deep_symbolize_keys)
      end

      def fetch_tenant(identifier:)
        Helpers.raise_if_not_proc(Config.fetch_tenant, 'config.fetch_tenant')

        Config.fetch_tenant.call(identifier)&.deep_symbolize_keys
      end

      def dig_db_config(tenant:)
        if Config.dig_db_config.is_a?(Proc)
          Config.dig_db_config.call(tenant)
        else
          key = Config.dig_db_config || :db_config

          tenant[key.to_sym]
        end
      end

      def shard_name_from_tenant(tenant:)
        shard = if Config.shard_name_from_tenant.is_a?(Proc)
                  Config.shard_name_from_tenant.call(tenant)
                else
                  key = Config.shard_name_from_tenant || :shard_name

                  tenant[key.to_sym] || tenant[:slug] || tenant[:id]
                end

        shard.underscore
      end

      def identifier_resolver(request:)
        raise Error, 'config.identifier_resolver must be provided' if Config.identifier_resolver.blank?

        Helpers.raise_if_not_proc(Config.identifier_resolver, 'config.identifier_resolver')

        Config.identifier_resolver.call(request)
      end
    end
  end
end
