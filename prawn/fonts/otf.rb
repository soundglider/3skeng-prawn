# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/fonts/ttf'

module Tsk3::Prawn
  module Fonts
    # OpenType font. This class is used mostly to distinguish OTF from TTF.
    # All functionality is in the {Fonts::TTF} class.
    #
    # @note You shouldn't use this class directly.
    class OTF < TTF
    end
  end
end
