require 'test_helper'

module Mesherator
  class TestTriangulation < MiniTest::Unit::TestCase
    def points
      [Vector3.new(0, 30), Vector3.new(15, 25), Vector3.new(20, 0),
        Vector3.new(30, 60), Vector3.new(50, 40), Vector3.new(70, 30),
        Vector3.new(55, 20), Vector3.new(50, 10)]
    end

    def setup
      @triangulation = DelaunayTriangulator.new(points)
    end

    def test_performs_triangulation
      triangles = @triangulation.triangulate
      assert_equal 12, triangles.count
    end
  end

  class TestFFITriangulation < MiniTest::Unit::TestCase
    def points
      [Vector3.new(0, 30), Vector3.new(15, 25), Vector3.new(20, 0),
        Vector3.new(30, 60), Vector3.new(50, 40), Vector3.new(70, 30),
        Vector3.new(55, 20), Vector3.new(50, 10)]
    end

    def setup
      @triangulation = FFI::DelaunayTriangulator.new(points)
    end

    def test_performs_triangulation
      triangles = @triangulation.triangulate
      assert_equal 9, triangles.count
    end
  end
end
