# frozen_string_literal: true

require_relative 'utils'
require_relative 'tenant'

module TenantRealm
  class DbContext
    # to cache all tenant's connections
    @@shards = {}

    # to cache all tenant's connections already connected
    @@connected_shards = nil

    class << self
      def root_db_config
        @@db_config ||= ActiveRecord::Base.connection_db_config.configuration_hash.deep_dup.freeze
      end

      def init_shards
        config = Utils.load_database_yml
        tenants = Tenant.tenants

        @@shards = config[Rails.env].keys.each_with_object({}) do |shard, shards|
          shards[shard] = shard
        end

        tenants.each do |tenant|
          db_config = Utils.dig_db_config(tenant:)
          shard = Utils.shard_name_from_tenant(tenant:)
          next if db_config.blank?

          add_shard(shard:, db_config:)
        end

        ActiveRecord::Base.connects_to(shards: connected_shards)
      end

      def connected_shards
        @@connected_shards ||= build_connected_shards
      end

      def add_shard(shard:, db_config:)
        return if shard_exist?(shard:) || db_config.blank?

        shard_name = shard.underscore
        config = Utils.load_database_yml
        tenant_shard_config = root_db_config.merge(database: db_config[:database])
        config[Rails.env][shard_name] = JSON.parse(tenant_shard_config.to_json)
        @@shards[shard_name] = shard_name

        # sometimes the dynamic tenant's db_config causes connection pool checkout
        # write tenants' db_config to database.yml
        # to fix this problem when restart server
        File.open('config/database.yml', 'w') do |f|
          YAML.dump(config, f)
        end

        ActiveRecord::Base.configurations.configurations << build_db_hash_config(
          shard_name,
          tenant_shard_config,
          Rails.env
        )

        sym_shard = shard_name.to_sym

        connected_shards[sym_shard] = {
          writing: sym_shard,
          reading: sym_shard
        }
      end

      def shard_exist?(shard:)
        @@shards.key?(shard.underscore)
      end

      def switch_database(shard:, db_config: nil, &block)
        add_shard(shard:, db_config:)

        ActiveRecord::Base.connected_to(shard: shard.underscore.to_sym, &block)
      end

      def flush_connection!
        ActiveRecord::Base.connection_handler.clear_active_connections!(:all)
        ActiveRecord::Base.connection_handler.flush_idle_connections!(:all)
      end

      def run_migrate(db_config:)
        ActiveRecord::Tasks::DatabaseTasks.with_temporary_connection(
          root_db_config.merge(database: db_config[:database])
        ) do
          ActiveRecord::Tasks::DatabaseTasks.migrate
        end

        false
      rescue StandardError
        flush_connection!

        true
      end

      def create_db(shard:, affix: nil)
        database = [shard, affix].compact.join('-').underscore
        db_config = root_db_config.merge(database:).tap do |config|
          config[:host] ||= 'localhost'
          config[:port] ||= 3306
        end

        ActiveRecord::Base.connection.create_database(database)

        db_config
      end

      def dump_schema(db_config:, shard:)
        return unless ActiveRecord.dump_schema_after_migration

        schema_format = ENV.fetch('SCHEMA_FORMAT', ActiveRecord.schema_format).to_sym
        ActiveRecord::Tasks::DatabaseTasks.dump_schema(
          build_db_hash_config(
            shard.to_s,
            db_config,
            Rails.env
          ),
          schema_format
        )
      end

      private

      def build_db_hash_config(shard, db_config, env_name = Rails.env)
        ActiveRecord::DatabaseConfigurations::HashConfig.new(
          env_name,
          shard,
          db_config
        )
      end

      def build_connected_shards
        @@shards.keys.each_with_object({}) do |shard, shards|
          sym_shard = shard.to_sym

          shards[sym_shard] = {
            writing: sym_shard,
            reading: sym_shard
          }
        end
      end
    end
  end
end
