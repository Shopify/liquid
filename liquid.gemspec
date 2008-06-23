(in /Users/tobi/Code/Ruby/liquid-markup)
Gem::Specification.new do |s|
  s.name = %q{liquid}
  s.version = "1.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Luetke"]
  s.date = %q{2008-06-23}
  s.description = %q{A secure non evaling end user template engine with aesthetic markup.}
  s.email = %q{tobi@leetsoft.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["CHANGELOG", "History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "example/server/example_servlet.rb", "example/server/liquid_servlet.rb", "example/server/server.rb", "example/server/templates/index.liquid", "example/server/templates/products.liquid", "init.rb", "lib/extras/liquid_view.rb", "lib/liquid.rb", "lib/liquid/block.rb", "lib/liquid/condition.rb", "lib/liquid/context.rb", "lib/liquid/document.rb", "lib/liquid/drop.rb", "lib/liquid/errors.rb", "lib/liquid/extensions.rb", "lib/liquid/file_system.rb", "lib/liquid/htmltags.rb", "lib/liquid/module_ex.rb", "lib/liquid/standardfilters.rb", "lib/liquid/strainer.rb", "lib/liquid/tag.rb", "lib/liquid/tags/assign.rb", "lib/liquid/tags/capture.rb", "lib/liquid/tags/case.rb", "lib/liquid/tags/comment.rb", "lib/liquid/tags/cycle.rb", "lib/liquid/tags/for.rb", "lib/liquid/tags/if.rb", "lib/liquid/tags/ifchanged.rb", "lib/liquid/tags/include.rb", "lib/liquid/tags/unless.rb", "lib/liquid/template.rb", "lib/liquid/variable.rb", "test/block_test.rb", "test/condition_test.rb", "test/context_test.rb", "test/drop_test.rb", "test/error_handling_test.rb", "test/extra/breakpoint.rb", "test/extra/caller.rb", "test/file_system_test.rb", "test/filter_test.rb", "test/helper.rb", "test/html_tag_test.rb", "test/if_else_test.rb", "test/include_tag_test.rb", "test/module_ex_test.rb", "test/output_test.rb", "test/parsing_quirks_test.rb", "test/regexp_test.rb", "test/security_test.rb", "test/standard_filter_test.rb", "test/standard_tag_test.rb", "test/statements_test.rb", "test/strainer_test.rb", "test/template_test.rb", "test/test_helper.rb", "test/unless_else_test.rb", "test/variable_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.liquidmarkup.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{liquid}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A secure non evaling end user template engine with aesthetic markup.}
  s.test_files = ["test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<hoe>, [">= 1.6.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.6.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.6.0"])
  end
end
