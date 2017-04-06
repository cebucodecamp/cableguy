module Palmade::Cableguy
  class Builders::CableSymlink < Cable
    add_as :symlink

    def configure(cabler)
      source = @args[0]
      destination = @args[1]

      FileUtils.ln_s(source, destination, :force => true)
    end
  end
end
