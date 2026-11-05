# frozen_string_literal: true

module Tsk3::TTFunk
  # Base class for different aggregate values and accumulators.
  #
  # @see Tsk3::TTFunk::Min
  # @see Tsk3::TTFunk::Max
  # @see Tsk3::TTFunk::Sum
  class Aggregate
    private

    def coerce(other)
      if other.respond_to?(:value_or)
        other.value_or(0)
      else
        other
      end
    end
  end
end
