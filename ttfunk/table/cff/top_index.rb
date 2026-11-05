# frozen_string_literal: true

module Tsk3::TTFunk
  class Table
    class Cff < Tsk3::TTFunk::Table
      # CFF Index conatining Top dict.
      class TopIndex < Tsk3::TTFunk::Table::Cff::Index
        private

        def decode_item(_index, offset, length)
          Tsk3::TTFunk::Table::Cff::TopDict.new(file, offset, length)
        end

        def encode_items(*)
          # Re-encode the top dict
          map(&:encode)
        end
      end
    end
  end
end
