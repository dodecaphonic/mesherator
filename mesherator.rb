require 'sinatra'
require 'json'

require_relative 'lib/mesherator'

if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144
end

POINTS = {
  small: [],
  medium: [],
  large: []
}

%w(small medium large).each do |data_set|
  points = open(File.expand_path("../public/data/#{data_set}.txt", __FILE__)).readlines.map { |l|
    Mesherator::Vector3.new(*l.scan(/\d+,\d+/).map { |v|
                              v.sub(',', '.').to_f
                            })
  }

  POINTS[data_set.to_sym] = points
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

get '/small/points' do
  content_type :json
  POINTS[:small].map { |p| vector3_to_hash(p) }.to_json
end

get '/small/triangulate' do
  content_type :json
  triangulate(POINTS[:small])
end

get '/small/triangulate/ffi' do
  content_type :json
  triangulate_ffi(POINTS[:small])
end

get '/medium/points' do
  content_type :json
  POINTS[:medium].map { |p| vector3_to_hash(p) }.to_json
end

get '/medium/triangulate' do
  content_type :json
  triangulate(POINTS[:medium])
end

get '/medium/triangulate/ffi' do
  content_type :json
  triangulate_ffi(POINTS[:small])
end

get '/large/points' do
  content_type :json
  POINTS[:large].map { |p| vector3_to_hash(p) }.to_json
end

post '/triangulate/:fast_or_slow' do
  content_type :json

  if params[:fast_or_slow] == 'slow'
    triangulate(json_to_vector3_list(params[:points]))
  else
    triangulate_ffi(json_to_vector3_list(params[:points]))
  end
end

get '/large/triangulate' do
  content_type :json
  triangulate(POINTS[:large])
end

get '/large/triangulate' do
  content_type :json
  triangulate_ffi(POINTS[:large])
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
