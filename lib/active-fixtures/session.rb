module ActiveFixtures
  class Session < Resource
    module Helper
      def af_session(name, &block)
        Session[name].perform(block)
      end
    end

    attribute :name, type: String
    attribute :url, type: String
    attribute :cookies, type: Object, default: []

    def initialize(build_step)
      self.name = build_step[:name]

      using_session do
        build_step[:block].call
        self.url = context.current_url
        self.cookies = context.page.driver.cookies.values.map{ |c| c.instance_variable_get(:@attributes).symbolize_keys}
      end
    end

    def perform(block)
      using_session do
        context.reset_session!
        cookies.each do |cookie|
          context.page.driver.set_cookie(nil, nil, cookie)
        end
        context.visit url
        block.call
      end
    end

    private

    def using_session(&block)
      context.using_session("__af::#{name}", &block)
    end
  end
end
