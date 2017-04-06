require 'sequel'
require 'fileutils'

module Palmade::Cableguy
  class DB
    attr_reader :database
    attr_reader :dataset

    GLOBAL_GROUP = 'globals'

    DEFAULT_OPTIONS = {
      :save_db => nil
    }

    def initialize(cabler, options = { })
      @options = DEFAULT_OPTIONS.merge(options)
      @cabler = cabler

      @database = nil
      @sql_options = { :logger => @cabler.logger, :sql_log_level => :info }

      if @cabler.options[:verbose]
        @sql_options[:sql_log_level] = :debug
      end

      @migrated = false
    end

    def boot
      if @options[:save_db].nil?
        connect_string = 'sqlite:/'
      else
        FileUtils.mkpath(File.dirname(@options[:save_db]))
        connect_string = 'sqlite://%s' % @options[:save_db]
      end

      @database = Sequel.connect(connect_string, @sql_options)
      @dataset = @database[:cablingdatas]

      @group_stack = [ ]
      @prefix_stack = [ ]

      self
    end

    def prepare_for_use
      prepare_table
    end

    def group(group, &block)
      @group_stack.push(group.to_s)

      if block_given?
        begin
          @database.transaction do
            yield
          end
        ensure
          @group_stack.pop
        end
      end

      group
    end

    def globals(&block)
      group(GLOBAL_GROUP, &block)
    end

    def prefix(prefix, &block)
      @prefix_stack.push(prefix)
      yield
    ensure
      @prefix_stack.pop
    end

    def final_key(key, group)
      if key =~ /^([A-Za-z0-9\_]*)\:([A-Za-z0-9\_\-\.]+)$/
        group = $~[1]
        key = $~[2]
      else
        group = @group_stack.last if group.nil?

        unless @prefix_stack.empty?
          key = (@prefix_stack + [ key ]).join('.')
        end
      end

      [ key, group ]
    end

    def final_value(group, key, value)
      val_key = '%s:%s' % [ group, key ]

      g = @cabler.values.fetch(group, { })
      g.fetch(key, value)
    end

    def set(key, value, group = nil)
      key, group = final_key(key, group)
      value = final_value(group, key, value)

      if @dataset.where(:key => key, :group => group).count > 0
        @dataset.filter(:key => key, :group => group).update(:value => value)
      else
        @dataset.insert(:key => key, :group => group, :value => value)
      end
    end

    def update(key, value, group = nil)
      key, group = final_key(key, group)
      value = final_value(group, key, value)

      @dataset.filter(:key => key, :group => group).update(:value => value)
    end

    def delete_key(key, group = nil)
      key, group = final_key(key, group)

      @dataset.filter(:key => key, :group => group).delete
    end

    def has_key?(key, group = nil)
      key, group = final_key(key, group)

      val = @dataset.where(:key => key, :group => group).count
      if val == 0
        val = @dataset.where(:key => key, :group => GLOBAL_GROUP).count
        val == 0 ? false : true
      else
        true
      end
    end

    def get(key, group = nil)
      key, group = final_key(key, group)

      val = @dataset.where(:key => key, :group => group)
      if val.empty?
        val = @dataset.where(:key => key, :group => GLOBAL_GROUP)
      end

      if val.count > 0
        val.first[:value]
      else
        raise "key \'%s\' cannot be found!" % key
      end
    end

    def get_if_key_exists(key, group = nil)
      get(key, group) if has_key?(key, group)
    end

    def get_children(key, group = nil)
      key, group = final_key(key, group)

      values = [ ]
      res = @dataset.where(Sequel.like(:key, "#{key}%"), :group => group)
      if res.empty?
        res = @dataset.where(Sequel.like(:key, "#{key}%"), :group => GLOBAL_GROUP)
      end

      key = key.split('.')

      res.each do |r|
        res_key = r[:key].split('.')
        res_key = (res_key - key).shift
        values.push(res_key)
      end

      if values.count > 0
        values & values
      else
        raise "no values for \'%s\'!" % key
      end
    end

    def empty?
      !@database.tables.include?(:cablingdatas) || @dataset.count == 0
    end

    def migrated?
      @migrated == true
    end

    def migrated!
      @migrated = true
    end

    def reset
      if @database.tables.include?(:cablingdatas)
        @dataset.truncate
      end

      @migrated = false
    end

    def prepare_table
      unless @database.tables.include?(:cablingdatas)
        @database.create_table(:cablingdatas) do
          String :key
          String :value
          String :group
        end
      end
    end
  end
end
