module ActiveFixtures
  module StateDumper
    FIXTURES_PATH = Rails.root.join('spec/fixtures/active').freeze
    DB_NAME = Rails.configuration.database_configuration[Rails.env]['database'].freeze
    CLEAN_STATE_NAME = :__clean

    class << self
      def init!
        FileUtils.mkdir_p(FIXTURES_PATH)
        dump_db(CLEAN_STATE_NAME)
      end

      def cleanup!
        load_clean
        FileUtils.rm_rf(FIXTURES_PATH) if File.exist?(FIXTURES_PATH)
      end

      def exists?(state_name)
        File.exists?(dump_db_file(state_name))
      end

      def load_clean
        load_db(CLEAN_STATE_NAME)
      end

      def load(state_name)
        load_db(state_name)

        Hash[*JSON.parse(File.read(dump_entities_file(state_name))).flat_map{ |name, attrs|
          [name, name.gsub(/::[^:]*\z/, '').constantize.new(attrs)]
        }]
      end

      def dump(state)
        dump_db(state.name)
        File.write(
          dump_entities_file(state.name),
          Hash[*state.entities.flat_map{ |name, entity|
            [name, entity.attributes]
          }].to_json
        )
      end

      private

      def dump_db_file(state_name)
        File.join(FIXTURES_PATH, "#{state_name}.db.dump")
      end

      def dump_entities_file(state_name)
        File.join(FIXTURES_PATH, "#{state_name}.entities.json")
      end

      def dump_db(state_name)
        args = ['-x', '-O', '-c', '-Fc', '-f', dump_db_file(state_name), DB_NAME]
        Kernel.system('pg_dump', *args)
      end

      def load_db(state_name)
        args = ['-c', '-d', DB_NAME, dump_db_file(state_name)]
        Kernel.system('pg_restore', *args)
      end

    end

  end
end
