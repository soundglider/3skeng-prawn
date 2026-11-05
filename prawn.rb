# frozen_string_literal: true
#
# Prawn PDF bundled for 3skeng - wrapped in Tsk3 namespace
# Original: https://github.com/prawnpdf/prawn (version 2.5.0)
# License: upstream offers its LICENSE conditions, GPLv2 or GPLv3. 3skeng uses the
#          LICENSE conditions, not the GPL. See THIRD_PARTY_NOTICE.txt and LICENSE.txt.
#
# Prawn is a fast, nimble PDF generation library for Ruby.
#
# Usage:
#   Tsk3::Prawn::Document.generate("output.pdf") do |pdf|
#     pdf.text "Hello World!"
#   end
#
# © 2025 by SHK Engineering and Consulting GmbH & Co KG (bundling/namespacing)

require 'set'

# Load dependencies first
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/ttfunk'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/pdf/core'

# Welcome to Prawn, the best PDF Generation library ever.
# This documentation covers user level functionality.
module Tsk3::Prawn
  # Prawn base directory (for data files)
  file = __FILE__
  file = File.readlink(file) if File.symlink?(file)
  dir = File.dirname(file)

  # The base source directory for Prawn as installed on the system.
  BASEDIR = File.expand_path(dir)

  # Directory where Prawn keeps its data files (fonts are in DATADIR/fonts).
  DATADIR = File.expand_path(File.join(dir, 'prawn'))

  # @deprecated This is not used any more.
  FLOAT_PRECISION = 1.0e-9

  # When set to `true`, Prawn will verify hash options to ensure only valid keys
  # are used. Off by default.
  #
  # @private
  # @return [Boolean]
  attr_accessor :debug

  module_function :debug, :debug= # rubocop:disable Style/AccessModifierDeclarations

  module_function

  # @private
  # @param accepted [Array<Symbol>] list of valid options
  # @param actual [Hash<Symbol, any>] options hash to validate
  # @return [void]
  # @raise [Tsk3::Prawn::Errors::UnknownOption]
  # @yield
  def verify_options(accepted, actual)
    return unless debug || $DEBUG

    unless (act = Set[*actual.keys]).subset?(acc = Set[*accepted])
      raise Tsk3::Prawn::Errors::UnknownOption,
        "\nDetected unknown option(s): #{(act - acc).to_a.inspect}\nAccepted options are: #{accepted.inspect}"
    end
    yield if block_given?
  end
end

# Load Prawn modules
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/version'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/errors'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/image_handler'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/utilities'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/text'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/graphics'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/images'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/images/image'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/images/jpg'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/images/png'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/stamp'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/soft_mask'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/security'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/transformation_stack'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/document'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/font'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/measurements'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/repeater'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/outline'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/grid'
Sketchup.require 'shk_3skeng/Tsk3_Ext/prawn/prawn/view'
