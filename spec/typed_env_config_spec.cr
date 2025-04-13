require "./spec_helper"

class AppSettings
  include TypedEnvConfig

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
    it "parses value correctly as per environment" do
      dev_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "development")
      prod_config = AppSettings.load_from_yaml_file!("spec/fixtures/app_settings.yml", "production")

      dev_config.ligo_app_cors_whitelist.should eq("*")
      prod_config.ligo_app_cors_whitelist.should eq("https://systatum.com")
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
