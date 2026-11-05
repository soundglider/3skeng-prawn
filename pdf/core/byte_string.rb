# frozen_string_literal: true

module Tsk3::PDF
  module Core
    # This is used to differentiate strings that must be encoded as
    # a byte string, such as binary data from encrypted strings.
    #
    # @api private
    class ByteString < String
    end
  end
end
