# frozen_string_literal: true

module TenantRealm
  class Config
    class << self
      attr_accessor(
        :fetch_tenant,
        :fetch_tenants,
        :dig_db_config,
        :skip_resolver,
        :current_tenant,
        :identifier_resolver,
        :shard_name_from_tenant
      )

      def cache
        yield Configuration::Cache
      end

      def current
        @current ||= current_tenant || CurrentTenant
      end
    end
  end
end
