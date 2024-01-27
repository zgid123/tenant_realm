# frozen_string_literal: true

module TenantRealm
  module Configuration
    class Cache
      class << self
        attr_accessor :service,
                      :expires_in,
                      :tenant_uniq_cols,
                      :tenant_keys_resolver
      end
    end
  end
end
