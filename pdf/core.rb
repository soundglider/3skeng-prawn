# frozen_string_literal: true

# Top level Module
module Tsk3::PDF
  # Tsk3::PDF::Core is concerned with low-level PDF functions such as serialization,
  # content streams and such.
  #
  # It's extracted from Prawn but at the moment is not entirely independent.
  module Core
    # Tsk3::PDF::Core-specific errors
    module Errors
      # This error indicates failure of {Tsk3::PDF::Core.pdf_object}
      class FailedObjectConversion < StandardError
      end

      # This error occurs when a graphic state is being restored but the graphic
      # state stack is empty.
      class EmptyGraphicStateStack < StandardError
      end

      # This error is raised when page layout is set to anything other than
      # `:portrait` or `:landscape`
      class InvalidPageLayout < StandardError
      end
    end
  end
end

Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/utils'       # Must be loaded first - used by reference.rb and name_tree.rb
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/pdf_object'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/annotations'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/byte_string'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/destinations'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/filters'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/stream'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/reference'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/literal_string'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/filter_list'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/page'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/object_store'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/document_state'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/name_tree'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/graphics_state'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/page_geometry'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/outline_root'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/outline_item'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/renderer'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core/text'
