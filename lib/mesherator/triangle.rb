module Mesherator
  class DegenerateTriangleError < StandardError; end

  class Triangle
    attr_reader :first_vertex, :second_vertex, :third_vertex

    def initialize(v0, v1, v2, complete = false, vector_helper = Vector3)
      raise DegenerateTriangleError if vector_helper.collinear?(v0, v1, v2)
      @first_vertex = v0
      @second_vertex = v1
      @third_vertex = v2
      @complete
    end

    def incomplete?
      !@complete
    end

    def vertices
      [@first_vertex, @second_vertex, @third_vertex]
    end
  end
end
