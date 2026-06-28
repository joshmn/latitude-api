# latitude-api

A Ruby client for the [Latitude.sh](https://www.latitude.sh) REST API. Covers servers, projects, virtual machines, Kubernetes clusters, storage, networking, firewalls, elastic IPs, SSH keys, teams, and more. Ships with a client for the on-instance metadata service.

Requires Ruby 3.0+. Fork it if you need lower support—should probably be fine.

## Install

```ruby
gem "latitude-api"
```

```bash
bundle add latitude-api
```

## Quickstart

```ruby
require "latitude"

Latitude.api_key = ENV.fetch("LATITUDE_API_KEY")

server = Latitude::Server.create(
  project: "proj_abc",
  plan: "c2-small-x86",
  site: "ASH",
  operating_system: "ubuntu_22_04_x64_lts",
  hostname: "web-01",
)

server.id         # => "sv_..."
server.hostname   # => "web-01"
server.status     # => "off"
server.plan.slug  # => "c2-small-x86"

server.reboot
server.lock
server.delete
```

## Configuration

```ruby
Latitude.configure do |c|
  c.api_key              = ENV.fetch("LATITUDE_API_KEY")
  c.api_base             = "https://api.latitude.sh"      # default
  c.api_version          = "2023-06-01"                   # optional, sent as API-Version header
  c.open_timeout         = 30
  c.read_timeout         = 80
  c.max_network_retries  = 2                              # retries 429/500/502/503/504 with backoff
  c.logger               = Logger.new($stdout)
end
```

Per-request overrides live in the final hash argument of any call:

```ruby
Latitude::Server.create(params, {
  api_key:         "lat_tenant_specific",
  api_version:     "2023-06-01",
  idempotency_key: "svr-create-123",
  open_timeout:    5,
})
```

So, for multi-tenant apps, use a client:

```ruby
client = Latitude::Client.new(api_key: "lat_tenant_A")
client.servers.list
client.projects.retrieve("proj_abc")
```

## Resources

All resources are under `Latitude::`:

| Resource | Class | Endpoint |
|---|---|---|
| Servers | `Latitude::Server` | `/servers` |
| Projects | `Latitude::Project` | `/projects` |
| Project SSH keys | `Latitude::Project::SSHKey` | `/projects/:project_id/ssh_keys` |
| Project user data | `Latitude::Project::UserData` | `/projects/:project_id/user_data` |
| SSH keys | `Latitude::SSHKey` | `/ssh_keys` |
| User data | `Latitude::UserData` | `/user_data` |
| Tags | `Latitude::Tag` | `/tags` |
| Teams | `Latitude::Team` | `/team` |
| Team members | `Latitude::Team::Member` | `/team/members` |
| API keys | `Latitude::APIKey` | `/auth/api_keys` |
| Elastic IPs | `Latitude::ElasticIP` | `/elastic_ips` |
| VLANs | `Latitude::VirtualNetwork` | `/virtual_networks` |
| VLAN assignments | `Latitude::VirtualNetwork::Assignment` | `/virtual_networks/assignments` |
| Firewalls | `Latitude::Firewall` | `/firewalls` |
| Firewall assignments | `Latitude::Firewall::Assignment` | `/firewalls/:firewall_id/assignments` |
| VPN sessions | `Latitude::VPNSession` | `/vpn_sessions` |
| Filesystems | `Latitude::Storage::Filesystem` | `/storage/filesystems` |
| Volumes | `Latitude::Storage::Volume` | `/storage/volumes` |
| Object storage | `Latitude::Storage::Object` | `/storage/objects` |
| Virtual machines | `Latitude::VirtualMachine` | `/virtual_machines` |
| Kubernetes clusters | `Latitude::KubernetesCluster` | `/kubernetes_clusters` |
| Plans | `Latitude::Plan` (+ `OperatingSystem`, `Bandwidth`, `Storage`, `VirtualMachine`) | `/plans` |
| Regions | `Latitude::Region` | `/regions` |
| Roles | `Latitude::Role` | `/roles` |
| Events | `Latitude::Event` | `/events` |
| IPs | `Latitude::IP` | `/ips` |
| Billing usage | `Latitude::BillingUsage` | `/billing/usage` |
| Traffic | `Latitude::Traffic` (+ `#quota`) | `/traffic` |
| User profile | `Latitude::User::Profile` | `/user/profile` |
| User teams | `Latitude::User::Team` | `/user/teams` |

Every full-CRUD resource supports a spooky-familiar operation surface:

```ruby
Latitude::Project.list(filter: { name: { match: "prod" } }, sort: "-created_at", page: { size: 50 })
Latitude::Project.retrieve("proj_abc")
Latitude::Project.create(name: "Payments", provisioning_type: "on_demand")
Latitude::Project.update("proj_abc", name: "Payments 2.0")
Latitude::Project.delete("proj_abc")

project = Latitude::Project.retrieve("proj_abc")
project.name = "renamed"
project.save
project.delete
```

### Filters, sort, pagination

Follows the [Latitude API filter grammar](https://docs.latitude.sh):

```ruby
Latitude::Server.list(
  filter: {
    project:  "proj_abc",
    hostname: { prefix: "web" },
    ram:      { gte: 32 },
    tags:     ["tag_prod", "tag_db"],
  },
  sort: "-created_at",
  page: { size: 50, number: 1 },
  extra_fields: { servers: "credentials" },
)
```

Auto-paginate:

```ruby
Latitude::Server.list(filter: { project: "proj_abc" }).auto_paging_each do |server|
  # ...
end

# or materialize the whole collection
Latitude::Server.all(filter: { project: "proj_abc" })
```

### Server power and maintenance actions

```ruby
server = Latitude::Server.retrieve("sv_abc")

server.reboot
server.power_on
server.power_off
server.reset

server.lock
server.unlock

server.rescue_mode
server.exit_rescue_mode

server.schedule_deletion(at: "2026-05-01T00:00:00Z", reason: "decommission")
server.unschedule_deletion

server.reinstall(
  operating_system: "ubuntu_22_04_x64_lts",
  hostname: "web-01",
  ssh_keys: ["ssh_abc"],
)

server.deploy_config
server.update_deploy_config(hostname: "web-02")

server.create_out_of_band_connection(port: 22)
server.list_out_of_band_connections
```

### Nested resources

```ruby
Latitude::Project::SSHKey.list(project_id: "proj_abc")
Latitude::Project::SSHKey.create(project_id: "proj_abc", name: "bastion", public_key: "ssh-rsa ...")

project = Latitude::Project.retrieve("proj_abc")
project.ssh_keys.create(name: "bastion", public_key: "ssh-rsa ...")
project.user_data.list
```

## Errors

Every API failure raises a typed exception:

```ruby
begin
  Latitude::Server.retrieve("sv_bogus")
rescue Latitude::NotFoundError => e
  e.http_status    # => 404
  e.code           # => "not_found"
  e.detail         # => "Specified Record Not Found"
  e.request_id     # from response header
  e.errors         # Array<APIError::Entry> with raw payloads
end
```

Hierarchy is straightforward:

- `Latitude::Error`
  - `Latitude::ConfigurationError`
  - `Latitude::ConnectionError`
  - `Latitude::APIError`
    - `Latitude::BadRequestError` (400)
    - `Latitude::AuthenticationError` (401)
    - `Latitude::PermissionError` (403) — `#feature_not_enabled?`, `#read_only_key?`
    - `Latitude::NotFoundError` (404)
    - `Latitude::ConflictError` (409)
    - `Latitude::UnprocessableEntityError` (422)
    - `Latitude::RateLimitError` (429) — `#retry_after` reads `meta.retry_after`
    - `Latitude::ServerError` (5xx)

## Rate limits

The API rate limits per API key; these are handled in the gem but you should be mindful yourself:

- Reads (GET): 60 requests/minute
- Writes (POST/PUT/PATCH/DELETE): 20 requests/minute

Set `max_network_retries` to auto-backoff across 429s; `RateLimitError#retry_after` is honored between retries.

## Versioning

As of this commit, only supports Latitude `2023-06-01`. You can override this if you want:

```ruby
Latitude.api_version = "2023-06-01"                       # global
Latitude::Server.list({}, { api_version: "2022-07-18" })  # per call
```

## Instance metadata service

One quirk I haven't decided to bake in because I don't need it (if you do, let me know and I'll do my best):

_Only_ if your code runs on a Latitude.sh bare metal server, `Latitude::Metadata` reads the on-instance metadata service (`http://169.254.169.254/metadata/v1`) using IMDSv2-style tokens. Separate from the main API—different auth, same library.

```ruby
Latitude::Metadata.hostname       # "web-01"
Latitude::Metadata.public_ipv4    # "203.0.113.10"
Latitude::Metadata.region         # "SAO"
Latitude::Metadata.tags           # [{key:, value:}, ...]
Latitude::Metadata.userdata       # cloud-init string or nil
Latitude::Metadata.all            # full metadata object

meta = Latitude::Metadata.all
meta.network.interfaces.first.addresses.first.address
```

Not reachable from outside a Latitude server. Outside that context, calls raise `Latitude::Metadata::Unavailable`.

I've thought about making a protected HTTP server expose this but I don't imagine anyone needs it that can't do it themselves.

## Development

```bash
bin/setup
bundle exec rake test
```

## Contributing

Bug reports and pull requests welcome at [github.com/joshmn/latitude-api](https://github.com/joshdotmn/latitude-api).

## License

MIT.
