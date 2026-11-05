# frozen_string_literal: true

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/reader'

module Tsk3::TTFunk
  class Table
    class Cmap
      # Character to Glyph Index encoding record.
      # This class can be extended with a format-specific
      #
      # @see Tsk3::TTFunk::Table::Cmap::Format00
      # @see Tsk3::TTFunk::Table::Cmap::Format04
      # @see Tsk3::TTFunk::Table::Cmap::Format06
      # @see Tsk3::TTFunk::Table::Cmap::Format10
      # @see Tsk3::TTFunk::Table::Cmap::Format12
      class Subtable
        include Reader

        # Platform ID.
        # @return [Integer]
        attr_reader :platform_id

        # Platform-specific encoding ID.
        # @return [Integere]
        attr_reader :encoding_id

        # Record encoding format.
        # @return [Integer]
        attr_reader :format

        # Most used encoding mappings.
        ENCODING_MAPPINGS = {
          mac_roman: { platform_id: 1, encoding_id: 0 }.freeze,
          # Use microsoft unicode, instead of generic unicode, for optimal
          # Windows support
          unicode: { platform_id: 3, encoding_id: 1 }.freeze,
          unicode_ucs4: { platform_id: 3, encoding_id: 10 }.freeze,
        }.freeze

        # Encode encoding record.
        #
        # @param charmap [Hash{Integer => Integer}] keys are code points in the
        #   used encoding, values are Unicode code points.
        # @param encoding [Symbol] - one of the encodign mapping in
        #   {ENCODING_MAPPINGS}
        # @return [Hash]
        #   * `:platform_id` (<tt>Integer</tt>) - Platform ID of this encoding record.
        #   * `:encoding_id` (<tt>Integer</tt>) - Encodign ID of this encoding record.
        #   * `:subtable` (<tt>String</tt>) - encoded encoding record.
        #   * `:max_glyph_id` (<tt>Integer</tt>) - maximum glyph ID in this encoding
        #     record.
        #   * `:charmap` (<tt>Hash{Integer => Hash}</tt>) - keys are codepoints in this
        #     encoding record, values are hashes:
        #     * `:new` - new glyph ID.
        #     * `:old` - glyph ID in the original font.
        def self.encode(charmap, encoding)
          case encoding
          when :mac_roman
            result = Format00.encode(charmap)
          when :unicode
            result = Format04.encode(charmap)
          when :unicode_ucs4
            result = Format12.encode(charmap)
          else
            raise NotImplementedError,
              "encoding #{encoding.inspect} is not supported"
          end

          mapping = ENCODING_MAPPINGS[encoding]

          # platform-id, encoding-id, offset
          result.merge(
            platform_id: mapping[:platform_id],
            encoding_id: mapping[:encoding_id],
            subtable: [
              mapping[:platform_id],
              mapping[:encoding_id],
              12,
              result[:subtable],
            ].pack('nnNA*'),
          )
        end

        # @param file [Tsk3::TTFunk::File]
        # @param table_start [Integer]
        def initialize(file, table_start)
          @file = file
          @platform_id, @encoding_id, @offset = read(8, 'nnN')
          @offset += table_start

          parse_from(@offset) do
            @format = read(2, 'n').first

            case @format
            when 0 then extend(Tsk3::TTFunk::Table::Cmap::Format00)
            when 4 then extend(Tsk3::TTFunk::Table::Cmap::Format04)
            when 6 then extend(Tsk3::TTFunk::Table::Cmap::Format06)
            when 10 then extend(Tsk3::TTFunk::Table::Cmap::Format10)
            when 12 then extend(Tsk3::TTFunk::Table::Cmap::Format12)
            end

            parse_cmap!
          end
        end

        # Is this an encoding record for Unicode?
        #
        # @return [Boolean]
        def unicode?
          (platform_id == 3 && (encoding_id == 1 || encoding_id == 10) && format != 0) ||
            (platform_id.zero? && format != 0)
        end

        # Is this encoding record format supported?
        #
        # @return [Boolean]
        def supported?
          false
        end

        # Get glyph ID for character code.
        #
        # @param _code [Integer] character code.
        # @return [Integer] glyph ID.
        def [](_code)
          raise NotImplementedError, "cmap format #{@format} is not supported"
        end

        private

        def parse_cmap!
          # do nothing...
        end
      end
    end
  end
end

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap/format00'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap/format04'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap/format06'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap/format10'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap/format12'
