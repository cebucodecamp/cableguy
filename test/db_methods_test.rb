require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class DbMethodsTest < MiniTest::Test
  def setup
    @cabler = TestHelper.configure
    @db = @cabler.db
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_data_methods
    assert_respond_to(@db, :group)
    assert_respond_to(@db, :prefix)
    assert_respond_to(@db, :globals)
  end
end
