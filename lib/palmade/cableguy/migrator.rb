module Palmade::Cableguy
  class Migrator
    attr_reader :cabler
    attr_reader :db
    attr_reader :cabling_path

    attr_accessor :klass_stack
    attr_accessor :file_stack
    attr_accessor :instance_stack

    DIR_TREE = [ 'base', 'targets', '.' ]

    DEFAULT_OPTS = {
      :unload_cabling => true
    }

    def self.boot(cabler, cabling_path, opts = { })
      Migrator.new(cabler, cabling_path, opts).tap { |o| o.boot }
    end

    def initialize(cabler, cabling_path, opts = { })
      @options = DEFAULT_OPTS.merge(opts)

      @cabler = cabler
      @db = cabler.db
      @cabling_path = cabling_path

      @file_stack = [ ]
      @klass_stack = [ ]
      @instance_stack = [ ]
    end

    def boot
      init_file = File.join(cabling_path, 'init.rb')
      require init_file if File.exist?(init_file)
    end

    def load_cabling
      if @instance_stack.empty?
        search_for_files
        require_files_once
        instantiate_klasses
      end
    end

    def unload_cabling
      @klass_stack.each do |k|
        klass_name = k.name

        knames = klass_name.split('::')
        if knames.count > 1
          const_name = knames.pop
          parent_module = ::Object.module_eval('::%s' % knames.join('::'), __FILE__, __LINE__)
        else
          parent_module = ::Object
          const_name = knames[0]
        end

        parent_module.send(:remove_const, const_name.to_sym)
      end
    end

    def run!
      load_cabling

      run_all_migrations(:pre_migrate)
      run_all_migrations(:migrate!)
      run_all_migrations(:post_migrate)

      if @options[:unload_cabling]
        unload_cabling
      end

      self
    end

    protected

    def instantiate_klasses
      @klass_stack.each do |klass|
        @instance_stack << klass.new(cabler)
      end
    end

    def run_all_migrations(migration)
      @instance_stack.each do |i|
        i.send(migration)
      end
    end

    def require_files_once
      Palmade::Cableguy::Migration.use_klass_stack(@klass_stack) do
        file_stack.each { |file| load(file) }
      end
    end

    def directory_tree; DIR_TREE; end

    def search_for_files
      directory_tree.each do |child|
        path = File.join(cabling_path, child)

        case child
        when 'targets'
          if !cabler.location.nil? && !cabler.location.empty? && cabler.location != cabler.target
            file = File.join(path, '%s_%s.rb' % [ cabler.target, cabler.location ])
          else
            file = File.join(path, '%s.rb' % cabler.target)
          end

          if File.exists?(file)
            file_stack.push(file)
          end
        when '.'
          if File.exist?(File.join(path, 'custom.rb'))
            file_stack.push(Dir['%s/custom.rb' % path].shift)
          end
        else
          Dir['%s/*.rb' % path].each { |file| file_stack.push(file) }
        end
      end
    end
  end
end
