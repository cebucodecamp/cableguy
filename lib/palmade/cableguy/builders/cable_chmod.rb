module Palmade::Cableguy
  class Builders::CableChmod < Cable
    add_as :chmod

    def configure(cabler)
      FileUtils.chmod(@args.shift.to_i(8),
                      File.join(cabler.determine_apply_path, @args.shift))
    end
  end
end
