# Thermos

**Always-warm Rails caching that automatically rebuilds when your models change.**

[![Gem Version](https://badge.fury.io/rb/thermos.svg)](https://badge.fury.io/rb/thermos)
[![Code Climate](https://codeclimate.com/github/athal7/thermos/badges/gpa.svg)](https://codeclimate.com/github/athal7/thermos)
![Build Status](https://img.shields.io/github/actions/workflow/status/athal7/thermos/CI.yml?branch=main)

Thermos is a Rails caching library that keeps your cache always warm by rebuilding it in the background whenever ActiveRecord models change. No more stale data, no more cold cache penalties, no more `touch: true` on all your associations.

## Features

- **Always-warm cache** — Cache is rebuilt in the background when models change
- **No stale data** — Unlike TTL-based caching, data is only as stale as your job queue latency
- **No cold cache penalties** — Cache is pre-warmed, so users never wait for expensive queries
- **No `touch` callbacks needed** — Thermos watches model dependencies automatically
- **Works with any backend** — Sidekiq, Solid Queue, Resque, or any ActiveJob adapter
- **Works with any cache store** — Redis, Memcached, Solid Cache, or any Rails cache store
- **ETag support** — Works seamlessly with HTTP caching for browser and CDN caching

## Installation

Add to your Gemfile:

```ruby
gem 'thermos'
```

Then run:

```bash
bundle install
```

## Quick Start

```ruby
# In a controller - cache is automatically rebuilt when Category or its products change
json = Thermos.keep_warm(key: "category", model: Category, id: params[:id], deps: [:products]) do |id|
  Category.includes(:products).find(id).to_json
end

render json: json
```

That's it! When any `Category` or associated `Product` is created, updated, or destroyed, Thermos automatically rebuilds the cache in the background.

## Why Thermos?

Most cache strategies have significant downsides:

| Strategy | Problem |
|----------|---------|
| **TTL-based** (expires_in) | Stale data until expiration |
| **Key-based** (cache_key) | Cold cache on first request after any change |
| **Touch callbacks** | Extra database writes on every association change |

Thermos solves all of these by rebuilding caches proactively in background jobs.

> "I just want to Thermos everything now!! Unbelievable improvement. It's like every dev's dream come true" — [@jono-booth](https://github.com/jono-booth)

## Prerequisites

Configure a [Rails Cache Store](https://guides.rubyonrails.org/caching_with_rails.html#configuration) that supports shared access across processes (Redis, Memcached, Solid Cache — not MemoryStore).

Thermos works with any ActiveJob adapter, including Rails 8's [Solid Queue](https://github.com/rails/solid_queue) and [Solid Cache](https://github.com/rails/solid_cache).

## Usage

### keep_warm (Simple)

With `keep_warm`, the cached content is defined along with the cache block and dependencies definition. This is the simplest implementation, *but is only compatible with the [Active Job Inline Adapter](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/InlineAdapter.html)*. See the next section about fill/drink for compatibility with other Active Job Adapters.

*API Controller*

```ruby
json = Thermos.keep_warm(key: "api_categories_show", model: Category, id: params[:id], deps: [:category_items, :products]) do |id|
  Category.find(id).to_json
end

render json: json
```

*Frontend Controller*

```ruby
rendered_template = Thermos.keep_warm(key: "frontend_categories_show", model: Category, id: params[:id], deps: [:category_items, :products]) do |id|
  @category = Category.includes(category_items: :product).find(id)
  render_to_string :show
end

render rendered_template
```

### fill / drink (Advanced)

For more control, define your cache once with `fill` and read it anywhere with `drink`. This is ideal for sharing cached data across multiple controllers or when using background job adapters other than inline.

*Rails Initializer*

```ruby
Thermos.fill(key: "api_categories_show", model: Category, deps: [:category_items, :products]) do |id|
  Category.find(id).to_json
end
```

*API Controller*

```ruby
json = Thermos.drink(key: "api_categories_show", id: params[:id])
render json: json
```

## Options

### lookup_key

If you want to be able to lookup by a key other than `id` (e.g. you use a slug in the params), you can specify the `lookup_key` as an argument to `keep_warm` or `fill`:

```ruby
Thermos.keep_warm(key: "api_categories_show", model: Category, id: params[:slug], lookup_key: :slug) do |slug|
  Category.find_by(slug: slug).to_json
end
```

or

```ruby
Thermos.fill(key: "api_categories_show", model: Category, lookup_key: :slug) do |slug|
  Category.find_by(slug: slug).to_json
end
```

### queue

If you want to specify a queue for the refill jobs to run other than the default queue, you can provide it to either way of using Thermos:

```ruby
Thermos.keep_warm(key: "api_categories_show", model: Category, queue: "low_priority") do |id|
  Category.find(id).to_json
end
```

or

```ruby
Thermos.fill(key: "api_categories_show", model: Category, queue: "low_priority") do |id|
  Category.find(id).to_json
end

Thermos.drink(key: "api_categories_show", id: params[:slug])
```

### Indirect Relationships

You can specify indirect relationships as dependencies as well. For example, if `Store has_many categories`, and `Category has_many products`, but there is no relationship specified on the `Store` model to `Product`:

```ruby
Thermos.keep_warm(key: "api_stores_show", model: Store, id: params[:id], deps: [categories: [:products]]) do |id|
  Store.find(id).to_json
end
```

*NOTE* in this example, a change to any model in the association chain will trigger a refill of the cache.

### filter

You can provide a filter to restrict whether a record gets rebuilt on model changes:

```ruby
filter = ->(model) { model.name.match("ball") }
Thermos.keep_warm(key: "api_categories_show", model: Category, id: params[:id], filter: filter) do |id|
  Category.find(id).to_json
end
```

## Using with ETags

Thermos works seamlessly with Rails' HTTP caching via ETags, enabling browser and CDN caching of your responses. Since Thermos keeps your cache always warm and rebuilds it when models change, the cached value's digest will naturally change when the underlying data changes.

Use Rails' `stale?` helper with the cached value to enable conditional GET requests:

```ruby
def show
  json = Thermos.drink(key: "api_categories_show", id: params[:id])

  if stale?(etag: json)
    render json: json
  end
end
```

When the cached value changes (triggered by model updates), the ETag will change, and clients will receive the new content. When the value hasn't changed, clients with a matching ETag will receive a `304 Not Modified` response.

This enables caching at multiple layers:
- **Browser cache**: Browsers store responses and revalidate with the server using the ETag, avoiding re-downloads of unchanged content
- **CDN cache**: CDNs can cache responses and serve them directly to users, only revalidating with your server when needed

Combined with Thermos, you get:
- **Always-warm application cache** (no cold cache penalties)
- **Reduced server load** (304 responses skip rendering)
- **Reduced bandwidth** (browsers and CDNs serve cached content)
- **Faster responses** (CDN edge locations serve content closer to users)

## Contributors

<a href="https://github.com/athal7/thermos/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=athal7/thermos" />
</a>

## License

This project uses MIT-LICENSE.