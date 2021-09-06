module Civ
  # Abstracted drawing handler.
  class Draw
    attr_accessor :layers, :debug_layer

    def initialize(_args)
      # layers = [[{}, {}, {},], [{}, {}, {}]]
      @layers = []
      @debug_layer = []
    end

    def tick(args)
      args.outputs.primitives << @layers
      @layers.each(&:clear)

      args.outputs.debug << @debug_layer
      @debug_layer.clear
    end
  end
end
