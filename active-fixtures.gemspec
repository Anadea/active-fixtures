lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active-fixtures/version'

Gem::Specification.new do |s|
  s.name        = 'active-fixtures'
  s.version     = ActiveFixtures::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = 'Sergey Tokarenko'
  s.email       = 'private.tokarenko.sergey@gmail.com'
  s.homepage    = 'https://github.com/Anadea/active-fixtures'
  s.summary     = %q{active-fixtures provides the way how to populate the server state
                    (DB, sessions) as an application user but not as programmer.}
  s.description = s.summary
  s.license     = 'MIT'

  s.files       = Dir['{lib}/**/*', 'LICENSE', 'README.md']
  s.test_files  = Dir['{spec}/**/*']

  s.required_ruby_version = '>= 2.3.1'

  s.add_dependency 'rails', '>= 4.2'
  s.add_dependency 'active_attr'
  s.add_dependency 'timecop'
end
