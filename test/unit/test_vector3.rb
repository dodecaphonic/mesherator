require 'test_helper'

module Mesherator
  class Vector3Test < MiniTest::Unit::TestCase
    def setup
      @vector = Vector3.new(0.0, 1.0, -1.0)
    end

    def test_vector_sets_all_dimensions
      assert_equal  0.0, @vector.x
      assert_equal  1.0, @vector.y
      assert_equal -1.0, @vector.z
    end

    def test_equality
      assert_equal @vector, Vector3.new(0.0, 1.0, -1.0)
    end

    def test_cross_product
      other_vector = Vector3.new(2.0, -1.0, -2.0)
      assert_equal Vector3.new(-3.0, -2.0, -2.0), @vector.cross(other_vector)
    end

    def test_has_string_representation
      assert_equal "(0.00, 1.00, -1.00)", @vector.to_s
    end

    def test_can_subtract_another_vector
      other_vector = Vector3.new(1.0, 1.0, 1.0)
      assert_equal Vector3.new(-1.0, 0.0, -2.0), (@vector - other_vector)
    end

    def test_can_sum_another_vector
      other_vector = Vector3.new(1.0, 1.0, 1.0)
      assert_equal Vector3.new(1.0, 2.0, 0.0), (@vector + other_vector)
    end

    def test_can_determine_if_vectors_are_collinear
      v0 = Vector3.new(0.0, 0.0, 0.0)
      v1 = Vector3.new(0.0, 1.0, 0.0)
      v2 = Vector3.new(0.0, -1.0, 0.0)
      assert Vector3.collinear?(v0, v1, v2)
    end

    def test_can_determine_if_vectors_are_not_collinear
      v0 = Vector3.new(1.0, 0.0, 0.0)
      v1 = Vector3.new(2.0, 1.0, 0.0)
      v2 = Vector3.new(0.0, 3.0, 1.0)
      assert Vector3.collinear?(v0, v1, v2) == false
    end

    def test_calculates_its_norm
      assert_equal Math.sqrt(2), @vector.norm
    end
  end
end
