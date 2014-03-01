#fixed by Takayasu_Hayashi for cristal background

#require 'rubygems'
#require 'RMagick'

#require File.dirname(__FILE__) + '/deprecated'

##
# = Gruff. Graphs.
#
# Author:: Geoffrey Grosenbach boss@topfunky.com
#
# Originally Created:: October 23, 2005
#
# Extra thanks to Tim Hunter for writing RMagick, and also contributions by
# Jarkko Laine, Mike Perham, Andreas Schwarz, Alun Eyre, Guillaume Theoret,
# David Stokar, Paul Rogers, Dave Woodward, Frank Oxener, Kevin Clark, Cies
# Breijs, Richard Cowin, and a cast of thousands.
#
# See Gruff::Base#theme= for setting themes.

module Gruff


  class Base

    # You can set a theme manually. Assign a hash to this method before you
    # send your data.
    #
    #  graph.theme = {
    #    :colors => %w(orange purple green white red),
    #    :marker_color => 'blue',
    #    :background_colors => %w(black grey)
    #  }
    #
    # :background_image => 'squirrel.png' is also possible.
    #
    # (Or hopefully something better looking than that.)
    #

    # A color scheme plucked from the colors on the popular usability blog.
    def theme_37signals
      # Colors
      @green = '#339933'
      @purple = '#cc99cc'
      @blue = '#336699'
      @yellow = '#FFF804'
      @red = '#ff0000'
      @orange = '#cf5910'
      @black = 'black'
      @colors = [@black, @blue, @green, @red, @purple, @orange, '#202020']

      self.theme = {
        :colors => @colors,
        :marker_color => 'black',
        :font_color => 'black',
        :background_colors => ['white', 'white']
      }
=begin
      # Colors
      @dark_pink = '#FF3333'
      @dark_blue = '#3a5b87'
      @some_blue= '#3333ee'
      @peach = '#daaea9'
      '#a9a9da' # dk purple
      @green = '#009933'
      @purple = '#cc99cc'
      @light_purple = '#a9a9da'
      @light_blue='#333399'
      @blue = '#0000ff'
      @yellow = '#FFF804'
      @red = '#ff0000'
      @orange = '#cf5910'
      @black = 'black'
      
      @colors = [@black, @some_blue,@green, @red,@dark_pink ,@blue, @orange,@dark_blue ]

      self.theme = {
        :colors => @colors,
        :marker_color => 'black',
        :font_color => 'black',
        :background_colors => ['white', 'white']
      }
=end
    end
  end # Gruff::Base
end # Gruff

