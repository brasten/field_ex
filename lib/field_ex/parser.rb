module FieldEx

  # Parser is responsible for parsing a FieldEx expression into nodes
  # that can be used by FieldEx::Filter to filter objects.
  #
  class Parser
    NODE_CLASS = Node

    # Parse the expression.
    #
    # Use () for nesting and , for grouping.
    #
    # Examples:
    #
    # Given the object:
    #    {
    #      users: [
    #        {
    #          id: "1",
    #          age: 40,
    #          name: {
    #            first: "Xavier", last: "Self"
    #          }
    #        },
    #        {
    #          id: "2",
    #          age: 21,
    #          name: {
    #            first: "Lisa", last: "Kar"
    #          }
    #        }
    #      ]
    #    }
    #
    # ... and the PQ expression:
    #    users(id,name(last))
    #
    # ... parse should return a tree useful for capturing:
    #
    #    {
    #      users: [
    #        {
    #          id: "1",
    #          name: { last: "Self" }
    #        },
    #        {
    #          id: "2",
    #          name: { last: "Kar" }
    #        }
    #      ]
    #    }
    #
    def parse(str)
      top = NODE_CLASS.new()
      current_parent = top
      name = NameBuilder.new

      str.each_char do |c|
        case c
        when FieldEx::SEPARATOR
          current_parent << NODE_CLASS.new(name.use!) unless name.empty?
        when FieldEx::NESTING[0]
          node = NODE_CLASS.new(name.use!)
          current_parent = current_parent << node
        when FieldEx::NESTING[-1]
          node = NODE_CLASS.new(name.use!)
          current_parent << node
          current_parent = current_parent.parent
        else
          name << c
        end
      end
      current_parent << NODE_CLASS.new(name.use!) unless name.empty?

      top
    end

    private

    class NameBuilder
      def initialize
        @str = ""
      end

      def <<(char)
        @str << char
      end

      def empty?
        @str.strip.empty?
      end

      def use!
        value = @str.strip
        @str = ""
        value
      end
    end

  end
end
