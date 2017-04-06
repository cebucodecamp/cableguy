require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class AppCablingTest < MiniTest::Test
  include TestHelper

  def setup
    @cabler = TestHelper.configure
    @db = @cabler.db
    @migrator = @cabler.migrator
    @app_migrator = @cabler.app_migrator

    @cabler.configure
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_app_cabling_path_is_set
    assert_equal(@cabler.app_cabling_path, File.join(TestHelper::TEST_APP_ROOT, 'cabling'))
  end

  def test_cabling_init_is_loaded
    assert(defined?(TEST_APP_CABLING_INIT_FILE_LOADED), 'App cabling init not loaded')
    assert_equal(true, TEST_APP_CABLING_INIT_FILE_LOADED)
  end

  def test_blog_values_inserted
    assert_equal('true', @db.get('fb_oauth', 'blog'))
    assert_equal('127.0.0.1', @db.get('mongo.host', 'blog'))
  end
end
