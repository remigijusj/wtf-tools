Gem::Specification.new do |s|
  s.name            = 'wtf-tools'
  s.version         = '1.0.3'
  s.date            = '2016-07-01'
  s.platform        = Gem::Platform::RUBY
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.summary         = 'tools for debugging and profiling Ruby on Rails projects'
  s.license         = 'MIT'

  s.description = <<-EOF
WTF-tools offers some flexible options for your puts-style Ruby debugging needs,
and method-level profiling for Ruby on Rails projects.
EOF

  s.files           = Dir['{lib/**/*,example/*,test/*}'] + %w(LICENSE Rakefile README.md wtf-tools.gemspec)
  s.require_path    = 'lib'
  s.test_files      = Dir['test/*.rb']

  s.author          = 'Remigijus Jodelis'
  s.email           = 'remigijus.jodelis@gmail.com'
  s.homepage        = 'http://github.com/remigijusj/wtf-tools'

  s.add_runtime_dependency 'absolute_time', '~> 1.0'
end
