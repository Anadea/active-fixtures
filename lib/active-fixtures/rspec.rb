Dir[Rails.root.join('spec/active_fixtures/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ActiveFixtures::Session::Helper

  config.around do |example|
    ActiveFixtures.prepare!(:default)
    example.run
  end
end
