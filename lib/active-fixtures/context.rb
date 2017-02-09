module ActiveFixtures
  module Context

    def self.extended(klass)
      klass.instance_eval do
        delegate :context, to: :class
        define_method(:method_missing, &method(:method_missing))
      end
    end

    def context
      RSpec.current_example.example_group_instance
    end

    def method_missing(method, *args, &block)
      context.respond_to?(method) ?
        context.public_send(method, *args, &block) :
        super
    end

  end
end
