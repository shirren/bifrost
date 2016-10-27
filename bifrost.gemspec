$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'bifrost/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'bifrost'
  s.version     = Bifrost::VERSION
  s.authors     = ['Shirren Premaratne']
  s.email       = ['shirren@filmpond.com']
  s.homepage    = 'https://github.com/filmpond/bifrost'
  s.summary     = 'Bifrost is a simple pub/sub messaging wrapper component.'
  s.description = 'Topic definitions should occur via the Bifrost. Subscriptions should take place via the Bifrost. ' \
                  'Therefore all messages need to transit through the Bifrost'

  s.files      = Dir['{app,config,db,lib}/**/*', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_runtime_dependency 'azure', '~> 0.7.6'

  s.add_development_dependency 'rubocop'

  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'dotenv', '~> 2.1'
  s.add_development_dependency 'factory_girl_rails', '~> 4.2'
  s.add_development_dependency 'rspec-mocks', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.4'
  s.add_development_dependency 'simplecov', '~> 0.7'
end
