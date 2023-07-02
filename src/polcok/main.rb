# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'plank.rb'

module Toto
  module Polcok

    def self.add_plank
      model = Sketchup.active_model
      plank = Plank.new(0.2, 2, 4, '2m 4')
      model.start_operation('Add Plank', true)
      plank.add_to_model([0,0,0])
      model.commit_operation
    end

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Polc') {
        self.add_plank
      }
      file_loaded(__FILE__)
    end

  end # module HelloCube
end # module Polcok
