require 'ffi'

module Mesherator
  module FFI
    extend ::FFI::Library
    ffi_lib 'libtriangle.dylib'

    typedef :pointer, :triangulateio

    attach_function :triangulate, [:string, :triangulateio, :triangulateio, :triangulateio], :void
    attach_function :trifree, [:pointer], :void

    class TriangulateIO < ::FFI::Struct
      layout :pointlist, :pointer,
             :pointattributelist, :pointer,
             :pointmarkerlist, :pointer,
             :numberofpoints, :int,
             :numberofpointattributes, :int,
             :trianglelist, :pointer,
             :triangleattributelist, :pointer,
             :trianglearealist, :pointer,
             :neighborlist, :pointer,
             :numberoftriangles, :int,
             :numberofcorners, :int,
             :numberoftriangleattributes, :int,
             :segmentlist, :pointer,
             :segmentmarkerlist, :pointer,
             :numberofsegments, :int,
             :holelist, :pointer,
             :numberofholes, :int,
             :regionlist, :pointer,
             :numberofregions, :int,
             :edgelist, :pointer,
             :edgemarkerlist, :pointer,
             :normlist, :pointer,
             :numberofedges, :int
    end

    class DelaunayTriangulator
      attr_reader :points

      def initialize(points)
        @points = points
      end

      def triangulate
        point_array_ptr = ::FFI::MemoryPointer.new(:double, points.size * 2)
        point_array_ptr.write_array_of_double(flatten(points))

        input  = TriangulateIO.new
        output = TriangulateIO.new

        input[:pointlist] = point_array_ptr
        input[:numberofpoints] = points.size
        input[:numberofpointattributes] = 0

        FFI.triangulate 'czeXQ', input, output, nil

        triangles = read_triangles(output)
        triangles
      ensure
        free input
        free output
      end

      private
      def flatten(point_set)
        point_set.map { |c| [c.x, c.y] }.flatten
      end

      def read_triangles(triangulateio)
        triangle_count   = triangulateio[:numberoftriangles]
        triangle_indices = triangulateio[:trianglelist].read_array_of_int(triangle_count * 3)

        triangles = []

        0.step(triangle_indices.size - 1, 3) do |first_point_index|
          p0 = points[triangle_indices[first_point_index]]
          p1 = points[triangle_indices[first_point_index + 1]]
          p2 = points[triangle_indices[first_point_index + 2]]
          triangles << Triangle.new(p0, p1, p2)
        end

        triangles
      end

      def free(triangulateio_ptr)
      end
    end
  end
end
