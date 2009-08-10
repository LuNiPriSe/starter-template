# Delete unnecessary files
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"
  run 'rm public/images/rails.png'
  # run "rm -f public/javascripts/*"
  run 'cp config/database.yml config/database.yml.example'
  
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
# changed to gem
#plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true
plugin 'textile-editor-helper', :git => 'git://github.com/felttippin/textile-editor-helper.git', :submodule => true
plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git'
plugin 'http_accept_language', :git => '	git://github.com/iain/http_accept_language.git'
plugin 'pretty_flash', :git => '	git://github.com/rpheath/pretty_flash.git'



# Clone the Authlogic-starter pack (makes a fodler with all the logic)
# git :clone => "git://github.com/LuNiPriSe/auth_logic-starter.git", :submodule => true

# Install RSpec
if yes?("Do you want to use RSpec for testing? (yes/no)")
  gem "rspec", :lib => false, :version => ">= 1.2.0"
  gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
  generate :rspec
end

# Install gems  
  mysql_path = '/usr/local/mysql/bin/mysql_config'
  if no?("Do you want to use the default mysql config path? (default= /usr/local/mysql/bin/mysql_config) (yes/no)")
    mysql_path = ask("What is your mysql config path? (default= /usr/local/mysql/bin/mysql_config)")
  end
  gem 'mysql', :install_options => '--with-mysql-config=#{mysql_path}', :lib => 'mysql'
  gem 'authlogic', :lib => false
 # gem 'ruby-openid', :lib => 'openid'
  gem 'json', :lib => false
  gem 'hpricot', :lib => false
  gem 'RedCloth', :lib => 'redcloth'
  
# Install the gems
  rake("gems:install", :sudo => true)
  
