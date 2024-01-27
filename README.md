Tenant Realm is a lightweight gem provides some helpers to support working on multi-tenant easily using [Multiple Database with Active Record](https://guides.rubyonrails.org/active_record_multiple_databases.html).

# Installation

```sh
gem 'tenant_realm'
```

# CLI

- init `tenant_realm`

```sh
rails g tenant_realm
```

- run migration for all tenants

```sh
rake tenant_realm:migrate
```

# Configuration

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    # required
    # identifier is extracted from `identifier_resolver`
    config.fetch_tenant = lambda { |identifier|
      # get tenant using identifier
    }

    # required
    config.fetch_tenants = lambda {
      # get tenant list
    }

    # optional
    # default is getting from key :db_config from tenant
    config.dig_db_config = lambda { |tenant|
      tenant[:db_config]
    }

    # optional
    # set this when you wanna skip the switch database
    config.skip_resolver = lambda { |request|
      request.env['REQUEST_PATH'].match?(/health|favicon.ico/)
    }

    # required
    # method to extract the identifier of tenant
    config.identifier_resolver = lambda { |request|
      # get identifier from request
      # tenant is retrieved using its domain
      domain = request.referer || request.origin
      domain ? URI(domain).host : nil
    }

    # optional
    # extract the sharding name for multi_db
    # default will be this proc return value -> tenant's shard_name -> slug -> id
    config.shard_name_from_tenant = lambda { |tenant|
      tenant[:slug]
    }

    # optional
    # default will be TenantRealm::CurrentTenant
    config.current_tenant = MyCurrentTenant

    # optional
    config.cache do |cache_config|
      # using cache service
      cache_config.service = :redis

      # when will the tenant list and tenant are expired
      cache_config.expires_in = 6.days

      # list keys to cache the tenant
      cache_config.tenant_uniq_cols = %i[slug domain]

      # in case the column is not simple like above
      # this option will override the one above
      cache_config.tenant_keys_resolver = lambda { |tenant|
        [
          tenant[:slug],
          tenant[:settings][:domain]
        ]
      }
    end
  end
end
```

# Customize

- Custom current tenant

```rb
# frozen_string_literal: true

class CurrentTenant < TenantRealm::CurrentTenant
  attribute :additional_info

  def tenant=(tenant)
    super

    self.additional_info = {
      domain: tenant[:settings][:domain]
    }
  end
end
```

# TODO

- [ ] support Row-Level Security (RLS)

- [ ] support multi-schema
