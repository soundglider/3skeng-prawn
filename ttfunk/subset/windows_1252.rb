# frozen_string_literal: true

require 'set'

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/code_page'

module Tsk3::TTFunk
  module Subset
    # Windows 1252 sbset. It uses code page 1252 and Windows-1252 encoding.
    class Windows1252 < CodePage
      # @param original [Tsk3::TTFunk::File]
      def initialize(original)
        super(original, 1252, Encoding::CP1252)
      end
    end
  end
end
