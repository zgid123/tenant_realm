# API Reference

All features of Tenant Realm.

## Configuration

### fetch_tenant

- Type: `Proc`
- Default: `nil`
- Required: `true`

Method to fetch tenant detail using `identifier` extracted from [`identifier_resolver`](/api-reference.html#identifier-resolver).

Before everytime switch database, Tenant Realm will use this `proc` to fetch the tenant detail to get all necessary info to do switch database.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.fetch_tenant = lambda { |identifier|
      response = HTTParty.get("http:localhost:3001/api/v1/tenants/#{identifier}")
      data = JSON.parse(response.body)['data']
      data&.deep_symbolize_keys
    }
  end
end
```

### fetch_tenants

- Type: `Proc`
- Default: `nil`
- Required: `true`

Method to fetch tenant list.

When Rails app starts, Tenant Realm will fetch the tenant list to initial all shards for Active Record.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.fetch_tenants = lambda { |identifier|
      response = HTTParty.get("http:localhost:3001/api/v1/tenants")
      data = JSON.parse(response.body)['data']
      data&.map(&:deep_symbolize_keys)
    }
  end
end
```

### dig_db_config

- Type: `Proc` | `Symbol`
- Default: `:db_config`
- Required: `false`

Method/key to extract `db_config` from tenant.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.dig_db_config = lambda { |tenant|
      tenant[:settings][:db_config]
    }

    # or

    config.dig_db_config = :db_config_settings
  end
end
```

### skip_resolver

- Type: `Proc`
- Default: `nil`
- Required: `false`

Method to specify when we want to skip the switch database logic.

Sometimes, we do not want to switch database for some api endpoints.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.skip_resolver = lambda { |request|
      request.env['REQUEST_PATH'].match?(/health|favicon.ico/)
    }
  end
end
```

### current_tenant

- Type: `ActiveSupport::CurrentAttributes`
- Default: `TenantRealm::CurrentTenant`
- Required: `false`

Class to store tenant info.

```rb
# frozen_string_literal: true

class MyCurrent < TenantRealm::CurrentTenant
  attribute :domains,
            :db_config

  def tenant=(tenant)
    super

    self.domains = tenant[:settings][:domains].map { |domain| domain[:value] }
    self.db_config = tenant[:settings][:db_config]
  end
end

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.current_tenant = MyCurrent
  end
end
```

### identifier_resolver

- Type: `Proc`
- Default: `nil`
- Required: `true`

Method to extract `identifier` of tenant from `request`.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.identifier_resolver = lambda { |request|
      domain = request.referer || request.origin
      domain ? URI(domain).host : nil
    }
  end
end
```

### shard_name_from_tenant

- Type: `Proc` | `Symbol`
- Default: `:shard_name` | `:slug` | `:id`
- Required: `false`

Method/key to extract shard from tenant.

When this one is a `Symbol`, the priority of value will be `provided value` or `:shard_name` -> `:slug` -> `:id`. It means when `provided value` or `:shard_name` is not existing in tenant, Tenant Realm will get tenant's slug and last resort is tenant's id.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.shard_name_from_tenant = lambda { |tenant|
      tenant[:shard]
    }

    # or

    config.shard_name_from_tenant = :custom_shard
  end
end
```

## Cache Configuration

To configurate cache service. Default key for tenant will be its slug.

### service

- Type: `Symbol`
- Default: `nil`
- Required: `false`
- Enum: `:redis` | `:kredis`

Specify which cache library that Tenant Realm will use to cache the tenant/tenant list.

If specify, Tenant Realm will fetch tenant/tenant list if no cache, else will get from cache.

`:redis` and `:kredis` will specify [`Kredis`](https://github.com/rails/kredis).

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.cache do |cache_config|
      cache_config.service = :redis
    end
  end
end
```

### expires_in

- Type: `ActiveSupport::Duration`
- Default: `nil`
- Required: `false`

Specify when will the cache will be expired.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.cache do |cache_config|
      cache_config.expires_in = 6.days
    end
  end
end
```

### tenant_uniq_cols

- Type: `Symbol` | `Array<Symbol>`
- Default: `nil`
- Required: `false`

Specify which columns' value that Tenant Realm should you to cache the tenant.

This will be overrided by [`tenant_keys_resolver`](/api-reference.html#tenant-keys-resolver).

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.cache do |cache_config|
      cache_config.tenant_uniq_cols = :domain

      # or

      cache_config.tenant_uniq_cols = %i[domain name]
    end
  end
end
```

### tenant_keys_resolver

- Type: `Proc`
- Default: `nil`
- Required: `false`

Method to extract cache keys from tenant.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.cache do |cache_config|
      cache_config.tenant_keys_resolver = lambda { |tenant|
        [
          tenant[:name],
          *tenant[:settings][:domains]
        ]
      }
    end
  end
end
```
