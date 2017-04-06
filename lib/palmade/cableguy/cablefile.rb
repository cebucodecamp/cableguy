require 'pathname'

module Palmade::Cableguy
  class Cablefile < Configurator
    include Constants

    attr_reader :setups

    attr_reader :file_path
    attr_reader :app_root

    def self.parse!(cabler)
      klass = Class.new(self)
      klass.new(cabler).parse!
    end

    def initialize(*args)
      super

      @cabler = args[0]
      @app_root = @cabler.app_root

      @file_path = nil
      @setups = [ ]
    end

    def parse!
      unless @app_root.nil?
        @file_path = File.join(@app_root, cablefile_name)

        unless File.exists?(file_path)
          @file_path = nil
        end
      end

      if @file_path.nil?
        @file_path = find_cable_file
      end

      unless File.exists?(@file_path)
        legacy_file_path = File.join(@app_root, legacy_cablefile_name)
        if File.exists?(legacy_file_path)
          @file_path = legacy_file_path
        end
      end

      if File.exists?(@file_path)
        configure_from_file(@file_path)
      end

      self
    end

    def cabling(*args, &block)
      if block_given?
        update_section(:cabling, *args, &block)
      else
        call_section(:cabling, *args)
      end
    end
    alias :setup_cabling :cabling

    def setup(what, *args, &block)
      @setups.push([ what, args, block ])
    end

    def requirements(*args, &block)
      if block_given?
        update_section(:requirements, *args, &block)
      else
        call_section(:requirements, *args)
      end
    end

    def configured?
      @sections.include?(:cabling)
    end

    protected

    def legacy_cablefile_name
      DEFAULT_LEGACY_CABLEFILE_NAME
    end

    def cablefile_name
      DEFAULT_CABLEFILE_NAME
    end

    def find_cable_file
      found = nil
      pname = Pathname.new(@app_root)

      pname.ascend do |path|
        if File.exists?(File.join(path, cablefile_name))
          found = path
          break
        end
      end

      unless found.nil?
        @app_root = found.to_path
      end

      @file_path = File.join(@app_root, cablefile_name)
    end
  end
end
