module FieldEx

  # FIXME [bls]: The responsibility of this class is not well defined. This is
  #              kind of a mess. Do NODES filter objects, or do filters filter
  #              objects using nodes?
  #
  class Filter
    attr_reader :node

    def initialize(node)
      @node = node
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
      if !has_children?
        keys.dup
      elsif has_wildcard?
        keys.map(&:to_sym) - negating_children.map(&:name).map(&:to_sym)
      else

      end
    end

    def allow?(key)
      if node.has_wildcard?
        node.has_negation_for?(key)
      else
        node.has_path?(key.to_s)
      end
    end

    # Apply filter to object (or array of object).
    #
    def on(obj_or_arr)
      return obj_or_arr if @node.children.empty?

      if obj_or_arr.kind_of?(Array)
        obj_or_arr.map do |obj|
          self.class.new(@node).on(obj)
        end
      else
        explode(@node.children, obj_or_arr).inject({}) do |hsh, child|
          if value = obj_or_arr[child.name.to_s]
            hsh[child.name.to_s] = Filter.new(child).on( value )
          elsif value = obj_or_arr[child.name.to_sym]
            hsh[child.name.to_sym] = Filter.new(child).on( value )
          end
          hsh
        end
      end
    end

    # If there are any wildcard children here, include a basic node for all
    # attributes on the object. Keep any existing nodes, however.
    #
    # Also has the nice side-effect of maintaining object key ordering.
    #
    def explode(nodes, obj)
      is_wildcard = nodes.any?(&:wildcard?)
      negations   = nodes.find_all(&:negation?).map(&:name)

      obj.keys.map { |key|
        nodes.find { |c| c.name == key.to_s } || (is_wildcard && !negations.include?("!#{key.to_s}") ? Node.new(key, parent: @node) : nil)
      }.compact
    end
  end
end
