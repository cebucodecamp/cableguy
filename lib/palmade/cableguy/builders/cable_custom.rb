module Palmade::Cableguy
  class Builders::CableCustom < Cable
    add_as :custom

    def configure(cabler)
      unless @block.nil?
        if @block.arity == 2
          @block.call(self, cabler)
        else
          @block.call(self)
        end
      end
    end
  end
end
