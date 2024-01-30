# Changelogs

## v1.1.0

- add rollback rake task to rollback all tenants' migration
- public method's parameters must be as hash unless it is internal usage
- add `force_load` to `Tenant` class to force loading `tenant`/`tenant list` via external api instead of cache

**Public method's changes**

```rb
# from
TenantRealm::Tenant.tenant(params[:id])
# to
TenantRealm::Tenant.tenant(identifier: params[:id])

# from
TenantRealm::Tenant.cache_tenant(tenant)
# to
TenantRealm::Tenant.cache_tenant(tenant:)
```

**force_load usage**

```rb
# will get from cache
# if not cached, get from provided proc
TenantRealm::Tenant.tenant(identifier: params[:id])
```

```rb
# always get from provided proc
TenantRealm::Tenant.tenant(identifier: params[:id], force_load: true)
```

```rb
# will get from cache
# if not cached, get from provided proc
TenantRealm::Tenant.tenants
```

```rb
# always get from provided proc
TenantRealm::Tenant.tenants(force_load: true)
```

**Full Changelog**: https://github.com/zgid123/tenant_realm/compare/v1.0.2...v1.1.0

## v1.0.2

- `rake tenant_realm:migrate` will run migration for `primary` shard and dump schema for primary (`schema.rb`)
- always use `primary` shard if no tenant
- only cache tenant if not nil

**Full Changelog**: https://github.com/zgid123/tenant_realm/compare/v1.0.0...v1.0.2
