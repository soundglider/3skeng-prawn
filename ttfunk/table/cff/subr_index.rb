# frozen_string_literal: true

module Tsk3::TTFunk
  class Table
    class Cff < Tsk3::TTFunk::Table
      # CFF Subroutine index.
      class SubrIndex < Tsk3::TTFunk::Table::Cff::Index
        # Subroutine index biase. For correct subroutine selection the
        # calculated bias must be added to the subroutine number operand before
        # accessing the index.
        # @return [Integer]
        def bias
          if items.length < 1240
            107
          elsif items.length < 33_900
            1131
          else
            32_768
          end
        end
      end
    end
  end
end
