require "yaml"

module TypedEnvConfig
  VERSION = "0.1.0"

  # when there's any error whatsoever on loading the config
  class LoadError < Exception
  end

  # when the key has never been assigned value
  class KeyError < Exception
  end

  @values = Hash(String, Nil | Bool | Float32 | Float64 | String).new
  @@default_values = {} of String => Nil | Bool | Float32 | Float64 | String

  # define a field
  macro field(decl, default)
    {% if decl.var.stringify.ends_with?("?") %}
      {% decl.raise "You cannot define a setting ending with '?' like `#{decl.var}'" %}
    {% end %}

    @@default_values[{{ decl.var.stringify }}] = {{ default }}

    def {{ decl.var }}=(value : {{ decl.type }})
      key = {{ decl.var.stringify }}
      @values[key] = value
    end

    # test
    def {{ decl.var }} : {{ decl.type }}
      key = {{ decl.var.stringify }}

      if @values.has_key?(key)
        val = @values[key]
        {% if decl.type.stringify == "Bool" %}
          val == "true" || val == "True" || val == "TRUE" ||
          val == "y" || val == "Y" || val == "yes" || val == "Yes" || val == "YES" ||
          val == "on" || val == "On" || val == "ON"
        {% elsif decl.type == String %}
          val.as({{ decl.type }})
        {% else %}
          val.as({{ decl.type }})
        {% end %}
      else
        @@default_values[key].as({{ decl.type }})
      end
    end
  end

  macro included
    # load a yaml file, if the file doesn't exist, we will raise an error;
    # if there's any error, we'll raise any error too!
    def self.load_from_yaml_file!(file : String, environment : String)
      config = self.new
      yml_path = File.expand_path(file)

      if File.exists?(yml_path)
        content = File.read(yml_path)
        parsed_content = YAML.parse(content)
        config.load_from_yaml(parsed_content, environment)
      else
        raise LoadError.new("Cannot load configuration file: #{file}; file doesn't exist")
      end

      return config
    rescue e : ::YAML::ParseException | ::KeyError
      raise LoadError.new(e.message)
    end
  end

  def load_from_yaml(yaml : YAML::Any, environment : String)
    assign_values_from_yaml(yaml[environment], "")
  end

  private def assign_values_from_yaml(yaml : YAML::Any, prefix = "")
    case raw = yaml.raw
    when Hash
      raw.each do |key, value|
        env_key = "#{prefix}_#{key.to_s}".lchop("_")
        assign_values_from_yaml(value, env_key)
      end
    else
      unless prefix.empty?
        value = raw.to_s
        variable_name = prefix

        @values[prefix] = value
      end
    end
  end
end
