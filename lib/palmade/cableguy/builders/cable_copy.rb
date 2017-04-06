module Palmade::Cableguy
  class Builders::CableCopy < Cable
    add_as :copy

    def configure(cabler)
      FileUtils.cp(@args.shift, @args.shift)
    end
  end
end
