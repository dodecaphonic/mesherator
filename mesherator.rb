require 'sinatra'
require 'json'

require_relative 'lib/mesherator'

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

post '/triangulate/:fast_or_slow' do
  content_type :json

  if params[:fast_or_slow] == 'slow'
    triangulate(json_to_vector3_list(params[:points]))
  else
    triangulate_ffi(json_to_vector3_list(params[:points]))
  end
end

def vector3_to_hash(vector3)
  { x: vector3.x, y: vector3.y, z: vector3.z }
end

def triangle_to_array_of_vector3_hashes(triangle)
  [
    vector3_to_hash(triangle.first_vertex),
    vector3_to_hash(triangle.second_vertex),
    vector3_to_hash(triangle.third_vertex)
  ]
end

def triangulate(points)
  triangulator = Mesherator::DelaunayTriangulator.new(points)
  triangulator.triangulate.map { |triangle|
    triangle_to_array_of_vector3_hashes(triangle)
  }.to_json
end

def triangulate_ffi(points)
  triangulator = Mesherator::TriangleFFI::DelaunayTriangulator.new(points)
  triangulator.triangulate.map { |triangle|
    triangle_to_array_of_vector3_hashes(triangle)
  }.to_json
end

def json_to_vector3_list(points)
  points.values.map { |p| Mesherator::Vector3.new(p['x'].to_f, p['y'].to_f, p['z'].to_f) }
end
