Dir[Rails.root.join('spec/active_fixtures/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ActiveFixtures::Session::Helper

  config.before do
    ActiveFixtures.prepare!(:default)
  end
end
