Gem::Specification.new do |s|
  s.name = "liquid"
  s.version = "1.9.0"
  s.date = "2008-06-23"
  s.description = s.summary = "A secure non evaling end user template engine with aesthetic markup."
  s.email = "tobi@leetsoft.com"
  s.homepage = "http://www.liquidmarkup.org"
  s.has_rdoc = true
  s.authors = ["Tobias Lütke"]
  p s.files  = File.read('Manifest.txt').to_a.collect { |f| f.strip }
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
end