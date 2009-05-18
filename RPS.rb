# Delete unnecessary files
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"
  run "rm -f public/javascripts/*"
  
# Set up git repository
  git :init

# Set up .gitignore files
  run %{find . -type d -empty | xargs -I xxx touch xxx/.gitignore}
    file '.gitignore', <<-END
    .DS_Store
    coverage/*
    log/*.log
    db/*.db
    db/*.sqlite3
    db/schema.rb
    tmp/**/*
    doc/api
    doc/app
    config/database.yml
    coverage/*
    END

# Install the basic plugins  
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true
plugin 'textile-editor-helper', :git => 'git://github.com/felttippin/textile-editor-helper.git', :submodule => true
plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git'

# Clone the Authlogic-starter pack
 git :clone => "git://github.com/LuNiPriSe/auth_logic-starter.git", :submodule => true

# Install RSpec
if yes?("Do you want to use RSpec for testing? (yes/no)")
  gem "rspec", :lib => false, :version => ">= 1.2.0"
  gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
  generate :rspec
end

# Install gems  
  gem 'ruby-openid', :lib => 'openid'
  gem 'hpricot', :lib => false
  gem 'RedCloth', :lib => 'redcloth'
  
  
# Initialize submodules
  # git :submodule => "init"
  
    
    # rake('db:sessions:create')
    # generate("authlogic", "user session")
  
# Install the gems
  rake("gems:install", :sudo => true)
  
# Install textile-editor helper methods  
  rake("textile_editor_helper:install")
  
# Commit all work so far to the repository
#  git :add => '.'
#  git :commit => "-a -m 'Initial commit'"

# Success!
  puts "SUCCESS!"