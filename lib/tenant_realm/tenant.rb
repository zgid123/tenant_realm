# frozen_string_literal: true

require_relative 'cache/kredis_cache'

module TenantRealm
  class Tenant
    @@cache = {
      redis: Cache::KredisCache,
      kredis: Cache::KredisCache
    }

    class << self
      def tenants(force_load: false)
        if cache.present?
          unless force_load
            tenants = cache.tenants
            return tenants if tenants.present?
          end

          tenants = Utils.fetch_tenants
          cache.cache_tenants(tenants:)
          tenants
        else
          Utils.fetch_tenants
        end
      end

      def tenant(identifier:, force_load: false)
        if cache.present?
          unless force_load
            tenant = cache.tenant(identifier:)
            return tenant if tenant.present?
          end

          tenant = Utils.fetch_tenant(identifier:)
          cache.cache_tenant(tenant:)
          tenant
        else
          Utils.fetch_tenant
        end
      end

      def cache_tenants(tenants:)
        return Helpers.dev_log('Tenant Realm: Skip cache tenants because cache not configured') if cache.blank?

        cache.cache_tenants(tenants:)
      end

      def cache_tenant(tenant:)
        return Helpers.dev_log('Tenant Realm: Skip cache tenant because cache not configured') if cache.blank?

        cache.cache_tenant(tenant:)
      end

      private

      def cache
        @cache ||= @@cache[Configuration::Cache.service]
      end
    end
  end
end
