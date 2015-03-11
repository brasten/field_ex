module FieldEx
  class Param
    KEY = :fields

    def initialize(request, key: KEY)
      @key = key
      @request = request
    end

    def value
      @request.params[@key] || @request["zoe.default_fields"]
    end
  end
end
