module Palmade::Cableguy
  class LegacyConfigurator < Configurator
    attr_reader :setups
    attr_reader :requires

    def initialize(*args)
      super
      @setups = [ ]
    end

    def setup_cabling(*args, &block)
      if block_given?
        update_section(:setup_cabling, *args, &block)
      else
        call_section(:setup_cabling, *args)
      end
    end

    def requirements(*args, &block)
      if block_given?
        update_section(:requirements, *args, &block)
      else
        call_section(:requirements, *args)
      end
    end

    def setup(what, *args, &block)
      @setups.push([ what, args, block ])
    end
  end
end
