module FixturePath
  def fixture_path(file_name)
    File.join("spec/fixtures", file_name)
  end
end

RSpec.configure do |config|
  config.include FixturePath
end