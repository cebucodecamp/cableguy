require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class CablefileTest < MiniTest::Test
  def setup
    subdir_app_root = File.join(TestHelper::TEST_APP_ROOT, 'config')

    @cabler = TestHelper.configure
    @cablefile = @cabler.cablefile

    @cabler_sub = TestHelper.configure(subdir_app_root)
    @cablefile_sub = @cabler_sub.cablefile

    @db = @cabler.db
  end

  def teardown
    TestHelper.unload_cabling
  end

  def test_cablefile_path
    correct_cablefile_path = File.join(TestHelper::TEST_APP_ROOT, 'Cablefile')

    assert_equal(correct_cablefile_path, @cabler.cablefile.file_path)
    assert_equal(correct_cablefile_path, @cabler_sub.cablefile.file_path)
  end

  def test_app_root
    assert_equal(@cabler.app_root, File.dirname(@cabler.cablefile.file_path))
    assert_equal(@cabler_sub.app_root, File.dirname(@cabler_sub.cablefile.file_path))
  end

  def test_is_configured
    assert(@cabler.cablefile.configured?, 'Cablefile not configured!')
  end

  def test_app_group_is_set
    @group_stack = @db.instance_variable_get('@group_stack')

    assert_equal('blog', @cabler.app_group)
    assert_equal('blog', @group_stack[0])
    assert_equal([ 'blog' ], @group_stack)
  end
end
