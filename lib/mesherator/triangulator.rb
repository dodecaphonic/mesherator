#  ported from p bourke's triangulate.c
#  http://astronomy.swin.edu.au/~pbourke/terrain/triangulate/triangulate.c
#
#  C to Java:
#  fjenett, 20th february 2005, offenbach-germany.
#  contact: http://www.florianjenett.de/
#
#  Java to Ruby:
#  Gregory Seidman, 2006-11-28, Washington, DC, USA
#  contact: gmail account gseidman
#
#  to view the output: http://processing.org/
#
#  usage: (random vertices) ruby triangulate.rb [num vertices]
#         (benchmark)       ruby triangulate.rb bm

module Mesherator
  Edge = Struct.new(:p1, :p2) do
    def ==(o)
      (p1 == o.p1 && p2 == o.p2) || (p1 == o.p2 && p2 == o.p1)
    end

    def valid?
      p1 && p2
    end

    def reset!
      self.p1 = self.p2 = nil
    end
  end

  Coord = Struct.new(:x, :y)
  EPSILON = 0.000001

  class DelaunayTriangulator
    attr_reader :vertices

    def initialize(vertices)
      @vertices = vertices.sort_by(&:x)
    end

    def points_are_coincident(p1, p2)
      (p1.y - p2.y).abs < EPSILON && (p1.x - p2.x).abs < EPSILON
    end

    def get_bounding_vertices(vertices)
      # Find the maximum and minimum vertex bounds.
      # This is to allow calculation of the bounding triangle
      xmin = vertices[0].x
      ymin = vertices[0].y
      xmax = xmin
      ymax = ymin
      vertices.each { |p|
        xmin = p.x if (p.x < xmin)
        xmax = p.x if (p.x > xmax)
        ymin = p.y if (p.y < ymin)
        ymax = p.y if (p.y > ymax)
      }
      dx = xmax - xmin
      dy = ymax - ymin
      dmax = (dx > dy) ? dx : dy
      xmid = (xmax + xmin) / 2.0
      ymid = (ymax + ymin) / 2.0

      [Coord.new(xmid - 2.0 * dmax, ymid - dmax),
        Coord.new(xmid, ymid + 2.0 * dmax),
        Coord.new(xmid + 2.0 * dmax, ymid - dmax)]
    end

    # Triangulation subroutine
    # Takes as input vertices in array vertices
    # Returned is a list of triangular faces in the array tris
    # These triangles are arranged in a consistent clockwise order.
    def triangulate
      edges = []
      tris = []
      # sort by X coord
      # center/radius cache used by circum_circle
      cc_cache = {}

      # Set up the supertriangle
      # This is a triangle which encompasses all the sample points.
      # The supertriangle coordinates are added to the end of the
      # vertex list. The supertriangle is the first triangle in
      # the triangle list.
      number_of_vertices = vertices.size
      bounding_p1, bounding_p2, bounding_p3 = get_bounding_vertices(vertices)
      vertices << bounding_p1 << bounding_p2 << bounding_p3
      tris << Triangle.new(number_of_vertices, number_of_vertices+1, number_of_vertices+2)

      # Include each point one at a time into the existing mesh
      vertices.each_with_index do |current_point, i|
        edges = []
        # Set up the edge buffer.
        # If the point (xp,yp) lies inside the circumcircle then the
        # three edges of that triangle are added to the edge buffer
        # and that triangle is removed.
        j = 0
        tris_size = tris.size
        while j < tris_size
          current_triangle = tris[j]
          if current_triangle.incomplete?
            p1 = vertices[current_triangle.p1]
            p2 = vertices[current_triangle.p2]
            p3 = vertices[current_triangle.p3]
            inside, xc, yc, r = circum_circle(current_point, p1, p2, p3, cc_cache)
            current_triangle.complete = true if (xc + r) < current_point.x

            if inside
              edges << Edge.new(current_triangle.p1, current_triangle.p2)
              edges << Edge.new(current_triangle.p2, current_triangle.p3)
              edges << Edge.new(current_triangle.p3, current_triangle.p1)
              tris.delete_at(j)
              tris_size -= 1
              j -= 1
            end
          end
          j += 1
        end

        while !edges.empty?
          edge = edges.shift
          rejected = edges.reject! {|e| e == edge}
          tris << Triangle.new(edge.p1, edge.p2, i) if rejected.nil?
        end
      end

      # Remove supertriangle vertices
      3.times do
        vertices.pop
      end
      number_of_vertices = vertices.size

      # Remove triangles with supertriangle vertices
      # These are triangles which have a vertex number greater than number_of_vertices
      tris.delete_if { |tri| tri.p1 >= number_of_vertices || tri.p2 >= number_of_vertices || tri.p3 >= number_of_vertices }

      convert_internal_triangles_to_mesherator_triangles(tris)
    end

    def convert_internal_triangles_to_mesherator_triangles(triangles)
      triangles.map { |triangle|
        Mesherator::Triangle.new(vertices[triangle.p1], vertices[triangle.p2], vertices[triangle.p3])
      }
    end

    # Return TRUE if a point p is inside the circumcircle made up of the
    # points p1, p2, p3
    # The circumcircle center is returned in (xc,yc) and the radius r
    # The return value is an array [ inside, xc, yc, r ]
    # Takes an optional cache hash to use for radius/center caching
    # NOTE: A point on the edge is inside the circumcircle
    def circum_circle(p, p1, p2, p3, cache = nil)
      dx,dy,rsqr,drsqr = []
      cached = cache && cache[[p1, p2, p3]]
      xc, yc, r = []
      rsqr = 0

      if cached
        xc, yc, r, rsqr = cached
      else
        # Check for coincident points
        if (points_are_coincident(p1,p2) || points_are_coincident(p2,p3) || points_are_coincident(p1,p3))
          #puts("CircumCircle: Points are coincident.")
          return [ false, 0, 0, 0 ]
        end

        if (p2.y-p1.y).abs < EPSILON
          m2 = - (p3.x-p2.x) / (p3.y-p2.y)
          mx2 = (p2.x + p3.x) * 0.5
          my2 = (p2.y + p3.y) * 0.5
          xc = (p2.x + p1.x) * 0.5
          yc = m2 * (xc - mx2) + my2
        elsif (p3.y-p2.y).abs < EPSILON
          m1 = - (p2.x-p1.x) / (p2.y-p1.y)
          mx1 = (p1.x + p2.x) * 0.5
          my1 = (p1.y + p2.y) * 0.5
          xc = (p3.x + p2.x) * 0.5
          yc = m1 * (xc - mx1) + my1
        else
          m1 = - (p2.x-p1.x) / (p2.y-p1.y)
          m2 = - (p3.x-p2.x) / (p3.y-p2.y)
          mx1 = (p1.x + p2.x) * 0.5
          mx2 = (p2.x + p3.x) * 0.5
          my1 = (p1.y + p2.y) * 0.5
          my2 = (p2.y + p3.y) * 0.5
          xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
          yc = m1 * (xc - mx1) + my1
        end

        dx = p2.x - xc
        dy = p2.y - yc
        rsqr = dx*dx + dy*dy
        r = Math.sqrt(rsqr)
        cache[[p1, p2, p3]] = [ xc, yc, r, rsqr ] if cache
      end

      dx = p.x - xc
      dy = p.y - yc
      drsqr = dx*dx + dy*dy

      [(drsqr <= rsqr), xc, yc, r]
    end

    class Triangle
      attr_reader :p1, :p2, :p3
      attr_accessor :complete

      def initialize(p1, p2, p3, complete = false)
        @p1 = p1
        @p2 = p2
        @p3 = p3
        @complete = false
      end

      def incomplete?
        !complete
      end
    end
  end
end
