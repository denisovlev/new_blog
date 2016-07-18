module BSON
  class ObjectId

    def to_json(arg=nil)
      to_s.to_json
    end

    def as_json(arg=nil)
      to_s
    end

  end
end