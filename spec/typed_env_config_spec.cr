require "./spec_helper"

class AppSettings
  include TypedEnvConfig

  field small_number : Int32, default: 0
  field outwardly_inherited : Bool, default: false
  field ligo_app_cors_whitelist : String, default: ""
  field ligo_undefined_key : String, default: "undefined"
end

describe TypedEnvConfig do
  context "when loading undefined environment" do
    it "raises a LoadError" do
      expect_raises(TypedEnvConfig::LoadError) do
        AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "undefined")
      end
    end
  end

  context "fetching set variables" do
    it "parses String value correctly as per environment" do
      dev_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "development")
      prod_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "production")

      dev_config.ligo_app_cors_whitelist.should eq("*")
      prod_config.ligo_app_cors_whitelist.should eq("https://systatum.com")
    end

    it "parses Boolean value correctly as per environment" do
      truthy_values = ["true", "\"true\"", "True", "TRUE", "y", "Y", "yes", "Yes", "YES", "on", "On", "ON"]

      truthy_values.each do |truthy_value|
        yaml_content = <<-YAML
          development:
            outwardly_inherited: false
          production:
            outwardly_inherited: #{truthy_value}
        YAML
        parsed_content = YAML.parse(yaml_content)

        dev_config = AppSettings.new
        dev_config.load_from_yaml(parsed_content, "development")
        prod_config = AppSettings.new
        prod_config.load_from_yaml(parsed_content, "production")

        dev_config.outwardly_inherited.should eq(false)
        prod_config.outwardly_inherited.should eq(true)
      end
    end

    it "parses Int32 values correctly as per environment" do
      yaml_content = <<-YAML
        development:
          small_number: 2147483647
        production:
          small_number: -2147483648
      YAML
      parsed_content = YAML.parse(yaml_content)

      dev_config = AppSettings.new
      dev_config.load_from_yaml(parsed_content, "development")
      prod_config = AppSettings.new
      prod_config.load_from_yaml(parsed_content, "production")

      dev_config.small_number.should eq(2147483647)
      prod_config.small_number.should eq(-2147483648)
    end
  end

  context "fetching unset variables" do
    it "returns default value" do
      dev_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "development")
      prod_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "production")

      dev_config.ligo_undefined_key.should eq("undefined")
      prod_config.ligo_undefined_key.should eq("undefined")
    end
  end
end
