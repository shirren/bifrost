$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'bifrost/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'bi-frost'
  s.version     = Bifrost::VERSION
  s.authors     = ['Shirren Premaratne']
  s.email       = ['shirren@filmpond.com']
  s.homepage    = 'https://github.com/shirren/bifrost'
  s.summary     = 'Bifrost is a pub/sub wrapper library which uses the Azure message bus and actors.'
  s.description = 'Bifrost is a pub/sub wrapper library which uses Azure message bus and actors.'
  s.files       = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']
  s.test_files  = Dir['spec/**/*']
  s.licenses    = ['MIT']

  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'azure', '~> 0.7.6'
  s.add_runtime_dependency 'celluloid', '~> 0.17.3'

  s.add_development_dependency 'rubocop', '~> 0'

  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'dotenv', '~> 2.1'
  s.add_development_dependency 'factory_girl_rails', '~> 4.2'
  s.add_development_dependency 'rspec-mocks', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.4'
  s.add_development_dependency 'simplecov', '~> 0.7'
end
