# TenantRealm::CurrentTenant

This is a class stores tenant info that is inherited from [Rails' Current Attributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html). The tenant detail must be in [Hash](https://ruby-doc.org/3.1.4/Hash.html).

Sometimes, you do not want to dig too many keys whenever you access this class. To do that, you should inherit this class and override the `setter` method.

```rb
# frozen_string_literal: true

class CurrentTenant < TenantRealm::CurrentTenant
  attribute :domains,
            :db_config

  def tenant=(tenant)
    super

    self.domains = tenant[:settings][:domains].map { |domain| domain[:value] }
    self.db_config = tenant[:settings][:db_config]
  end
end
```

And then set it to the configuration:

```rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  TenantRealm.configure do |config|
    config.current_tenant = CurrentTenant
  end
end
```

You can access `domains` and `db_config` anytime now.

```rb
# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    user = User.find(params[:id])

    render json: {
      data: {
        user:,
        domains: CurrentTenant.domains
      }
    }
  end
end
```
