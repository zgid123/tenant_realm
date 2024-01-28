# Getting Started

## Installation

#### Prerequisites

- Ruby version 3.1.0 or higher.
- Ruby on Rails version 7.0.0 or higher.

```rb
gem 'tenant_realm'
```

## Configuration

Tenant Realm provides a rake task to generate a configuration file.

```sh
rails g tenant_realm
```

It will create a file `config/initializers/tenant_realm.rb` with a default configuration.

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.fetch_tenant = lambda { |identifier|
      # get tenant using identifier
    }

    config.fetch_tenants = lambda {
      # get tenant list
    }

    config.dig_db_config = lambda { |tenant|
      tenant[:db_config]
    }

    config.skip_resolver = lambda { |request|
      request.env['REQUEST_PATH'].match?(/health|favicon.ico/)
    }

    config.identifier_resolver = lambda { |request|
      # get identifier from request
      # domain = request.referer || request.origin
      # domain ? URI(domain).host : nil
    }

    config.shard_name_from_tenant = lambda { |tenant|
      tenant[:slug]
    }
  end
end
```

> [!NOTE]
> [Check here](/api-reference) to see full API.

### config.fetch_tenant

A method to fetch tenant detail from external server or query from database using `identifier` that is extracted from [`config.identifier_resolver`](/introduction/getting-started.html#config-identifier-resolver). Result must be in [Hash](https://ruby-doc.org/3.1.4/Hash.html).

### config.fetch_tenants

A method to fetch tenant list from external server or query from database to initial all tenants' shard. Result must be in [Hash](https://ruby-doc.org/3.1.4/Hash.html).

### config.dig_db_config

A method to get `db_config` from tenant instance.

### config.skip_resolver

A method to specify which endpoint needs to be skipped switch database.

### config.identifier_resolver

A method to get tenant's identifier value.

### config.shard_name_from_tenant

A method to extract tenant's shard database.

## Query data as usual

With the config above, you can query data from tenant normally without doing any extra work.

```rb
# frozen_string_literal: true

class OrderController < ApplicationController
  def index
    # this will get list orders from tenant
    # whose shard is extracted from `config.shard_name_from_tenant`
    orders = Order.all

    render json: {
      data: orders
    }
  end
end
```

## Access tenant info at anytime

You can get tenant info at anytime per request using `TenantRealm::CurrentTenant` which is inherited from [Rails' Current Attributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html).

```rb
# frozen_string_literal: true

class OrderController < ApplicationController
  def index
    # this will get list orders from tenant
    # whose shard is extracted from `config.shard_name_from_tenant`
    orders = Order.all

    render json: {
      data: {
        orders:,
        tenant: TenantRealm::CurrentTenant.tenant
      }
    }
  end
end
```
