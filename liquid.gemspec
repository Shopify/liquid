Gem::Specification.new do |s|
  s.name = %q{liquid}
  s.version = "1.9.0"
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Luetke"]
  s.date = %q{2008-06-23}
  s.description = %q{A secure non evaling end user template engine with aesthetic markup.}
  s.email = %q{tobi@leetsoft.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["CHANGELOG", "History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "lib/extras/liquid_view.rb", "lib/liquid.rb", "lib/liquid/block.rb", "lib/liquid/condition.rb", "lib/liquid/context.rb", "lib/liquid/document.rb", "lib/liquid/drop.rb", "lib/liquid/errors.rb", "lib/liquid/extensions.rb", "lib/liquid/file_system.rb", "lib/liquid/htmltags.rb", "lib/liquid/module_ex.rb", "lib/liquid/standardfilters.rb", "lib/liquid/strainer.rb", "lib/liquid/tag.rb", "lib/liquid/tags/assign.rb", "lib/liquid/tags/capture.rb", "lib/liquid/tags/case.rb", "lib/liquid/tags/comment.rb", "lib/liquid/tags/cycle.rb", "lib/liquid/tags/for.rb", "lib/liquid/tags/if.rb", "lib/liquid/tags/ifchanged.rb", "lib/liquid/tags/include.rb", "lib/liquid/tags/unless.rb", "lib/liquid/template.rb", "lib/liquid/variable.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.liquidmarkup.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{liquid}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A secure non evaling end user template engine with aesthetic markup.}
end
