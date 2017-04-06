require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class MigrateTest < MiniTest::Test
  def setup
    @cabler = TestHelper.configure(nil, :unload_cabling => false)
    @db = @cabler.db
    @migrate = @cabler.migrate
    @migrator = @cabler.migrator
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_cabling_init_is_loaded
    assert(defined?(TEST_CABLING_INIT_FILE_LOADED), 'Cabling init not loaded')
    assert_equal(true, TEST_CABLING_INIT_FILE_LOADED)
  end

  def test_cabling_blog_loaded
    assert(defined?(TestCableguyCabling::Base::Blog), 'Base::Blog expected from cabling not loaded')
    assert_includes(@migrator.klass_stack, TestCableguyCabling::Base::Blog)
    assert_equal(@migrator.klass_stack, [ TestCableguyCabling::Base::Blog ])
  end

  def test_blog_values_inserted
    assert_equal('true', @db.get('require_2fa', 'blog'))
    assert_equal('true', @db.get('twitter_auth', 'blog'))
  end

  def test_migration_instantiated
    refute_empty(@migrator.instance_stack)
  end

  def test_cabling_path_values_are_retained
    assert_equal('127.0.0.1', @db.get('db.host', 'blog'))
  end
end
