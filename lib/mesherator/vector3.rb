module Mesherator
  class Vector3
    attr_reader :x, :y, :z

    def initialize(x, y, z = 0.0)
      @x = x
      @y = y
      @z = z
    end

    def ==(other)
      @x == other.x && @y == other.y && @z == other.z
    end

    def cross(other)
      x = self.y * other.z - self.z * other.y
      y = self.z * other.x - self.x * other.z
      z = self.x * other.y - self.y * other.x

      self.class.new(x, y, z)
    end

    def norm
      Math.sqrt(x**2 + y**2 + z**2)
    end

    def -(other)
      self.class.new(x - other.x, y - other.y, z - other.z)
    end

    def +(other)
      self.class.new(x + other.x, y + other.y, z + other.z)
    end

    def to_s
      "(%.2f, %.2f, %.2f)" % [x, y, z]
    end

    def self.collinear?(v0, v1, v2)
      (v1 - v0).cross(v2 - v0).norm == 0.0
    end
  end
end
