# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table'

module Tsk3::TTFunk
  class Table
    # A table that TTFunk doesn't decode but preserve.
    class Simple < Table
      # Table tag
      # @return [String]
      attr_reader :tag

      # @param file [Tsk3::TTFunk::File]
      # @param tag [String]
      def initialize(file, tag)
        @tag = tag
        super(file)
      end
    end
  end
end
