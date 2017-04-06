require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class CablingValuesTest < MiniTest::Test
  def setup
    @cabler = TestHelper.configure
    @cabler.configure

    @db = @cabler.db
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_values_loaded
    assert_equal('127.0.0.1', @cabler.values['redis']['host'])
    assert_equal(6379, @cabler.values['redis']['port'])
  end

  def test_password_value_override
    assert_equal('password', @db.get('db.password', 'blog'))
  end
end
