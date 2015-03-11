require 'path_ex'

module FieldEx

  # Represents a single node in a field expression.
  #
  # Field expressions are parsed into tree structures.
  #
  # FIXME: This class IS NOT THREAD-SAFE.
  #        This would be relatively easy to fix, but it not required given
  #        the currently-anticipated use-cases.
  #
  class Node
    attr_accessor :name,
                  :parent,
                  :children

    # @param [#to_s] name
    # @param [Node] parent
    # @param [Array<Node>] children
    #
    def initialize( name=nil, parent:nil, children:[] )
      @name     = name.to_s
      @parent   = parent
      @children = children.dup
    end

    def allow?(key)
      !allowed_from(key).empty?
    end

    # Given a list of possible keys, which keys would this node
    # permit?
    #
    # If this node has no children, then all keys are allowed.
    #
    # @param [*#to_sym] keys
    # @return [Array<Symbol>]
    #
    def allowed_from(*keys)
      keys = keys.map(&:to_sym)
      return keys if !has_children?

      if has_wildcard?
        keys - negating_children.lazy.map(&:negated_name).map(&:to_sym).to_a
      else
        keys & children.lazy.map(&:name).map(&:to_sym).to_a
      end
    end

    # Adds a child node to this node. Merges the provided node
    # with any existing children that have an identical name.
    #
    # FIXME: Thread-safty.
    #
    # @param [Node] node
    # @return a new representation of the node, after merging
    #         and modifications.
    #
    def <<(node)
      existing = node_for(node.name)

      if existing
        children.delete(existing)

        self.children << (existing + node)
      else
        node.parent = self
        self.children << node
        node
      end
    end

    alias_method :add_node, :<<

    # Returns the node in this node's hierarchy that corresponds to the
    # provided dot-notation-compatible path.
    #
    # @param [String, PathEx::Key] path_or_key
    # @return [Node, nil]
    #
    def node_for(path_or_key)
      key = PathEx::Key.new(path_or_key)
      return nil if key.blank?

      child = self.children.find { |c| c.name == key.head }
      child.nil? ? nil : key.has_tail? ? child.node_for(key.tail) : child
    end

    # Returns true if this node has a descendant that corresponds to the
    # provided dot-notation path.
    #
    # @param [String, PathEx::Key] path dot-delimited key path
    # @return [Boolean]
    #
    def has_path?(path)
      !node_for(path).nil?
    end

    def has_children?
      !children.empty?
    end

    def has_wildcard?
      return false if children.empty?

      children.any? { |c| c.wildcard? }
    end

    def has_negation_for?(key)
      !children.find { |c| c.negates?(key) }.nil?
    end

    # Returns true if this node is a wildcard "*"
    #
    def wildcard?
      name.start_with?(FieldEx::WILDCARD)
    end

    # Returns true if this node is a negation node.
    #
    def negation?
      name.start_with?(FieldEx::NEGATION)
    end

    def negated_name
      name[1..-1]
    end

    def negates?(key)
      negation? && key.to_s == negated_name
    end

    # Returns a list of children that would affect how inclusive this node
    # can ultimately be.
    #
    # @return [Array<Node>]
    #
    def negating_children
      return [] if !has_children?

      children.find_all(&:negation?)
    end

    def to_s
      "#<FieldEx::Node:#{object_id}\n" +
      "  name        : '#{name}'\n" +
      "  parent.name : '#{parent.nil? ? 'nil' : parent.name}'\n" +
      "  children    : '#{children.map(&:name).inspect}'>"
    end

    def each(&block)
      @children.each(&block)
    end

    def dup
      Node.new( name, parent: parent, children: children.map(&:dup) )
    end

    # Merges this and another Node together.
    #
    def +(other)
      target = nil

      if other.name == name
        target = Node.new(name, parent: parent)

        other_children = other.children.dup

        self.each do |child|
          other_child = other_children.find { |c| c.name == child.name }

          if other_child
            other_children.delete(other_child)
            target << child + other_child
          else
            target << child.dup
          end
        end

        # Remaining other children
        other_children.each do |other_child|
          target << other_child.dup
        end

      else
        target = Node.new()
        target << self.dup
        target << other.dup
      end

      target
    end

  end
end
