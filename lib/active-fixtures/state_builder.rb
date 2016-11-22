module ActiveFixtures
  class StateBuilder
    attr_accessor :steps

    def initialize(block)
      self.steps = []
      instance_eval(&block)
    end

    def prepare_each
      steps.each do |build_step|
        yield(
          build_step[:name],
          send("build_#{build_step[:type]}", build_step)
        )
      end
    end

    private

    def resource(name, &block)
      steps << {type: :resource, name: name, block: block}
    end

    def session(name, &block)
      steps << {type: :session, name: name, block: block}
    end

    def build_resource(build_step)
      build_step[:block].call
    end

    def build_session(build_step)
      Session.new(build_step)
    end
  end
end
