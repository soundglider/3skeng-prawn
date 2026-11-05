# frozen_string_literal: true

module Tsk3::TTFunk
  class Table
    class Cff < Tsk3::TTFunk::Table
      # CFF Header.
      class Header < Tsk3::TTFunk::SubTable
        # CFF table major version.
        # @return [Integer]
        attr_reader :major

        # CFF table minor version.
        # @return [Integer]
        attr_reader :minor

        # Size of the header itself.
        # @return [Integer]
        attr_reader :header_size

        # Size of all offsets from beginning of table.
        # @return [Integer]
        attr_reader :absolute_offset_size

        # Length of header.
        #
        # @return [Integer]
        def length
          4
        end

        # Encode header.
        #
        # @return [String]
        def encode
          [major, minor, header_size, absolute_offset_size].pack('C*')
        end

        private

        def parse!
          @major, @minor, @header_size, @absolute_offset_size = read(4, 'C*')
        end
      end
    end
  end
end
