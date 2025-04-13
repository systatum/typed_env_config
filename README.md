# typed_env_config

![ci badge](https://github.com/github/docs/actions/workflows/main.yml/badge.svg?event=push)

`typed_env_config` is a Crystal library for loading environment configurations/variables with type safety.
We do so without cluttering the `ENV` variable.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     typed_env_config:
       github: systatum/typed_env_config
   ```

2. Run `shards install`

## Usage

First, define a configuration class. It must include `TypedEnvConfig`.

```crystal
class AppSettings
  include TypedEnvConfig

  field ligo_app_cors_whitelist : String, default: ""
  field ligo_undefined_key : String, default: "undefined"
end
```

Given the following configuration file aptly named `app_settings.yml`:

```yaml
default: &default
  outwardly_inherited: true

  ligo:
    app: &ligo_app
      cors_whitelist: "*"
      deeply_inherited: true


production:
  <<: *default

  ligo:
    app:
      <<: *ligo_app
      cors_whitelist: "https://systatum.com"

development:
  <<: *default

  ligo:
    app:
      <<: *ligo_app
```

We can then load the configuration from a YAML file in this way:

```crystal
dev_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "development")
dev_config.ligo_app_cors_whitelist
```

Easy, and type-safe!

## Contributing

1. Fork it (<https://github.com/systatum/typed_env_config/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

Create with ⸜(｡˃ ᵕ ˂ )⸝♡ at Systatum.
