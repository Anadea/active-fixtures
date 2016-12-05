Dir[Rails.root.join('spec/active_fixtures/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include ActiveFixtures::Session::Helper

  config.around(:each) do |example|
    ActiveFixtures.prepare!(:default)
    example.run
  end

  config.before(:all) do
    ActiveFixtures.init!
  end

  config.after(:all) do
    ActiveFixtures.cleanup!
  end

end
