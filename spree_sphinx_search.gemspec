# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_sphinx_search'
  s.version     = '2.2.0'
  s.summary     = 'Search for Spree via Sphinx.'
  s.description = 'Search for Spree via Sphinx.'
  s.required_ruby_version = '>= 2.1.6'

  s.author            = 'Roman Smirnov/Arkhitech'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '>= 2.3.3'
  s.add_dependency 'thinking-sphinx', '>= 3.4.0'
  s.add_dependency 'ts-sidekiq-delta', '>= 0.2.0'

  s.add_development_dependency 'capybara', '>= 1.0.1'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '>= 2.7'
  s.add_development_dependency 'sqlite3'
end
