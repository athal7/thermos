# Thermos

[![Gem Version](https://badge.fury.io/rb/thermos.svg)](https://badge.fury.io/rb/thermos)
[![Code Climate](https://codeclimate.com/github/athal7/thermos/badges/gpa.svg)](https://codeclimate.com/github/athal7/thermos)
![Build Status)](https://img.shields.io/github/workflow/status/athal7/thermos/CI/main)

Thermos is a library for caching in rails that re-warms caches in the background based on model changes.

## Why Do I Need Thermos?

Most cache strategies require either time-based or key-based expiration. These strategies have some downsides:

*Time-based expiration:*

- Stale data

*Key-based expiration:*

- Have to look up the record to determine whether the cache is warm, AND then might need to load more records in a cold cache scenario. Might have to balance cold vs warm cache performance as it pertains to eager loading records.
- Associated model dependencies need to 'touch' the primary model, meaning more database writes to other tables when changes are made.

*Both:*

- Potentially expensive cold-cache operations, people sometimes mitigate this with denormalization, which has it's own cache-related problems.

With Thermos, the cache-filling operation is performed in the background, by observing model (and dependent model) changes.

*Thermos benefits:*

- Always warm cache
- No need to 'touch' models to keep key-based cache up to date
- Cache is only as stale as your background workers' latency
- No need to worry about slow cold-cache operations (unless your cache store fails)

## Examples

In these examples any changes to a category, it's category items, or it's products will trigger a rebuild of the cache for that category.

### keep_warm

With `keep_warm`, the cached content is defined along with the cache block and dependencies definition.

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

### fill / drink

With `fill` and `drink` the cache definition can be in one place, and the response can be used in multiple other places. This is useful if you share the same response in multiple controllers, and want to limit your number of cache keys. Even in the unlikely occurrence of a cache store failure and therefore cache miss, drink can still build up your desired response from the block that was originally defined in `fill`.

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

## Other options

- If you want to be able to lookup by a key other than `id` (e.g. you use a slug in the params), you can specify the `lookup_key` as an argument to `keep_warm` or `fill`:

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

Thermos.drink(key: "api_categories_show", id: params[:slug])
```

## Contributing

Contributions are encouraged! Just fork it, make your change, and submit a pull request.

This project rocks and uses MIT-LICENSE.
