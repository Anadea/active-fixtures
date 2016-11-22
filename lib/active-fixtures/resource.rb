module ActiveFixtures
  class Resource
    include ActiveAttr::Model

    delegate :context, to: :class

    def self.[](name)
      ActiveFixtures.current_state.read_entity(name, self)
    end

    private

    def self.context
      RSpec.current_example.example_group_instance
    end

    def self.method_missing(method, *args, &block)
      context.respond_to?(method) ?
        context.public_send(method, *args, &block) :
        super
    end

    define_method(:method_missing, &method(:method_missing))
  end
end
