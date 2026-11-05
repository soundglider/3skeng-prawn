# frozen_string_literal: true

require 'stringio'
require 'pathname'

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/aggregate'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/directory'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/resource_file'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/collection'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/ttf_encoder'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/encoded_string'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/placeholder'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/otf_encoder'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/sci_form'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/bit_field'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/bin_utils'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/sub_table'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/min'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/max'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/sum'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/one_based_array'

# TTFunk is a TrueType and OpenType font library written in pure ruby. It
# supports both parsing and encoding of fonts. Also provides limited font
# subsetting.
#
# It supports a veriety of SFNT-based formats:
# * TrueType fonts (ttf)
# * OpenType fonts (otf), with both TrueType and CFF glyph outlines
# * DFont resources (dfont)
# * TrueType Collections (ttc)
#
# While not all TrueType and OpenType tables are implemented the most common
# ones are.
module Tsk3::TTFunk
  # TTFunk-specific exceptions
  class Error < StandardError; end

  # File represents an individual font. It can represents both TrueType and
  # OpenType fonts.
  class File
    # Raw content of the font.
    # @return [String]
    attr_reader :contents

    # Font tables directory.
    # @return [Tsk3::TTFunk::Directory]
    attr_reader :directory

    # Open font file
    #
    # @overload open(io)
    #   @param io [IO] IO to read font content from. IO position and binmode
    #     might change.
    #   @return [Tsk3::TTFunk::File]
    # @overload open(path)
    #   @param path [String, Pathname] Path to file to read the font from.
    #   @return [Tsk3::TTFunk::File]
    def self.open(io_or_path)
      new(verify_and_read(io_or_path))
    end

    # Load a font from a resource file.
    #
    # @param file [String, Pathname] Path to the resource file.
    # @param which [Integer, String] index or name of the font to load
    # @return [Tsk3::TTFunk::File]]
    def self.from_dfont(file, which = 0)
      new(ResourceFile.open(file) { |dfont| dfont['sfnt', which] })
    end

    # Load a font from a TrueType collection.
    #
    # @overload from_ttc(io, which = 0)
    #   @param file [IO] IO to read the collection from.
    #   @param which [Integer] index of the font to load
    #   @return [Tsk3::TTFunk::File]
    # @overload from_ttc(file_path, which = 0)
    #   @param file_path [String, Pathname] Path to the resource file.
    #   @param which [Integer] index of the font to load
    #   @return [Tsk3::TTFunk::File]
    def self.from_ttc(file, which = 0)
      Collection.open(file) { |ttc| ttc[which] }
    end

    # Turn a path or IO into an IO convenient for TTFunk. The resulting IO is
    # going to be in bin mode and its position set to the beginning.
    #
    # @overload verify_and_open(io)
    #   @param io [IO] IO to prepare. Its position and binmode might
    #     change.
    #   @return [io]
    # @overload verify_and_open(path)
    #   @param path [String, Pathname] path of the file to turn into an IO.
    #   @return [IO] newly opened IO for the path
    # @deprecated This method might retain open files for longer than necessary.
    # @see .verify_and_read
    def self.verify_and_open(io_or_path)
      # File or IO
      if io_or_path.respond_to?(:rewind)
        io = io_or_path
        # Rewind if the object we're passed is an IO, so that multiple embeds of
        # the same IO object will work
        io.rewind
        # read the file as binary so the size is calculated correctly
        # guard binmode because some objects acting io-like don't implement it
        io.binmode if io.respond_to?(:binmode)
        return io
      end
      # String or Pathname
      io_or_path = Pathname.new(io_or_path)
      raise ArgumentError, "#{io_or_path} not found" unless io_or_path.file?

      io_or_path.open('rb')
    end

    # Read contents of a path or IO.
    #
    # @overload verify_and_read(io)
    #   @param io [IO] IO to read from. Its position and binmode might
    #     change. IO is read from the beginning regardless of its initial
    #     position.
    #   @return [String]
    # @overload verify_and_read(path)
    #   @param path [String, Pathname] path of the file to read.
    #   @return [String]
    def self.verify_and_read(io_or_path)
      # File or IO
      if io_or_path.respond_to?(:rewind)
        io = io_or_path
        # Rewind if the object we're passed is an IO, so that multiple embeds of
        # the same IO object will work
        io.rewind
        # read the file as binary so the size is calculated correctly
        # guard binmode because some objects acting io-like don't implement it
        io.binmode if io.respond_to?(:binmode)
        return io.read
      end
      # String or Pathname
      io_or_path = Pathname.new(io_or_path)
      raise ArgumentError, "#{io_or_path} not found" unless io_or_path.file?

      io_or_path.binread
    end

    # @param contents [String] binary string containg the font data
    # @param offset [Integer] offset at which the font data starts
    def initialize(contents, offset = 0)
      @contents = StringIO.new(contents)
      @directory = Directory.new(@contents, offset)
    end

    # Glyphs ascent as defined for in the font.
    #
    # @return [Integer]
    def ascent
      @ascent ||= (os2.exists? && os2.ascent && os2.ascent.nonzero?) ||
        horizontal_header.ascent
    end

    # Glyphs descent as defined in the font.
    #
    # @return [Integer]
    def descent
      @descent ||= (os2.exists? && os2.descent && os2.descent.nonzero?) ||
        horizontal_header.descent
    end

    # Line gap as defined in the font.
    #
    # @return [Integer]
    def line_gap
      @line_gap ||= (os2.exists? && os2.line_gap && os2.line_gap.nonzero?) ||
        horizontal_header.line_gap
    end

    # Glyps bounding box as defined in the font.
    #
    # @return [Array(Integer, Integer, Integer, Integer)]
    def bbox
      [header.x_min, header.y_min, header.x_max, header.y_max]
    end

    # Font directory entry for the table with the provided tag.
    #
    # @param tag [String] table tab
    # @return [Hash, nil]
    def directory_info(tag)
      directory.tables[tag.to_s]
    end

    # Font Header (`head`) table
    #
    # @return [Tsk3::TTFunk::Table::Head, nil]
    def header
      @header ||= Tsk3::TTFunk::Table::Head.new(self)
    end

    # Character to Glyph Index Mapping (`cmap`) table
    #
    # @return [Tsk3::TTFunk::Tbale::Cmap, nil]
    def cmap
      @cmap ||= Tsk3::TTFunk::Table::Cmap.new(self)
    end

    # Horizontal Header (`hhea`) table
    #
    # @return [Tsk3::TTFunk::Table::Hhea, nil]
    def horizontal_header
      @horizontal_header ||= Tsk3::TTFunk::Table::Hhea.new(self)
    end

    # Horizontal Metrics (`hmtx`) table
    #
    # @return [Tsk3::TTFunk::Table::Hmtx, nil]
    def horizontal_metrics
      @horizontal_metrics ||= Tsk3::TTFunk::Table::Hmtx.new(self)
    end

    # Maximum Profile (`maxp`) table
    #
    # @return [Tsk3::TTFunk::Table::Maxp, nil]
    def maximum_profile
      @maximum_profile ||= Tsk3::TTFunk::Table::Maxp.new(self)
    end

    # Kerning (`kern`) table
    #
    # @return [Tsk3::TTFunk::Table::Kern, nil]
    def kerning
      @kerning ||= Tsk3::TTFunk::Table::Kern.new(self)
    end

    # Naming (`name`) table
    #
    # @return [Tsk3::TTFunk::Table::Name, nil]
    def name
      @name ||= Tsk3::TTFunk::Table::Name.new(self)
    end

    # OS/2 and Windows Metrics (`OS/2`) table
    #
    # @return [Tsk3::TTFunk::Table:OS2, nil]
    def os2
      @os2 ||= Tsk3::TTFunk::Table::OS2.new(self)
    end

    # PostScript (`post`) table
    #
    # @return [Tsk3::TTFunk::Table::Post, nil]
    def postscript
      @postscript ||= Tsk3::TTFunk::Table::Post.new(self)
    end

    # Index to Location (`loca`) table
    #
    # @return [Tsk3::TTFunk::Table::Loca, nil]
    def glyph_locations
      @glyph_locations ||= Tsk3::TTFunk::Table::Loca.new(self)
    end

    # Glyph Data (`glyf`) table
    #
    # @return [Tsk3::TTFunk::Table::Glyf, nil]
    def glyph_outlines
      @glyph_outlines ||= Tsk3::TTFunk::Table::Glyf.new(self)
    end

    # Standard Bitmap Graphics (`sbix`) table
    #
    # @return [Tsk3::TTFunk::Table::Sbix, nil]
    def sbix
      @sbix ||= Tsk3::TTFunk::Table::Sbix.new(self)
    end

    # Compact Font Format (`CFF `) table
    #
    # @return [Table::Table::Cff, nil]
    def cff
      @cff ||= Tsk3::TTFunk::Table::Cff.new(self)
    end

    # Vertical Origin (`VORG`) table
    #
    # @return [Tsk3::TTFunk::Table::Vorg, nil]
    def vertical_origins
      @vertical_origins ||=
        if directory.tables.include?(Tsk3::TTFunk::Table::Vorg::TAG)
          Tsk3::TTFunk::Table::Vorg.new(self)
        end
    end

    # Digital Signature (`DSIG`) table
    #
    # @return [Tsk3::TTFunk::Table::Dsig, nil]
    def digital_signature
      @digital_signature ||=
        if directory.tables.include?(Tsk3::TTFunk::Table::Dsig::TAG)
          Tsk3::TTFunk::Table::Dsig.new(self)
        end
    end

    # Find glyph by its index.
    #
    # @return [Tsk3::TTFunk::Table::Cff::Charstring] if it's a CFF-based OpenType font
    # @return [Tsk3::TTFunk::Table::Glyf::Simple, Tsk3::TTFunk::Table::Glyf::Compound]
    #   if it's a TrueType font
    def find_glyph(glyph_id)
      if cff.exists?
        cff.top_index[0].charstrings_index[glyph_id].glyph
      else
        glyph_outlines.for(glyph_id)
      end
    end
  end
end

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cff'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/cmap'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/dsig'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/glyf'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/head'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/hhea'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/hmtx'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/kern'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/loca'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/maxp'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/name'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/os2'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/post'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/sbix'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk/table/vorg'
