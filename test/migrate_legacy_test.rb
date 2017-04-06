require File.expand_path('../test_helper', __FILE__)
require 'minitest/autorun'

class MigrateLegacyTest < MiniTest::Test
  def setup
    @cabler = TestHelper.configure(nil, :save_db => true)
    @db = @cabler.db
    @save_db = @cabler.save_db

    @migrate = @cabler.migrate
    @migrator = @cabler.migrator
  end

  def teardown
    TestHelper.unload_cabling

    unless @save_db.nil?
      File.delete(@save_db)
    end
  end

  def test_migrator_created
    refute_nil(@migrator, '@migrator not initiated')
  end

  def test_migrate_migrated
    assert(@db.migrated?, 'DB not migrated')
  end

  def test_db_created
    refute_nil(@save_db, 'SQLite DB not set')
    assert(File.exists?(@save_db), 'SQLite DB not created')
  end
end
