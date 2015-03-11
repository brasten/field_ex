module FieldEx

  # Accepts a Partial Response query string and applies it to
  # a hash.
  #
  class Extractor
    def initialize(*paths)
      nodes = paths.map { |path| Parser.new.parse(path) }.reduce(:+)
      # puts "NODES: #{nodes.inspect}"

      @filter = Filter.new(nodes)
    end

    def on(obj)
      @filter.on(obj)
    end
  end
end
