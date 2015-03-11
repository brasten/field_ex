require "field_ex/version"

# FieldEx parses field query expressions
#
# @see FieldEx::Parser.parse
#
module FieldEx
  SEPARATOR = ","
  NESTING   = "()"
  WILDCARD  = "*"
  NEGATION  = "!"

  # Helper method for filtering options hashes provided to as_json(opts)
  # methods.
  #
  # @param [Hash] options
  # @param [String] key
  # @return [Hash] new options hash
  #
  def self.options_for(options, key)
    options = options.dup

    if fields = options.delete(:fields)
      if f = fields.node_for(key)
        options[:fields] = f
      end
    end

    options
  end

  def self.parse(*exp)
    parser = Parser.new()

    exp.map { |e| e.kind_of?(Node) ? e : parser.parse(e) }.reduce(:+)
  end

  def json_options_for(options={}, key)
    FieldEx.options_for(options, key)
  end

end

require 'field_ex/extractor'
require 'field_ex/filter'
require 'field_ex/node'
require 'field_ex/param'
require 'field_ex/parser'
require 'field_ex/partial'
