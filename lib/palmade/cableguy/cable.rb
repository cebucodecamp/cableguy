module Palmade::Cableguy
  class Cable
    attr_reader :args

    @@builders = { }
    def self.builders
      @@builders
    end

    def self.add_as(key, klass = nil)
      builders[key] = klass || self
    end

    def self.build_key(klass = nil)
      builders.index(klass || self)
    end

    def self.build(what, *args, &block)
      if builders.include?(what)
        builders[what].new(*args, &block)
      else
        raise ArgumentError, "Unknown builder: #{what} -- supports: #{supported_builders.join(', ')}"
      end
    end

    def self.supported_builders
      builders.keys
    end

    def initialize(*args, &block)
      @args = args
      @block = block
    end

    def configure(cabler, &block)
      puts "Not implemented: #{self.class.build_key}"
    end
  end
end
