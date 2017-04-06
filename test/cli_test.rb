require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class CliTest < MiniTest::Test
  include Palmade::Cableguy::Constants

  def setup
    @cli = TestHelper.new_cli_tester('configure')
    @lock_opts = @cli.prepare_lock_file

    TestHelper.disable_default_cabling_path do
      @cabler = @cli.cabler
    end

    @cabler.configure

    @default_cli = TestHelper.new_cli_tester('configure', [ '--nolock' ])

    TestHelper.disable_default_cabling_path do
      @default_cabler = @default_cli.cabler
    end

    @default_db = @default_cabler.db
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_cabling_path_set
    assert_equal(TestHelper::TEST_CABLING_PATH, @cabler.cabling_path)
  end

  def test_cabling_values_path_set
    assert_equal(TestHelper::TEST_CABLING_VALUES_PATH, @cabler.values_path)
  end

  def test_app_root_is_set
    assert_equal(TestHelper::TEST_APP_ROOT, @cabler.app_root)
  end

  def test_cabling_defaults_set
    if ENV.include?('CABLING_PATH')
      default_path = File.expand_path(ENV['CABLING_PATH'])
    elsif File.exists?(DEFAULT_CABLING_PATH)
      default_path = File.expand_path(DEFAULT_CABLING_PATH)
    else
      default_path = nil
    end

    unless default_path.nil?
      loop do
        if File.symlink?(default_path)
          default_path = File.readlink(default_path)
        else
          break
        end
      end

      assert_equal(default_path, @default_cabler.cabling_path)
    end

    values_path = File.expand_path(DEFAULT_CABLING_VALUES_PATH)
    if File.exists?(values_path)
      assert_equal(values_path, @default_cabler.values_path)
    else
      assert_nil(@default_cabler.values_path, 'Default cabling values path is not nil')
    end
  end

  def test_cabling_defaults_will_raise_error
    assert_raises(RuntimeError) do
      @default_cabler.configure
    end
  end

  def test_cabling_defaults_db_empty
    assert(@default_db.empty?, 'Default database not empty!')
  end

  def test_lock_defaults_target
    assert_equal(DEFAULT_TARGET, @lock_opts[:target])
  end

  def test_lock_defaults_location
    assert_nil(@lock_opts[:location])
  end
end
