# frozen_string_literal: true

require 'set'

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/subset/code_page'

module Tsk3::TTFunk
  module Subset
    # Mac Roman subset. It uses code page 10,000 and Mac OS Roman encoding.
    class MacRoman < CodePage
      # @param original [Tsk3::TTFunk::File]
      def initialize(original)
        super(original, 10_000, Encoding::MACROMAN)
      end
    end
  end
end
