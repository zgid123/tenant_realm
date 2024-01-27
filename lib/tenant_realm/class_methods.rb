# frozen_string_literal: true

module TenantRealm
  class << self
    def configure
      yield Config
    end

    def configuration
      Config
    end
  end
end
