require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class CliLockTest < MiniTest::Test
  include Palmade::Cableguy::Constants

  def setup
    @test_cli = TestHelper.new_cli_tester('configure', [ '--target=test' ])
    @another_cli = TestHelper.new_cli_tester('configure', [ ])
  end

  def test_lock_target
    test_lock_opts = @test_cli.prepare_lock_file(:lock_no_persist => true)
    assert_equal('test', test_lock_opts[:target])

    test_cabler = @test_cli.cabler(:lock_no_persist => true)
    assert_equal('test', test_cabler.target)
  end

  def test_lock_file_target
    @test_cli.prepare_lock_file

    lock_opts = @another_cli.prepare_lock_file
    File.delete(@test_cli.lock_file_path)

    assert_equal('test', lock_opts[:target])
  end
end
