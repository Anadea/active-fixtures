module ActiveFixtures
  class State
    attr_accessor :name

    def initialize(_name)
      self.name = _name
    end

    def prepare!(state_builder)
      entities.clear

      clean_session = Session.new
      write_entity(clean_session.name, clean_session)

      state_builder.prepare_each do |name, resource|
        write_entity(name, resource)
      end
    end

    def read_entity(name, resource_class)
      entities[normalize_name(name, resource_class)]
    end

    private

    def write_entity(name, resource)
      entities[normalize_name(name, resource.class)] = resource
    end

    def normalize_name(name, resource_class)
      "#{resource_class.name}::#{name}"
    end

    def entities
      ActiveFixtures.thread_storage[:entities] ||= {}
    end

  end
end
