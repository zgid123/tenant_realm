# Migration

Tenant Realm already provides a rake task to run migration for all tenants.

To do that, first, create a migration like usual.

```sh
rails g migration create_users
```

Rails will create a migration file `db/migrate/202401028053950_create_users.rb`.

```rb
# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: '', index: { unique: true }
      t.string :password_digest, null: false, default: ''

      t.timestamps null: false
    end
  end
end
```

Run rake task to apply this migration to all tenants

```sh
rake tenant_realm:migrate
```

# Rollback

Tenant Realm provides a wrapper rollback for all tenants.

```sh
rake tenant_realm:rollback
```
