# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Unit
  watch(%r|^test/(.*)\/?test_(.*)\.rb|)
  watch(%r|^lib/triangulation/([^/]+)\.rb|)  { |m| "test/unit/test_#{m[1]}.rb" }
  watch(%r|^test/test_helper\.rb|) { "test" }
end
