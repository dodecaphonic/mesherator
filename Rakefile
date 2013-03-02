task :bootstrap do
  if !File.exist?('deps/libtriangle.so') && !File.exist?('deps/libtriangle.dylib')
    puts "Downloading and compiling dependencies..."
    system 'script/bootstrap'
  end
end

task benchmark: [:bootstrap] do
  ENV['LD_LIBRARY_PATH'] = 'deps'
  ruby 'script/benchmark'
end

task run: [:bootstrap] do
  system 'LD_LIBRARY_PATH=deps bundle exec foreman start'
end
