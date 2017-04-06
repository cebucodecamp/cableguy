module Palmade::Cableguy
  class Builders::CableMkdir < Cable
    add_as :mkdir

    def configure(cabler)
      @args.each do |path|
        FileUtils.mkdir_p(File.join(cabler.determine_apply_path,  path))
      end
    end
  end
end
