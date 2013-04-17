task :bootstrap do
  if !File.exist?('deps/libtriangle.so') && !File.exist?('deps/libtriangle.dylib')
    puts "Downloading and compiling dependencies..."
    system 'script/bootstrap'
  end
end

task run: [:bootstrap] do
  ENV['LD_LIBRARY_PATH'] = 'deps'
  ruby 'mesherator.rb'
end
