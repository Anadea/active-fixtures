ActiveFixtures
==============
[![Version](https://badge.fury.io/rb/active-fixtures.svg)](http://badge.fury.io/rb/active-fixtures)

ActiveFixtures provides the way how to populate the server state (DB, sessions) as an application user but not as programmer.

## Why?
The correct question is `why we write the tests at all?`.
Or even better - `what does the green line means?`.

Typical legacy code contains a tons of tests in isolation aka Unit Tests.
Mocks, stubs, factories & terrible traits, fakers etc etc.
Many smart things, so called `best practices`, a lot of efforts and time spent to write all of these.

And, after all - application just can't run due to the simple misspelling in `routes.rb`.

So, what is a really valuable reason to write the tests?

We working on the project for somebody personal.
We creating the web application for web users, we write the new cool library for other programmers.
The primary goal of automatic tests is to be sure that `our code works right like the target user expects`.

Test web application as web user plays with it.
Test the public methods of your library just like other programmer will use them.
Test web service endpoints just like the third-party applications will call them.

Nobody interested how exactly working the private methods in `Product` class.
Even more, nobody interested to know that class `Product` exists, it mapped to some database table etc.

Single thing is matter - how the application's user thinking about your application,
which entities he understand, how he affects to such entities.

In general case, tests in isolation are at least useless, at max - hurtful.
Lets write acceptance tests instead!

## Requirements
Currently works with Poltergeist and PostgreSQL.

## Getting started

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'active-fixtures'
end
```

Add to your `rails_helper.rb`:
```ruby
require 'active-fixtures/rspec'
```

Add to your `.gitignore`:
```
spec/fixtures/active
```

Remove Database Cleaners from your project, ActiveFixtures will take care about database cleanup in additional.

## Usage
### Active factory definition
Lets add the active factory in `spec/active_fixtures/user.rb`:

```ruby
class AFUser < ActiveFixtures::Resource
  attribute :login, type: String, default: 'admin@lvh.me'
  attribute :password, type: String, default: 'p@ssw0rd'

  def self.create_initial(attrs = {})
    new(attrs).tap { |user|
      Rake::Task['user:create'].invoke(user.login, user.password)
      Rake::Task['user:create'].reenable
    }
  end

  def self.create(attrs = {})
    new(attrs).tap { |user|
      af_session(:admin) do
        click_on 'Admins'

        click_on 'Invite'
        fill_in 'Email', with: user.login
        click_on 'Send an invitation'
      end

      af_session do
        open_email(user.login)

        current_email.click_on 'Accept invitation'
        fill_in 'Password', with: user.password
        fill_in 'Password confirmation', with: user.password
        click_on 'Set my password'
        assert_text 'Your password was set successfully. You are now signed in.'
      end
    }
  end

  def sign_in
    visit '/'
    fill_in 'Email', with: login
    fill_in 'Password', with: password
    click_on 'Sign in'
    assert_text 'Signed in successfully.'
  end

end
```

Implement the resource factory just like the application user will do -
capybara steps, rake tasks invocation, API calls etc.

Any methods available in `it` rspec context will be available in the factory
(for example `open_email` helper from `capybara-email` gem).

`ActiveFixtures::Resource` includes the [ActiveAttr::Model](https://github.com/cgriego/active_attr),
feel free to use any it's features.

`af_session` helper called without parameter will provide the clean capybara session on each call.
Use it in factory to avoid the influence to rspec's example default session.

`af_session` with parameter is a bit tricky, lets recall it later.

Now you can use factory in your tests:
```ruby
describe 'Users' do
  let(:admin) { AFUser.create_initial }

  it 'should pass' do
    admin.sing_in
  end
end
```

### Fixtures definition
Lets define active fixture in `spec/active_fixtures/_fixtures.rb`:

```ruby
ActiveFixtures.populate(:default) do
  resource(:admin) { AFUser.create_initial }
  session(:admin) { AFUser[:admin].sign_in }
  resource(:invited_admin) { AFUser.create(login: 'new_user@lvh.me') }
end
```

`:default` fixture will be loaded before each rspec example. You can play with resources like that:
```ruby
it 'should pass' do
  AFUser[:invited_admin].sign_in
end
```

### Active sessions
Once you defined the named session in factory, you can use it by `af_session` helper:
```ruby
it 'should pass' do
  af_session(:admin) do
    # already logged as admin
  end

  # some code
  af_session(:admin) do
    # second and any further `af_session` call within the same example
    # will drop the session to the state reached right after the session initialization
    # - same current URL, same cookies. This way you don't need to keep in mind
    # what you did with named session before, but can expect the same session state each time.
  end

  af_session do
    # always clean session, with blank current URL
  end
end
```

### How it works
ActiveFixtures work fairly, but effectively.

Fixture will be populated on the first it's usage, by genuine application's user actions.
For the next example it will be loaded from cache - no sense to to the same work again.

In case when you affecting the fixture creation process
(making changes in fixtures, related application functionality, DB schema etc),
you need to clean the fixtures cache manually before the tests run:
```console
  $ rake active_fixtures:clean
```

## License
MIT License. Copyright (c) 2016 Sergey Tokarenko
