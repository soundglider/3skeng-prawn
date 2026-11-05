# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table'

module Tsk3::TTFunk
  class Table
    # Glyph Data (`glyf`) table.
    class Glyf < Table
      # Encode table.
      #
      # @param glyphs [Hash] a hash mapping (old) glyph-ids to glyph objects
      # @param new_to_old [Hash{Integer => Integer}] a hash mapping new glyph
      #   IDs to glyph IDs in the original font.
      # @param old_to_new [Hash{Integer => Integer}] a hash mapping old glyph
      #   IDs to new glyph IDs.
      # @return [Hash]
      #   * `:table` (<tt>String</tt>) - encoded table.
      #   * `:offsets` (<tt>Array\<Integer></tt>) - glyph offsets in the table.
      def self.encode(glyphs, new_to_old, old_to_new)
        result = { table: +'', offsets: [] }

        new_to_old.keys.sort.each do |new_id|
          glyph = glyphs[new_to_old[new_id]]
          result[:offsets] << result[:table].length
          result[:table] << glyph.recode(old_to_new) if glyph
        end

        # include an offset at the end of the table, for use in computing the
        # size of the last glyph
        result[:offsets] << result[:table].length
        result
      end

      # Get glyph by ID.
      #
      # @param glyph_id [Integer]
      # @return [Tsk3::TTFunk::Table::Glyf::Simple, Tsk3::TTFunk::Table::Glyf::Compound,
      #   nil]
      def for(glyph_id)
        return @cache[glyph_id] if @cache.key?(glyph_id)

        index = file.glyph_locations.index_of(glyph_id)
        size = file.glyph_locations.size_of(glyph_id)

        if size.zero? # blank glyph, e.g. space character
          @cache[glyph_id] = nil
          return
        end

        parse_from(offset + index) do
          raw = io.read(size)
          number_of_contours = to_signed(raw.unpack1('n'))

          @cache[glyph_id] =
            if number_of_contours == -1
              Compound.new(glyph_id, raw)
            else
              Simple.new(glyph_id, raw)
            end
        end
      end

      private

      def parse!
        # because the glyf table is rather complex to parse, we defer
        # the parse until we need a specific glyf, and then cache it.
        @cache = {}
      end
    end
  end
end

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/glyf/compound'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/glyf/path_based'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/glyf/simple'
