#load 'c:\Devel\Bemjózsi2\polcok\src\polcok\plank.rb'
#plank=Toto::Polcok::Plank.new(0.2.m, 2.m, 3, 'x')
#tr = Geom::Transformation.rotation([0,0,0], [0,0,1], 90.degrees)
#tr2 = Geom::Transformation.translation([0, -0.20.m, 1.675.m])
#plank.add_to_model(tr*tr2)
require 'sketchup.rb'

module Toto
  module Polcok
    class Plank
      PlankHeight=0.012.m
      HoleR = 0.015.m
      @@model = Sketchup::active_model
      @@components = @@model.definitions
      def components
        @@components
      end

      def model
        @@model
      end

      def component
        @component
      end

      def initialize(depth, width, holes, name)
        raise ArgumentError, 'to deep' if 2*HoleR >= depth
        raise ArgumentError, 'to holy' if holes*depth >= width
        @depth = depth
        @width = width
        @component = @@components.add(name)
        @holes = holes
        @internal_width = (width-depth)/(holes-1)
        create_plank_component
      end

      def add_hole(entities, x)
        faces = entities.grep(Sketchup::Face)
        entities.add_circle([x, @depth/2, 0], [0,0,1], HoleR)
        faces = entities.grep(Sketchup::Face)
        entities.erase_entities(faces[1])
      end

      def add_to_model(transform)
        model.entities.add_instance(component, transform)
      end

      def create_plank_component
        #component.material=0xc48531
        component.material='brown'
        entities = component.entities
        entities.add_face([0,0,0], [@width, 0, 0], [@width, @depth, 0], [0,@depth,0])
        for i in 0..@holes-1
          add_hole(entities, @depth/2 + i*(@width - @depth)/(@holes-1))
        end
        face = entities.grep(Sketchup::Face)[0]
        face.pushpull(PlankHeight)
      end

      def to_s
        "#{@width}x#{@depth}, #{@holes} holes"
      end
    end
  end
end
