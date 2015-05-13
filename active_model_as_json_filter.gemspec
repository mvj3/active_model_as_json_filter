Gem::Specification.new do |s|
  s.name        = 'active_model_as_json_filter'
  s.version     = '0.0.1'
  s.date        = '2013-12-05'
  s.summary     = File.read("README.markdown").split(/===+/)[1].strip.split("\n")[0]
  s.description = s.summary
  s.authors     = ["David Chen"]
  s.email       = 'mvjome@gmail.com'
  s.homepage    = 'https://github.com/SunshineLibrary/active_model_as_json_filter/'
  s.license     = 'MIT'

  s.add_dependency "mongoid"
  s.add_dependency "activesupport", "> 3.2"

  s.files = `git ls-files`.split("\n")
end
