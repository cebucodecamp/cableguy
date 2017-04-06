require 'logger'

module Palmade::Cableguy
  class Cabler
    include Constants
    include CliHelper

    APP_CABLING_PATH = 'cabling'

    DEFAULT_OPTIONS = {
      :target => :development,
      :location => nil,
      :path => nil,
      :values_path => nil,
      :apply_path => nil,
      :templates_path => nil,
      :logger => nil,
      :save_db => false,
      :unload_cabling => true,
      :include_global_cabling => false
    }

    attr_reader :app_root
    attr_reader :app_group
    attr_reader :options

    attr_reader :cabling_path
    attr_reader :app_cabling_path
    attr_reader :target
    attr_reader :location
    attr_reader :apply_path

    attr_reader :values_path
    attr_reader :cabling_values
    attr_reader :templates_path

    attr_reader :cablefile
    attr_reader :db
    attr_reader :save_db
    attr_reader :logger

    attr_reader :builds
    attr_reader :migrator
    attr_reader :app_migrator

    def initialize(app_root, options = { })
      @options = DEFAULT_OPTIONS.merge(options)
      @app_root = app_root
      @app_group = nil

      @cabling_path = @options[:path]
      @app_cabling_path = File.join(@app_root, APP_CABLING_PATH)

      @target = @options[:target]
      @location = @options[:location]

      unless @options[:apply_path].nil?
        @apply_path = File.expand_path(@options[:apply_path])
      end

      @values_path = @options[:values_path]
      @cabling_values = nil

      @cablefile = nil

      if @options[:templates_path].nil?
        @templates_path = File.join(@app_root, DEFAULT_TEMPLATES_PATH)
      else
        @templates_path = File.expand_path(@options[:templates_path])
      end

      if options[:logger]
        @logger = options[:logger]
      else
        @logger = create_logger
      end

      @db = nil
      @save_db = nil
      @builds = nil

      @migrator = nil
      @app_migrator = nil
    end

    def boot
      if @options[:verbose]
        @logger.level = Logger::DEBUG
      else
        @logger.level = Logger::WARN
      end

      expand_cabling_path!

      @save_db = determine_save_db
      @db = Palmade::Cableguy::DB.new(self, { :save_db => @save_db }).boot

      load_cabling_values
      load_cablefile

      self
    end

    def set_app_group(g)
      # normalize group key, to be consistent everywhere
      g = g.to_s unless g.is_a?(String)

      @db.group(g)
      @app_group = g
    end
    alias :group= :set_app_group

    def values
      unless @cabling_values.nil?
        @cabling_values.values
      else
        nil
      end
    end

    def determine_apply_path(opts = { })
      if @apply_path.nil?
        ap = @app_root
      else
        ap = @apply_path
      end

      if opts[:for_templates]
        File.join(ap, DEPRECATED_DEFAULT_TARGET_PATH)
      else
        ap
      end
    end

    def configure
      unless @db.migrated?
        migrate
      end

      if @db.empty?
        raise 'Empty config data from [%s], did you provide some cabling data?' % @cabling_path
      end

      if @cablefile.configured?
        check_requirements
        builds = build_setups
        builds.each do |s|
          s.configure(self)
        end
      else
        raise 'Cablefile not configured or not loaded, configure will not work!'
      end

      self
    end

    def migrate
      cabling_paths = determine_useable_cabling_paths

      unless cabling_paths.empty?
        cabling_paths.each do |cp|
          perform_migrate(cp)
        end
      end

      @db.migrated!

      self
    end

    def app_migrate
      @db.prepare_for_use

      unless @app_cabling_path.nil?
        if File.exist?(@app_cabling_path)
          perform_migrate(@app_cabling_path)
        end
      end

      self
    end

    def cabling_migrate
      @db.prepare_for_use

      unless @cabling_path.nil?
        if @cabling_path != @app_cabling_path && File.exists?(@cabling_path)
          perform_migrate(@cabling_path)
        end
      end

      self
    end

    def remigrate
      if @db.migrated?
        @db.reset
      end

      migrate
    end

    protected

    def perform_migrate(cp)
      @db.prepare_for_use

      if !cp.nil? && File.exists?(cp)
        @migrator = Palmade::Cableguy::Migrator.boot(self, cp, :unload_cabling => @options[:unload_cabling])
        @migrator.run!
      end

      @migrator
    end

    def determine_useable_cabling_paths
      cabling_paths = [ ]

      if !@app_cabling_path.nil? && File.exist?(@app_cabling_path)
        cabling_paths << @app_cabling_path
      end

      if cabling_paths.empty? || @options[:include_global_cabling]
        if !@cabling_path.nil? && @cabling_path != @app_cabling_path && File.exists?(@cabling_path)
          cabling_paths << @cabling_path
        end
      end

      cabling_paths
    end

    def expand_cabling_path!
      unless @cabling_path.nil?
        cpath = File.expand_path(@cabling_path)

        loop do
          if File.symlink?(cpath)
            cpath = File.readlink(cpath)
          else
            break
          end
        end

        @cabling_path = cpath
      end

      @cabling_path
    end

    def determine_save_db
      save_db = nil

      if @options[:save_db]
        if @options[:save_db] === true
          use_cabling_path = nil

          cabling_paths = determine_useable_cabling_paths
          unless cabling_paths.empty?
            use_cabling_path = cabling_paths.first
          end

          unless use_cabling_path.nil?
            if @location.nil?
              save_db = File.join(use_cabling_path, DB_DIRECTORY, '%s.%s' % [ @target, DB_EXTENSION ])
            else
              save_db = File.join(use_cabling_path, DB_DIRECTORY, '%s_%s.%s' % [ @target, @location, DB_EXTENSION ])
            end
          end
        else
          save_db = @options[:save_db]
        end
      end

      save_db
    end

    def load_cablefile
      @cablefile = Cablefile.parse!(self)

      if @app_root != @cablefile.app_root
        @app_root = @cablefile.app_root
      end

      if @cablefile.configured?
        @cablefile.cabling(self, @cablefile, @target)
      end
    end

    def load_cabling_values
      if !@values_path.nil? && File.exist?(@values_path)
        @cabling_values = Palmade::Cableguy::CablingValues.load_cabling_values(self, @values_path)
      else
        @cabling_values = Palmade::Cableguy::CablingValues.new_empty(self)
      end
    end

    def build_setups
      Builders.load_all_builders

      if @builds.nil?
        @builds = @cablefile.setups.collect do |s|
          Cable.build(s[0], *s[1], &s[2])
        end
      else
        @builds
      end
    end

    def check_requirements
      if @cablefile.include?(:requirements)
        @cablefile.requirements(self, @cablefile, @target)
      end
    end

    def create_logger
      Logger.new($stdout)
    end
  end
end
