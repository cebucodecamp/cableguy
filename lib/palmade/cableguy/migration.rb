module Palmade::Cableguy
  class Migration
    attr_reader :cabler
    attr_reader :db
    attr_reader :cabling_path

    def self.use_klass_stack(klass_stack)
      @@klass_stack = klass_stack
      ret = yield
      @@klass_stack = nil
      klass_stack
    end

    def self.inherited(subclass)
      if defined?(@@klass_stack) && !@@klass_stack.nil?
        @@klass_stack << subclass
      end
    end

    def initialize(cabler)
      @cabler = cabler
      @db = cabler.db
      @cabling_path = cabler.cabling_path
    end

    protected

    def set(key, value, set = nil)
      db.set(key, value, set)
    end

    def update(key, value)
      db.update(key, value)
    end

    def get(key)
      db.get(key)
    end

    def group(group, &block)
      db.group(group, &block)
    end

    def globals(&block)
      db.globals(&block)
    end

    def prefix(prefix, &block)
      db.prefix(prefix, &block)
    end

    def delete_key(key, group = nil)
      db.delete_key(key, group)
    end

    def values
      cabler.values
    end

    def pre_migrate; end

    def post_migrate; end

    def migrate!
      raise "class %s doesn't have a migrate! method. Override!" % self.class.name
    end
  end
end
