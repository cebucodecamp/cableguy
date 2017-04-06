require 'thor'
require 'yaml'

module Palmade
  module Cableguy
    class CLI < Thor
      include Constants

      class_option :target, :default => nil
      class_option :location, :default => nil

      class_option :path, :default => nil
      class_option :values_path, :default => nil
      class_option :apply_path, :default => nil
      class_option :templates_path, :default => nil

      class_option :lock_file, :default => nil
      class_option :unlock, :default => false, :type => :boolean
      class_option :nolock, :default => false, :type => :boolean

      class_option :app_root, :default => nil, :type => :string
      class_option :include_global_cabling, :default => false, :type => :boolean

      class_option :verbose, :default => false, :type => :boolean
      class_option :silent, :default => false, :type => :boolean

      class_option :save_db

      attr_accessor :raise_error

      desc 'configure', 'start configuring!'
      def configure
        cabler.configure
      end

      desc 'migrate', 'migrates data into sqlite'
      def migrate
        cabler(:save_db => true).migrate
      end

      desc 'version', 'show version'
      def version
        say Palmade::Cableguy::VERSION
      end

      no_tasks do
        def app_path
          if options[:app_root]
            File.expand_path(options[:app_root])
          else
            File.expand_path(Dir.pwd)
          end
        end

        def lock_file_path
          file_path = options[:lock_file]

          if file_path.nil?
            file_path = File.join(app_path, DEFAULT_LOCK_FILE)

            if !File.exists?(file_path) && File.exists?(DEFAULT_LOCK_PATH)
              file_path = DEFAULT_LOCK_PATH
            end
          end

          file_path = File.expand_path(file_path)
        end

        def cabler(opts = { })
          if defined?(@cabler) && !@cabler.nil?
            @cabler
          else
            lock_opts = prepare_lock_file(opts)
            opts = opts.merge(lock_opts)
            opts = opts.merge(Utils.symbolize_keys(options))

            check_if_cabling_path_exists!(opts)
            check_if_cabling_values_exists!(opts)

            if opts[:save_db] == 'save_db'
              opts[:save_db] = true
            end

            @cabler = Palmade::Cableguy.boot_cabler(app_path, opts)
          end
        end

        def prepare_lock_file(opts = { })
          default_lock_opts = { :target => DEFAULT_TARGET, :location => DEFAULT_LOCATION }

          if options[:nolock]
            lock_opts = default_lock_opts
          else
            lfp = lock_file_path

            if !File.exists?(lfp) || options[:unlock]
              lock_opts = default_lock_opts.dup

              if !options[:target].nil? && !options[:target].empty?
                lock_opts[:target] = options[:target]
              end

              if !options[:location].nil? && !options[:location].empty?
                lock_opts[:location] = options[:location]
              end

              unless opts[:lock_no_persist]
                File.open(lfp, 'w') { |file| file.write(YAML.dump(lock_opts)) }
              end
            else
              lock_opts = YAML.load_file(lfp)
              check_locked_values(lock_opts)
            end
          end

          lock_opts
        end

        def check_locked_values(lock_opts)
          if !options[:target].nil? && !options[:target].empty?
            if lock_opts[:target] != options[:target]
              safety_message(:target, lock_opts)

              if raise_error
                raise 'Lock target not the same (%s != %s)' % [ lock_opts[:target], options[:target] ]
              else
                exit 1
              end
            end
          end

          if !options[:location].nil? && !options[:location].empty?
            if lock_opts[:location] != options[:location]
              safety_message(:location, lock_opts)

              if raise_error
                raise 'Lock location not the same (%s != %s)' % [ lock_opts[:location], options[:location] ]
              else
                exit 2
              end
            end
          end
        end

        def safety_message(val, lock_opts)
          lockfile_error_message = <<-error_message
Lockfile has a setting #{val} with value '#{lock_opts[val]}' \
and it is not equal to the specified #{val} '#{options[val]}'. \
This prevents accidental overriding of the cabling database. \
You can fix this by running with cabling migrate --unlock"
error_message

          say_with_format(lockfile_error_message, :red)
        end

        def say_with_format(msg, color = nil)
          unless options[:silent]
            say("-- #{msg}", color)
          end
        end

        def check_if_cabling_values_exists!(opts)
          if opts[:values_path].nil?
            vp = File.expand_path(DEFAULT_CABLING_VALUES_PATH)

            if File.exists?(vp)
              opts[:values_path] = vp
            end
          else
            vp = File.expand_path(opts[:values_path])

            if File.exists?(vp)
              opts[:values_path] = vp
            else
              say_with_format 'Cabling values path (%s) does not exists' % vp, :red

              if raise_error
                raise 'Cabling values path does not exists'
              else
                exit 3
              end
            end
          end

          opts[:values_path]
        end

        def check_if_cabling_path_exists!(opts)
          if opts[:path].nil?
            if ENV.include?('CABLING_PATH')
              path = ENV['CABLING_PATH']
            else
              path = DEFAULT_CABLING_PATH
            end
          else
            path = opts[:path]
          end

          if path.empty?
            path = nil
          else
            path = File.expand_path(path)
          end

          if !path.nil? && File.exists?(path)
            loop do
              if File.symlink?(path)
                path = File.readlink(path)
              else
                break
              end
            end

            opts[:path] = path
          elsif !opts[:path].nil?
            say_with_format 'Cabling path (%s) does not exists' % opts[:path], :red

            if raise_error
              raise 'Cabling path does not exists'
            else
              exit 3
            end
          else
            # ignore no cabling path!
          end
        end
      end

      default_task :configure
    end
  end
end
