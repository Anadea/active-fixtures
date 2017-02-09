module ActiveFixtures
  class Resource
    extend Context
    include ActiveAttr::Model

    def self.[](name)
      ActiveFixtures.current_state.read_entity(name, self)
    end

  end
end
