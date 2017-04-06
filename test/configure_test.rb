require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class ConfigureTest < MiniTest::Test
  include TestHelper

  def setup
    @cabler = TestHelper.configure
    @cabler.configure
    @builds = @cabler.builds

    TestHelper.unload_cabling

    @cabler_with_apply = TestHelper.configure(nil, :apply_path => TEST_APPLY_ROOT)
    @cabler_with_apply.configure

    TestHelper.unload_cabling
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_built
    assert(@builds.count > 0, 'No builds configured')
  end

  def test_apply_path_different
    refute_equal(@cabler_with_apply.determine_apply_path, @cabler_with_apply.app_root)
  end
end
