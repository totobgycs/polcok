#load 'c:\Devel\Bemjózsi2\polcok\src\polcok\plank.rb'
#room = Toto::Polcok::Room.new
#room.add_to_model
#plank=Toto::Polcok::Plank.new(0.2.m, 2.m, 3, 'x')
#tr = Geom::Transformation.rotation([0,0,0], [0,0,1], 90.degrees)
#tr2 = Geom::Transformation.translation([0, -0.20.m, 1.675.m])
#plank.add_to_model(tr*tr2)
require 'sketchup.rb'

module Toto
  module Polcok

    PlankHeight=0.012.m
    HoleR = 0.015.m

    @@model = Sketchup::active_model
    @@components = @@model.definitions
    @@entities = @@model.active_entities

    @@ow = Geom::Transformation.rotation([0,0,0], [0,0,1], 90.degrees) * Geom::Transformation.translation([0, -0.20.m, 0.m])
    @@tw = Geom::Transformation.translation([0,0,0])

    def Polcok.otherwall
      @@ow
    end

    def Polcok.thiswall
      @@tw
    end

    def Polcok.components
      @@components
    end

    def Polcok.model
      @@model
    end

    def Polcok.clear
      @@entities.clear!
    end

    class Plank

      def component
        @component
      end

      def hole_positions
        @hole_positions
      end

      def holes
        @holes
      end

      def model
        Polcok.model
      end

      def initialize(depth, width, holes, name)
        raise ArgumentError, 'to deep' if 2*HoleR >= depth
        raise ArgumentError, 'to holy' if holes*depth >= width
        @depth = depth
        @width = width
        @component = Polcok.components.add(name)
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
        model.start_operation("Add plank", true)
        model.entities.add_instance(component, transform)
        model.commit_operation
      end

      def create_plank_component
        #component.material=0xc48531
        @hole_positions = Array.new(@holes)
        component.material='brown'
        entities = component.entities
        entities.add_face([0,0,0], [@width, 0, 0], [@width, @depth, 0], [0,@depth,0])
        for i in 0..@holes-1
          hp = @depth/2 + i*(@width - @depth)/(@holes-1)
          @hole_positions[i] = [hp, @depth/2, 0]
          add_hole(entities, hp)
        end
        face = entities.grep(Sketchup::Face)[0]
        face.pushpull(PlankHeight)
      end

      def to_s
        "#{@width}x#{@depth}, #{@holes} holes"
      end
    end

    class Wall

      @@delta = Geom::Transformation.translation([0.m, 0.m, 0.25.m])
      @@pipe_start = Geom::Transformation.translation([0.m, 0.m, -0.1.m])

      def orientation
        @orientation
      end

      def begin_trans
        @begin_trans
      end

      def begin_point
        @pegin_point
      end

      def initialize(orientation, plank, planks, begin_at, name)
        @orientation = orientation
        @plank = plank
        @planks = planks
        @begin_trans = Geom::Transformation.translation(begin_at)
        @begin_point = begin_at
        @wall_start = @orientation * @begin_trans
        @name = name
        create_pipe_component
      end

      def create_pipe_component
        @component = Polcok.components.add("pipe " + @name)
        @component.material='black'
        entities = @component.entities
        c = entities.add_circle([0,0,0], [0,0,1], HoleR)
        f = entities.add_face(c)
        f.pushpull(@begin_point.z - 2.5.m)
        puts(@component)
      end

      def add_to_model
        at = @wall_start
        for i in 1..@planks
          @plank.add_to_model(at)
          at = at * @@delta
        end
        add_pipes
      end

      def add_pipes
        entities = Polcok.model.active_entities
         for i in 0..@plank.holes-1
          entities.add_instance(@component, @wall_start * @@pipe_start * @plank.hole_positions[i])
        end
      end

    end

    class Sofa

      def initialize
        create_open_sofa_component
      end

      def create_open_sofa_component
        @component = Polcok.components.add("Open sofa")
        @component.material='olive'
        entities = @component.entities
        points = []
        points << [0.m, 0.m, 0.2.m]
        points << [0.m, 1.5.m, 0.2.m]
        points << [2.m, 1.5.m, 0.2.m]
        points << [2.m, 0.m, 0.2.m]
        f = entities.add_face(points)
        f.pushpull( 0.2.m)
      end

      def add_to_model
        entities = Polcok.model.active_entities
        entities.add_instance(@component, [0, 0, 0.2.m])
      end
    end

    class Room

      def initialize
        @plank1 = Plank.new(0.2.m, 2.m, 4, 'plank1')
        @plank2 = Plank.new(0.2.m, 1.8.m, 3, 'plank2')
        @plank3 = Plank.new(0.2.m, 1.4.m, 3, 'plank2')

        @wall1 = Wall.new(Polcok.thiswall, @plank1, 3, [0.m, 0.m, 1.5.m], "wall1")
        @wall2 = Wall.new(Polcok.otherwall, @plank2, 3, [0.m, 0.m, 1.67.m], "wall2")
        @wall3 = Wall.new(Polcok.otherwall, @plank3, 8, [1.6.m, 0.m, 0.25.m], "wall3")

        @sofa = Sofa.new
      end

      def add_to_model
        Polcok.model.start_operation('room', true)
        @wall1.add_to_model
        @wall2.add_to_model
        @wall3.add_to_model
        @sofa.add_to_model
        Polcok.model.commit_operation
      end

      def clear
        Polcok.clear
      end

    end
  end
end
