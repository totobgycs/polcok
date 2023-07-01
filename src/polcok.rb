# Copyright 2016-2022 Trimble Inc
# Licensed under the MIT license

require 'sketchup.rb'
require 'extensions.rb'

module Toto # TODO: Change module name to fit the project.
  module Polcok

    #unless file_loaded?(__FILE__)
      file = __FILE__.dup
      file.force_encoding('UTF-8') if file.respond_to?(:force_encoding)
      path = File.dirname(file)

      loader = File.join(path, "polcok/main")
      ex = SketchupExtension.new('Polcok', loader)
      ex.description = 'Toto - polcok'
      ex.version     = '1.0.0'
      ex.copyright   = 'toto'
      ex.creator     = 'toto'
      Sketchup.register_extension(ex, true)
      file_loaded(__FILE__)
    #end

  end # module Polcok
end # module Toto
