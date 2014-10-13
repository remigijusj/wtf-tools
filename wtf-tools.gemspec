Gem::Specification.new do |s|
  s.name            = "wtf-tools"
  s.version         = "1.0.0"
  s.platform        = Gem::Platform::RUBY
  s.summary         = "tools for debugging and profiling Ruby on Rails projects"
  s.license         = "MIT"

  s.description = <<-EOF
WTF-tools offers some flexible options for your puts-style Ruby debugging needs,
and profiling Ruby on Rails projects.
EOF

  s.files           = Dir['{example/*,lib/**/*,test/**/*}'] +
                        %w(LICENCE README.md wtf-tools.gemspec)
  s.require_path    = 'lib'
  s.test_files      = Dir['test/*.rb']

  s.author          = 'Remigijus Jodelis'
  s.email           = 'remigijus.jodelis@gmail.com'
  s.homepage        = 'http://github.com/remigijusj/wtf-tools'

  # s.add_development_dependency ''
end
