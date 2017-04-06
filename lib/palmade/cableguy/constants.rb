module Palmade::Cableguy
  module Constants
    DB_DIRECTORY = 'db'
    DB_EXTENSION = 'sqlite3'

    DEFAULT_CABLEFILE_NAME = 'Cablefile'
    DEFAULT_LEGACY_CABLEFILE_NAME = 'config/cableguy.rb'

    DEFAULT_CABLING_PATH = File.join(ENV['HOME'], 'cabling')
    DEFAULT_CABLING_VALUES_PATH = File.join(ENV['HOME'], '.cabling_values.yml')

    DEFAULT_LOCK_FILE = File.join('.cabling.yml')
    DEFAULT_LOCK_PATH = File.join(ENV['HOME'], DEFAULT_LOCK_FILE)

    DEFAULT_TARGET = 'development'
    DEFAULT_LOCATION = nil

    DEFAULT_TEMPLATES_PATH = 'config/templates'
    DEPRECATED_DEFAULT_TARGET_PATH = 'config'
  end
end
