# frozen_string_literal: true

namespace :tenant_realm do
  desc 'Rollback db for all tenants'
  task rollback: :environment do
    tenants = TenantRealm::Tenant.tenants

    puts 'Rollback primary'
    Rake::Task['db:rollback:primary'].invoke
    Rake::Task['db:rollback:primary'].reenable

    tenants.each do |tenant|
      shard = TenantRealm::Utils.shard_name_from_tenant(tenant:)

      puts "Rollback #{shard}"

      db_config = TenantRealm::Utils.dig_db_config(tenant:)

      if db_config.blank?
        puts "Skip Rollback #{shard}"

        next
      end

      Rake::Task["db:rollback:#{shard}"].invoke
      Rake::Task["db:rollback:#{shard}"].reenable
    end
  end
end
