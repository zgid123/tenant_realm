# frozen_string_literal: true

namespace :tenant_realm do
  desc 'Migrate db for all tenants'
  task migrate: :environment do
    tenants = TenantRealm::Tenant.tenants

    tenants.each do |tenant|
      shard = TenantRealm::Utils.shard_name_from_tenant(tenant:)

      puts "Migrating #{shard}"

      db_config = TenantRealm::Utils.dig_db_config(tenant:)

      if db_config.blank?
        puts "Skip Migrating #{shard}"

        next
      end

      db_config = TenantRealm::DbContext.root_db_config.merge(
        database: db_config[:database]
      )

      ActiveRecord::Tasks::DatabaseTasks.with_temporary_connection(db_config) do
        ActiveRecord::Tasks::DatabaseTasks.migrate
      end
    end
  end
end
