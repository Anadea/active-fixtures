require 'active-fixtures/version'

module ActiveFixtures
  autoload :Resource, 'active-fixtures/resource'

  autoload :Session, 'active-fixtures/session'
  autoload :StateBuilder, 'active-fixtures/state_builder'
  autoload :State, 'active-fixtures/state'

  mattr_accessor :state_builders
  self.state_builders = {}

  class << self
    def populate(name, &block)
      state_builders[name] = StateBuilder.new(block)
    end

    def prepare!(name)
      self.current_state = State.new(name)
      current_state.prepare!(state_builders[name])
    end

    def thread_storage
      Thread.current[:__active_fixtures] ||= {}
    end

    def current_state
      thread_storage[:current_state]
    end

    def current_state=(state)
      thread_storage[:current_state] = state
    end

  end
end
