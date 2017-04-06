require File.expand_path('../boboot', __FILE__)
require 'minitest'
require 'palmade/cableguy'

require 'pp'

CABLEGUY_TEST_PATH = File.join(CABLEGUY_ROOT_PATH, 'test')

module TestHelper
  include Palmade::Cableguy::Constants

  TEST_APP_ROOT = File.join(CABLEGUY_TEST_PATH, 'app')
  TEST_APPLY_ROOT = File.join(CABLEGUY_TEST_PATH, 'test_apply')

  TEST_CABLING_PATH = File.join(CABLEGUY_TEST_PATH, 'cabling')
  TEST_CABLING_VALUES_PATH = File.join(CABLEGUY_TEST_PATH, '.cabling_values.yml')

  Palmade::Cableguy::Constants::DEFAULT_LOCK_PATH.replace('')

  def self.configure(app_root = nil, options = { })
    opts = {
      :path => TEST_CABLING_PATH,
      :values_path => TEST_CABLING_VALUES_PATH,
      :target => :test,
      :location => nil,
      :include_global_cabling => true
    }.merge(options)

    Palmade::Cableguy.boot_cabler(app_root || TEST_APP_ROOT, opts)
  end

  def self.new_cli_tester(cmd, args = nil)
    if args.nil?
      args = [ '--silent',
               '--app-root=%s' % TestHelper::TEST_APP_ROOT,
               '--include-global-cabling',
               '--nolock',
               '--path=%s' % TestHelper::TEST_CABLING_PATH,
               '--values-path=%s' % TestHelper::TEST_CABLING_VALUES_PATH
             ]
    else
      args += [ '--silent',
                '--app-root=%s' % TestHelper::TEST_APP_ROOT,
                '--include-global-cabling'
              ]
    end

    cli_k = Palmade::Cableguy::CLI

    command = cli_k.all_commands[cmd]
    if command.nil?
      command = Thor::DynamicCommand.new(cmd)
    end

    config = { }
    config[:current_command] = command
    config[:command_options] = command.options

    cli = Palmade::Cableguy::CLI.new([ ], args, config)
    cli.raise_error = true
    cli
  end

  def self.unload_cabling
    if defined?(TestCableguyCabling::Base::Blog)
      TestCableguyCabling::Base.send(:remove_const, :Blog)
    end

    if defined?(TestCableguyAppCabling::Base::Blog)
      TestCableguyAppCabling::Base.send(:remove_const, :Blog)
    end
  end

  def self.disable_default_cabling_path(&block)
    default_cabling_path = DEFAULT_CABLING_PATH
    DEFAULT_CABLING_PATH.replace('/tmp/path_to_nowhere-%s' % $$)
    ret = yield
    DEFAULT_CABLING_PATH.replace(default_cabling_path)
    ret
  end
end
