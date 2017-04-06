module Palmade::Cableguy
  module Builders
    def self.load_all_builders
      CableTemplate
      CableMkdir
      CableChmod
      CableSymlink
      CableCustom
      CableMove
      CableCopy
    end

    autoload :CableChmod,'palmade/cableguy/builders/cable_chmod'
    autoload :CableCustom,'palmade/cableguy/builders/cable_custom'
    autoload :CableMkdir,'palmade/cableguy/builders/cable_mkdir'
    autoload :CableSymlink,'palmade/cableguy/builders/cable_symlink'
    autoload :CableTemplate,'palmade/cableguy/builders/cable_template'
    autoload :CableMove,'palmade/cableguy/builders/cable_move'
    autoload :CableCopy,'palmade/cableguy/builders/cable_copy'
  end
end
