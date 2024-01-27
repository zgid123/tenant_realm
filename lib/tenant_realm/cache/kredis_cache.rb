# frozen_string_literal: true

require 'redis'
require 'kredis'

require_relative 'base_cache'

module TenantRealm
  module Cache
    class KredisCache < BaseCache
      class << self
        def cache_tenants(tenants)
          return if tenants.blank?

          cached_tenants = tenants_kredis
          cached_tenants.value = tenants
          tenants
        end

        def tenants
          cached_tenants = tenants_kredis
          cached_tenants.value&.map(&:deep_symbolize_keys) || []
        end

        def cache_tenant(tenant)
          tenant_unique_keys(tenant).each do |key|
            cached_tenant = tenant_kredis(key)
            cached_tenant.value = tenant
          end

          tenant
        end

        def tenant(identifier)
          cached_tenant = tenant_kredis(identifier)
          cached_tenant.value&.deep_symbolize_keys
        end

        private

        def tenants_kredis
          Kredis.json(tenants_key, expires_in: Configuration::Cache.expires_in)
        end

        def tenant_kredis(identifier)
          Kredis.json("#{tenant_key}:#{identifier}", expires_in: Configuration::Cache.expires_in)
        end
      end
    end
  end
end
