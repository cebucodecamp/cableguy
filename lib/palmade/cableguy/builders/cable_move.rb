module Palmade::Cableguy
  class Builders::CableMove < Cable
    add_as :move

    def configure(cabler)
      FileUtils.mv(@args.shift, @args.shift)
    end
  end
end
