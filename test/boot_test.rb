require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class BootTest < MiniTest::Test
  def setup
    @cabler = TestHelper.configure
  end

  def teardown

  end

  def test_booted
    assert_equal(@cabler.app_root, TestHelper::TEST_APP_ROOT)
    assert_equal(@cabler.cabling_path, TestHelper::TEST_CABLING_PATH)
    assert_equal(@cabler.target, :test)
    assert_nil(@cabler.location)
  end

  def test_create_builtin_logger
    refute_nil(@cabler.logger)
    assert_respond_to(@cabler.logger, :log)
    assert_respond_to(@cabler.logger, :add)
  end
end
