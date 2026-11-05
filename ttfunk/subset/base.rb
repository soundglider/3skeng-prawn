# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/glyf'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/head'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/hhea'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/hmtx'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/kern'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/loca'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/maxp'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/name'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/post'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/simple'

module Tsk3::TTFunk
  module Subset
    # Base subset.
    #
    # @api private
    class Base
      # Microsoft Platform ID
      MICROSOFT_PLATFORM_ID = 3

      # Symbol Encoding ID for Microsoft Platform
      MS_SYMBOL_ENCODING_ID = 0

      # Original font
      #
      # @return [Tsk3::TTFunk::File]
      attr_reader :original

      # @param original [Tsk3::TTFunk::File]
      def initialize(original)
        @original = original
      end

      # Is this Unicode-based subset?
      #
      # @return [Boolean]
      def unicode?
        false
      end

      # Does this subset use Microsoft Symbolic encoding?
      #
      # @return [Boolean]
      def microsoft_symbol?
        new_cmap_table[:platform_id] == MICROSOFT_PLATFORM_ID &&
          new_cmap_table[:encoding_id] == MS_SYMBOL_ENCODING_ID
      end

      # Get a mapping from this subset to Unicode.
      #
      # @return [Hash{Integer => Integer}]
      def to_unicode_map
        {}
      end

      # Encode this subset into a binary font representation.
      #
      # @param options [Hash]
      # @return [String]
      def encode(options = {})
        encoder_klass.new(original, self, options).encode
      end

      # Encoder class for this subset.
      #
      # @return [Tsk3::TTFunk::TTFEncoder, Tsk3::TTFunk::OTFEncoder]
      def encoder_klass
        original.cff.exists? ? OTFEncoder : TTFEncoder
      end

      # Get the first Unicode cmap from the original font.
      #
      # @return [Tsk3::TTFunk::Table::Cmap::Subtable]
      def unicode_cmap
        @unicode_cmap ||= @original.cmap.unicode.first
      end

      # Get glyphs in this subset.
      #
      # @return [Hash{Integer => Tsk3::TTFunk::Table::Glyf::Simple,
      #   Tsk3::TTFunk::Table::Glyf::Compound}] if original is a TrueType font
      # @return [Hash{Integer => Tsk3::TTFunk::Table::Cff::Charstring] if original is
      #   a CFF-based OpenType font
      def glyphs
        @glyphs ||= collect_glyphs(original_glyph_ids)
      end

      # Get glyphs by their IDs in the original font.
      #
      # @param glyph_ids [Array<Integer>]
      # @return [Hash{Integer => Tsk3::TTFunk::Table::Glyf::Simple,
      #   Tsk3::TTFunk::Table::Glyf::Compound>] if original is a TrueType font
      # @return [Hash{Integer => Tsk3::TTFunk::Table::Cff::Charstring}] if original is
      #   a CFF-based OpenType font
      def collect_glyphs(glyph_ids)
        collected =
          glyph_ids.each_with_object({}) do |id, h|
            h[id] = glyph_for(id)
          end

        additional_ids = collected.values
          .select { |g| g && g.compound? }
          .map(&:glyph_ids)
          .flatten

        collected.update(collect_glyphs(additional_ids)) if additional_ids.any?

        collected
      end

      # Glyph ID mapping from the original font to this subset.
      #
      # @return [Hash{Integer => Integer}]
      def old_to_new_glyph
        @old_to_new_glyph ||=
          begin
            charmap = new_cmap_table[:charmap]
            old_to_new =
              charmap.each_with_object(0 => 0) do |(_, ids), map|
                map[ids[:old]] = ids[:new]
              end

            next_glyph_id = new_cmap_table[:max_glyph_id]

            glyphs.each_key do |old_id|
              unless old_to_new.key?(old_id)
                old_to_new[old_id] = next_glyph_id
                next_glyph_id += 1
              end
            end

            old_to_new
          end
      end

      # Glyph ID mapping from this subset to the original font.
      #
      # @return [Hash{Integer => Integer}]
      def new_to_old_glyph
        @new_to_old_glyph ||= old_to_new_glyph.invert
      end

      private

      def glyph_for(glyph_id)
        if original.cff.exists?
          original
            .cff
            .top_index[0]
            .charstrings_index[glyph_id]
            .glyph
        else
          original.glyph_outlines.for(glyph_id)
        end
      end
    end
  end
end
