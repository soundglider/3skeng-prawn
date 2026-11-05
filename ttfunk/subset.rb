# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/unicode'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/unicode_8bit'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/mac_roman'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/windows_1252'

module Tsk3::TTFunk
  # Namespace for different types of subsets.
  module Subset
    # Create a subset for the font using the specified encoding.
    #
    # @param original [Tsk3::TTFunk::File]
    # @param encoding [:unicode, :unicode_8bit, :mac_roman, :windows_1252]
    # @raise [NotImplementedError] for unsupported encodings
    # @return [Tsk3::TTFunk::Subset::Unicode, Tsk3::TTFunk::Subset::Unicode8Bit,
    #   Tsk3::TTFunk::Subset::MacRoman, Tsk3::TTFunk::Subset::Windows1252]
    def self.for(original, encoding)
      case encoding.to_sym
      when :unicode then Unicode.new(original)
      when :unicode_8bit then Unicode8Bit.new(original)
      when :mac_roman then MacRoman.new(original)
      when :windows_1252 then Windows1252.new(original) # rubocop: disable Naming/VariableNumber
      else raise NotImplementedError, "encoding #{encoding} is not supported"
      end
    end
  end
end
