# frozen_string_literal: true

module TenantRealm
  module Cache
    class BaseCache
      class << self
        def cache_tenants(_tenants)
          raise NotImplementedError
        end

        def tenants
          raise NotImplementedError
        end

        def cache_tenant(_tenant)
          raise NotImplementedError
        end

        def tenant(_identifier)
          raise NotImplementedError
        end

        private

        def tenant_unique_keys(tenant)
          config = Configuration::Cache

          if config.tenant_keys_resolver.present?
            Helpers.raise_if_not_proc(config.tenant_keys_resolver, 'cache_config.tenant_keys_resolver')
            Helpers.wrap_array(config.tenant_keys_resolver.call(tenant))
          elsif config.tenant_uniq_cols.present?
            cols = Helpers.wrap_array(config.tenant_uniq_cols)

            cols.map do |col|
              tenant[col]
            end
          else
            [
              tenant[:slug]
            ]
          end
        end

        def tenants_key
          'tenant_realm:tenants'
        end

        def tenant_key
          'tenant_realm:tenant'
        end
      end
    end
  end
end
