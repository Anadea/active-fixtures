module ActiveFixtures
  class Session < Resource
    CLEAN_NAME = :__clean

    module Helper
      def af_session(name = CLEAN_NAME, &block)
        Session[name].perform(block)
      end
    end

    attribute :name, type: String, default: CLEAN_NAME
    attribute :url, type: String
    attribute :cookies, type: Object, default: []

    def initialize(attrs = {})
      super

      if attrs[:block]
        using_session do
          attrs[:block].call

          self.url = context.current_url
          self.cookies = context.page.driver.cookies.values.map{ |c| c.instance_variable_get(:@attributes).symbolize_keys}
        end
      end
    end

    def perform(block)
      res = nil

      using_session do
        context.reset_session!
        cookies.each do |cookie|
          context.page.driver.set_cookie(nil, nil, cookie)
        end
        context.visit(url) if url
        res = block.call
      end

      res
    end

    private

    def using_session(&block)
      context.using_session("__af::#{name}", &block)
    end
  end
end
