require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class CablerTest < MiniTest::Test
  include TestHelper

  def setup
    @cabler = TestHelper.configure
    @cabler_with_apply = TestHelper.configure(nil, :apply_path => TEST_APPLY_ROOT)
    @cabler_app_cabling_only = TestHelper.configure(nil, :include_global_cabling => false)
  end

  def test_apply_path
    assert_nil(@cabler.apply_path)
  end

  def test_apply_path_is_app_root
    assert_equal(@cabler.determine_apply_path, @cabler.app_root)
  end

  def test_apply_path_for_templates
    assert_equal(@cabler.determine_apply_path(:for_templates => true),
                 File.join(@cabler.app_root, 'config'))
  end

  def test_with_apply_path
    refute_equal(@cabler_with_apply.determine_apply_path, @cabler_with_apply.app_root)
  end

  def test_include_global_cabling_paths
    cps = @cabler.send(:determine_useable_cabling_paths)

    assert_includes(cps, TEST_CABLING_PATH)
    assert_includes(cps, File.join(TEST_APP_ROOT, 'cabling'))
    assert(cps.count, 2)
  end

  def test_app_cabling_only
    cps = @cabler_app_cabling_only.send(:determine_useable_cabling_paths)

    refute_includes(cps, TEST_CABLING_PATH)
    assert_includes(cps, File.join(TEST_APP_ROOT, 'cabling'))
    assert(cps.count, 1)
  end
end
