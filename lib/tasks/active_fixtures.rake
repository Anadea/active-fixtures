namespace :active_fixtures do
  desc 'Clean the fixtures cache'
  task :clean do
    ActiveFixtures.cleanup!
  end
end
