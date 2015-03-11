module FieldEx
  module Partial
    def partial(filter)
      FieldEx::Extractor.new(filter).on(self)
    end
  end
end
