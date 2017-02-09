module ActiveFixtures
  class Time < Resource

    module Helper
      def af_time(name)
        moment = Time[name].moment

        block_given? ?
          Timecop.freeze(moment){ yield } :
          moment
      end
    end

    attribute :moment, type: DateTime
  end
end