# Initialize submodules
   git :submodule => "init"
  
   db_name = ask("What do you want to call the databse? (e.g. 'test' leads to 'test_development' etx.) Make sure you have the MYSQL database already set up!!")
   file 'config/database.yml', 
   %Q{

   development:
     adapter: mysql
     database: #{db_name}_development
     username: root
     password: 
     host: localhost
     encoding: utf8

   test:
     adapter: mysql
     database: #{db_name}_test
     username: root
     password: 
     host: localhost
     encoding: utf8

   production:
     adapter: mysql
     database: #{db_name}_production
     username: root
     password: 
     host: localhost
     encoding: utf8
   }
  
  file 'app/controllers/application_controller.rb',
  %q{# Filters added to this controller apply to all controllers in the application.
      # Likewise, all the methods added will be available for all controllers.

      class ApplicationController < ActionController::Base
        before_filter :set_locale
        helper :all
        protect_from_forgery # See ActionController::RequestForgeryProtection for details
        helper_method :current_user_session, :current_user
        filter_parameter_logging :password, :password_confirmation

         def set_locale
           # sets locale to de, also possible to change in config environment the default language
           I18n.locale = :de
           # Sets locale via params
           # I18n.locale = params[:locale]
           # Sets the language by HTTP request
           # I18n.locale = request.preferred_language_from(I18n.available_locales)
            # Sets the language by subdomain
           # I18n.locale = extract_locale_from_subdomain
         end

         private
         def extract_locale_from_subdomain
           parsed_locale = request.subdomains.first
           (I18n.available_locales.include? parsed_locale) ? parsed_locale  : nil
         end

          def current_user_session
            return @current_user_session if defined?(@current_user_session)
            @current_user_session = UserSession.find
          end

          def current_user
            return @current_user if defined?(@current_user)
            @current_user = current_user_session && current_user_session.record
          end

          def require_user
            unless current_user
              store_location
              flash[:notice] = t("require login")
              redirect_to new_user_session_url
              return false
            end
          end

          def require_no_user
            if current_user
              store_location
              flash[:notice] = t(" require loggout")
              redirect_to account_url
              return false
            end
          end

          def store_location
            session[:return_to] = request.request_uri
          end

          def redirect_back_or_default(default)
            redirect_to(session[:return_to] || default)
            session[:return_to] = nil
          end
      end    
  }
  
  file 'app/controllers/user_sessions_controller.rb',
  %q{class UserSessionsController < ApplicationController
      before_filter :require_no_user, :only => [:new, :create]
      before_filter :require_user, :only => :destroy

      def new
        @user_session = UserSession.new
      end

      def create
        @user_session = UserSession.new(params[:user_session])
        if @user_session.save
          flash[:notice] = t("login suc")
          redirect_back_or_default account_url
        else
          render :action => :new
        end
      end

      def destroy
        current_user_session.destroy
        flash[:notice] = t("logout suc")
        redirect_back_or_default new_user_session_url
      end
    end
  }
  
  file 'app/controllers/users_controller.rb',
  %q{class UsersController < ApplicationController
      before_filter :require_no_user, :only => [:new, :create]
      before_filter :require_user, :only => [:show, :edit, :update]

      def new
        @user = User.new
      end

      def create
        @user = User.new(params[:user])
        if @user.save
          flash[:notice] = t("account registered")
          redirect_back_or_default account_url
        else
          render :action => :new
        end
      end

      def show
        @user = @current_user
      end

      def edit
        @user = @current_user
      end

      def update
        @user = @current_user # makes our views "cleaner" and more consistent
        if @user.update_attributes(params[:user])
          flash[:notice] = t("account updated")
          redirect_to account_url
        else
          render :action => :edit
        end
      end
    end
  }

  file 'app/models/user.rb',  
  %q{class User < ActiveRecord::Base
    acts_as_authentic
  end
  }
  
  file 'app/views/password_resets/edit.html.erb',
  %q{<h1><%= t(change password) %></h1>

  <% form_for @user, :url => password_reset_path, :method => :put do |f| %>
    <%= f.error_messages %>
    <%= f.label t(:password) %><br />
    <%= f.password_field :password %><br />
    <br />
    <%= f.label t(:password_confirmation) %><br />
    <%= f.password_field :password_confirmation %><br />
    <br />
    <%= f.submit t("update and login") %>
  <% end %>
  }
  
  file 'app/views/password_resets/new.html.erb',
  %q{<h1><%= t("forgot password") %></h1>

    <%= t("new password instructions") %><br />
    <br />

    <% form_tag password_resets_path do %>
      <label><%= t("email") %>:</label><br />
      <%= text_field_tag "email" %><br />
      <br />
      <%= submit_tag t("reset my password") %>
    <% end %>
  }
  
  file 'app/views/user_sessions/new.html.erb',
  %q{<h1><%= t("log in") %></h1>

    <% form_for @user_session, :url => user_session_path do |f| %>
      <%= f.error_messages %>
      <%= f.label t(:login) %><br />
      <%= f.text_field :login %><br />
      <br />
      <%= f.label t(:password) %><br />
      <%= f.password_field :password %><br />
      <br />
      <%= f.check_box :remember_me %><%= f.label t(:remember_me) %><br />
      <br />
      <%= f.submit t("log in") %>
    <% end %>
  }

  file 'app/views/users/show.html.erb',
  %q{<p>
      <b><%= t("login") %>:</b>
      <%=h @user.login %>
    </p>

    <p>
      <b><%= t("login count") %>:</b>
      <%=h @user.login_count %>
    </p>

    <p>
      <b><%= t("last request at") %>:</b>
      <%=h @user.last_request_at %>
    </p>

    <p>
      <b><%= t("last login at") %>:</b>
      <%=h @user.last_login_at %>
    </p>

    <p>
      <b><%= t("current login at") %>:</b>
      <%=h @user.current_login_at %>
    </p>

    <p>
      <b><%= t("last login ip") %>:</b>
      <%=h @user.last_login_ip %>
    </p>

    <p>
      <b><%= t("current login ip") %>:</b>
      <%=h @user.current_login_ip %>
    </p>


    <%= link_to t('edit'), edit_account_path %>
  }

  file 'app/views/users/new.html.erb',
  %q{<h1><%= t("register") %></h1>

    <% form_for @user, :url => account_path do |f| %>
      <%= f.error_messages %>
      <%= render :partial => "form", :object => f %>
      <%= f.submit t("register") %>
      <% end %>
  }

  file 'app/views/users/edit.html.erb',
  %q{<h1><%= t("edit my account") %></h1>

    <% form_for @user, :url => account_path do |f| %>
      <%= f.error_messages %>
      <%= render :partial => "form", :object => f %>
      <%= f.submit t("update") %>
    <% end %>

    <br /><%= link_to t("my profile"), account_path %>
  }

  file 'app/views/users/_form.html.erb',
  %q{<%= form.label t(:login) %><br />
    <%= form.text_field :login %><br />
    <br />
    <%= form.label t(:password), form.object.new_record? ? nil : t("change password") %><br />
    <%= form.password_field :password %><br />
    <br />
    <%= form.label t(:password_confirmation) %><br />
    <%= form.password_field :password_confirmation %><br />
    <br />
  }
  
  file 'app/views/layouts/application.html.erb',
  %q{<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
           "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
      <title><%= controller.controller_name %>: <%= controller.action_name %></title>
      <%= stylesheet_link_tag 'scaffold' %>
      <%= stylesheet_link_tag('flash') %>
      <%= javascript_include_tag :defaults %>
    </head>
    <body>

    <span style="float: right; text-align: right;"><%= link_to "Source code", "http://github.com/binarylogic/authlogic_example" %> | <%= link_to "Setup tutorial", "http://www.binarylogic.com/2008/11/3/tutorial-authlogic-basic-setup" %> | <%= link_to "Password reset tutorial", "http://www.binarylogic.com/2008/11/16/tutorial-reset-passwords-with-authlogic" %><br />
    <%= link_to "OpenID tutorial", "http://www.binarylogic.com/2008/11/21/tutorial-using-openid-with-authlogic" %> | <%= link_to "Authlogic Repo", "http://github.com/binarylogic/authlogic" %> | <%= link_to "Authlogic Doc", "http://authlogic.rubyforge.org/" %></span>
    <h1>Authlogic Example App</h1>
    <%= pluralize User.logged_in.count, "user" %> currently logged in<br /> <!-- This based on last_request_at, if they were active < 10 minutes they are logged in -->
    <br />
    <br />


    <% if !current_user %>
      <%= link_to t("register"), new_account_path %> |
      <%= link_to t("log in"), new_user_session_path %> 
    <% else %>
      <%= link_to t("my account"), account_path %> |
      <%= link_to t("logout"), user_session_path, :method => :delete, :confirm => t("logout sure") %>
    <% end %>

    <p><%= display_flash_messages %></p>

    <%= yield  %>

    </body>
    </html>
  }
  
  file 'db/migrate/20081103171327_create_users.rb',
  %q{class CreateUsers < ActiveRecord::Migration
    def self.up
      create_table :users do |t|
        t.timestamps
        t.string :login, :null => false
        t.string :crypted_password, :null => false
        t.string :password_salt, :null => false
        t.string :persistence_token, :null => false
        t.integer :login_count, :default => 0, :null => false
        t.datetime :last_request_at
        t.datetime :last_login_at
        t.datetime :current_login_at
        t.string :last_login_ip
        t.string :current_login_ip
      end

      add_index :users, :login
      add_index :users, :persistence_token
      add_index :users, :last_request_at
    end

    def self.down
      drop_table :users
    end
  end
  }
  
  file 'config/routes.rb',
  %q{ActionController::Routing::Routes.draw do |map|
    map.resource :account, :controller => "users"
    map.resources :users
    map.resource :user_session
    map.root :controller => "user_sessions", :action => "new"
  end
  }
  
  file 'config/locales/en.yml',
  %q{en:
      login: "Login"
      email: "Email"
      edit: "Edit"
      update: "Update"
      update and login: "Update my password and log me in"
      password: "Passwors"
      change password: "Change password"
      password_confirmation: "Confirm password"
      log in: "Log In"
      register: "Register"
      remember_me: "Remember me"
      forgot password: "Forgot password"
      new password instructions: "Fill out the form below and instructions to reset your password will be emailed to you"
      reset my password: "Reset my password"
      login count: "Login count"
      last request at: "Last request at"
      last login at: "Last login at"
      current login at: "Current login at"
      last login ip: "Last login IP"
      current login ip: "Current login IP"
      edit my account: "Edit my account"
      my profile: "My profile"
      Logout: "Logout"
      logout sure: "Are you sure you want to logout?"
      account registered: "Account registered!"
      account updated: "Account updated!"
      require login: "You must be logged in to access this page"
      require loggout: "You must be logged out to access this page"
      login suc: "Login successful!"
      logout suc: "Logout successful!"
  }
  
  file 'config/locales/de.yml',
  %q{de: 
        login: "Benutzername"
        email: "Email"
        edit: "Ändern"
        update: "aktualisieren"
        update and login: "Passwort ändern und mich einloggen"
        password: "Passwort"
        change password: "Passwort ändern"
        password_confirmation: "Passwort wiederholen"
        log in: "Einloggen"
        register: "Registrieren"
        remember_me: "Eingeloggt bleiben"
        forgot password: "Passwort vergessen"
        new password instructions: "Bitte folgen Sie den unten stehenden Anweisungen und füllen Sie das Formular aus und Ihnen wird Ihr Passwort zugeschickt."
        reset my password: "Passwort zuschicken"
        login count: "Anzahl der Einwahlen"
        last request at: "Letzte Anfrage"
        last login at: "Letzte Einwahl"
        current login at: "Eingewählt um"
        last login ip: "IP bei der letzten Einwahl"
        current login ip: "IP bei der aktuellen Einwahl"
        edit my account: "Profil ändern"
        my profile: "Mein Profil"
        my account: "Mein Profil"
        logout: "Ausloggen"
        logout sure: "Sind Sie sicher, dass Sie Sich ausloggen wollen?"
        account registered: "Benutzer angelegt"
        account updated: "Benutzer aktualisiert"
        require login: "Sie müssen eingeloggt sein, um diese Seite nutzen zu können"
        require loggout: "Sie müssen ausgeloggt sein, um diese Seite nutzen zu können"
        login suc: "Erfolgreich eingeloggt!"
        logout suc: "Erfolgreich ausgeloggt!"

        activerecord: 
          attributes:
            user:
              login: "Benutzername"
              password: "Passwort"
              password_confirmation: "Passwortwiederholung"
          errors:
              template:
                header:
                  one: "1 Fehler hat verhindert, dass {{model}} gespeichert werden konnte."
                  other: "{{count}} Fehler haben verhindert, dass {{model}} gespeichert werden konnte"
                body: "Bitte überprüfen Sie die folgenden Felder:"
              models:
                user: 
                  attributes:
                    login: 
                      to_short: "ist zu kurz (minimum 3 Zeichen)"
                    password: 
                      too_short: "ist zu kurz (minimum 4 Zeichen)"
                      confirmation: "stimmt nicht mit der Passwortwiederholung überein"
                    password_confirmation:
                      too_short: "ist zu kurz (minimum 4 Zeichen)"
          error_messages: 
            accepted: "muss akzeptiert werden"
            blank: "muss ausgefüllt werden"
            confirmation: "stimmt nicht mit der Bestätigung überein"
            empty: "muss ausgefüllt werden"
            equal_to: "muss genau {{count}} sein"
            even: "muss gerade sein"
            exclusion: "ist nicht verfügbar"
            greater_than: "muss größer als {{count}} sein"
            greater_than_or_equal_to: "muss größer oder gleich {{count}} sein"
            inclusion: "ist kein gültiger Wert"
            invalid: "ist nicht gültig"
            less_than: "muss kleiner als {{count}} sein"
            less_than_or_equal_to: "muss kleiner oder gleich {{count}} sein"
            not_a_number: "ist keine Zahl"
            odd: "muss ungerade sein"
            taken: "ist bereits vergeben"
            too_long: "ist zu lang (nicht mehr als {{count}} Zeichen)"
            too_short: "ist zu kurz (nicht weniger als {{count}} Zeichen)"
            wrong_length: "hat die falsche Länge (muss genau {{count}} Zeichen haben)"
        date: 
          formats: 
            default: "%d.%m.%Y"
            long: "%e. %B %Y"
            only_day: "%e"
            short: "%e. %b"
          day_names: [Sonntag, Monatg, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag]
          abbr_day_names: [So, Mo, Di, Mi, Dp, Fr, Sa]

          # Don't forget the nil at the beginning; there's no such thing as a 0th month
          month_names: [~, Januar, Februar, März, April, Mai, Juni, Juli, August, September, Oktober, November, Dezember]
          abbr_month_names: [~, Jan, Feb, Mrz, Apr, Mai, Jun, Jul, Aug, Sep, Okt, Nov, Dez]
          order: [ :day, :month, :year ]
        datetime: 
          distance_in_words: 
            about_x_hours: 
              one: "etwa 1 Stunde"
              other: "{{count}} Stunden"
            about_x_months: 
              one: "etwa 1 Monat"
              other: "{{count}} Monate"
            about_x_years: 
              one: "etwa 1 Jahr"
              other: "{{count}} Jahre"
            half_a_minute: "eine halbe Minute"
            less_than_x_minutes: 
              one: "eine Minute"
              other: "{{count}} Minuten"
              zero: "weniger als 1 Minute"
            less_than_x_seconds: 
              one: "1 Sekunde"
              other: "{{count}} Sekunden"
              zero: "weniger als 1 Sekunde"
            over_x_years: 
              one: "mehr als 1 Jahr"
              other: "{{count}} Jahre"
            x_days: 
              one: "1 Tag"
              other: "{{count}} Tage"
            x_minutes: 
              one: "1 Minute"
              other: "{{count}} Minuten"
            x_months: 
              one: "1 Monat"
              other: "{{count}} Monate"
            x_seconds: 
              one: "1 Sekunde"
              other: "{{count}} Sekunden"
        number: 
          currency: 
            format: 
              format: "%n%u"
              precision: 2
              unit: €
          format: 
            delimiter: "."
            precision: 2
            separator: ","
        time: 
          formats: 
            am: am
            datetime: 
              formats: 
                default: "%Y-%m-%dT%H:%M:%S%Z"
            default: "%A, %e. %B %Y, %H:%M Uhr"
            long: "%A, %e. %B %Y, %H:%M Uhr"
            only_second: "%S"
            pm: pm
            short: "%e. %B, %H:%M Uhr"
            time: "%H:%M"
        authlogic:
            error_messages:
                login_blank: "darf nicht leer sein"
                login_not_found: "ist ungültig"
                login_invalid: darf nur aus Buchstaben, Zahlen, Leerzeichen undd .-_@ bestehen.
                consecutive_failed_logins_limit_exceeded: wurde sicherheitshalber deaktiviert.
                email_invalid: sollte die Form einer Email-Adresse haben.
                password_blank: darf nicht leer sein
                password_invalid: ist ungültig
                not_active: Ihr Account ist noch nicht aktiviert worden.
                not_confirmed: Ihr Account ist bisher noch nicht bestätigt worden.
                not_approved: Ihr Account wurde noch nicht anerkannt.
                no_authentication_details: Sie müssen einen Benutzernamen und ein Passwort eingeben!
            models:
                user_session: "UserSession" 
            attributes:
                user_session: 
                   login: "Login"
                   email: "Email"
                   password: "Passwort"
                   remember_me: "Eingeloggt bleiben"
  }
  
   generate("helper", "password_resets")
   generate("helper", "user_session")
   generate("helper", "user_sessions")
   generate("helper", "users")

   if yes?("Do you want to store the session data in the database? (yes/no)")
     rake('db:sessions:create')
     initializer 'session_store.rb', <<-FILE
       ActionController::Base.session = { :session_key => '_#{(1..6).map { |x| (65 + rand(26)).chr }.join}_session', :secret => '#{(1..40).map { |x| (65 + rand(26)).chr }.join}' }
       ActionController::Base.session_store = :active_record_store
     FILE
   end
   
    rake('db:migrate')
    
    # for the Authlogic Session Model
   generate("session", "user_session")
  
  
# Install textile-editor helper methods  
  rake("textile_editor_helper:install")
  
# The config YAML file for the asset packager
  rake("asset:packager:create_yml")  
  
# copies the pretty flash CSS files  
  rake pretty_flash:install
  
# Commit all work so far to the repository
  git :add => '.'
  git :commit => "-a -m 'Initial commit'"

# Success!
  puts "SUCCESS!"