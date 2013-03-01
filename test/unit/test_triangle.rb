require 'test_helper'
require 'ostruct'

module Mesherator
  class TestTriangle < MiniTest::Unit::TestCase
    def setup
      vector = mock('Vector3')
      vector.expects(:collinear?).returns false

      @v0 = stub_vector
      @v1 = stub_vector
      @v2 = stub_vector
      @triangle = Triangle.new(@v0, @v1, @v2, vector_helper: vector)
    end

    def test_raises_error_on_collinear_vectors
      vector = mock('Vector3')
      vector.expects(:collinear?).returns true

      assert_raises(DegenerateTriangleError) do
        Triangle.new(stub_vector, stub_vector, stub_vector, vector_helper: vector)
      end
    end

    def test_has_accessors_for_each_vertex
      assert_equal @v0, @triangle.first_vertex
      assert_equal @v1, @triangle.second_vertex
      assert_equal @v2, @triangle.third_vertex
    end

    def test_creates_an_array_with_vertices
      assert_equal [@v0, @v1, @v2], @triangle.vertices
    end

    def stub_vector(x = 0, y = 0, z = 0)
      stub('vector', x: x, y: y, z: z)
    end
  end
end
