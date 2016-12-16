require 'active-fixtures/version'
require 'active_attr'

module ActiveFixtures
  autoload :Resource, 'active-fixtures/resource'

  autoload :Session, 'active-fixtures/session'
  autoload :StateBuilder, 'active-fixtures/state_builder'
  autoload :State, 'active-fixtures/state'
  autoload :StateDumper, 'active-fixtures/state_dumper'

  class PrepareStateError < StandardError; end

  mattr_accessor :state_builders
  self.state_builders = {}

  class << self
    def populate(name, &block)
      state_builders[name] = StateBuilder.new(block)
    end

    def init!
      StateDumper.init!
    end

    def cleanup!
      StateDumper.cleanup!
    end

    def prepare!(name)
      raise PrepareStateError.new("Undefined active fixture: #{name.inspect}") unless state_builders.key?(name)

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
