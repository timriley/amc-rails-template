app_name = ask('Application name (eg. <name>.amc.org.au):')

plugin 'exception_notifier',  :git => 'git://github.com/rails/exception_notification.git'
plugin 'thinking-sphinx',     :git => 'git://github.com/freelancing-god/thinking-sphinx' if yes?('Thinking Sphinx plugin?')
plugin 'proxy_ping',          :git => 'git://github.com/artpop/proxy_ping'

# For proxy_ping
route "map.route '/proxy_ping', :controller => 'proxy_ping', :action => 'ping'"

gem 'haml'
gem 'mislav-will_paginate',   :lib => 'will_paginate',  :source => 'http://gems.github.com'
gem 'chriseppstein-compass',  :lib => 'compass',        :source => 'http://gems.github.com'
gem 'fiveruns_manage',                                  :source => 'http://gems.fiveruns.com', :version => '>= 1.1.1' if yes?('Fiveruns gem?')
gem 'thoughtbot-paperclip',   :lib => 'paperclip',      :source => 'http://gems.github.com'   if yes?('Paperclip gem?')
gem 'authlogic'                                                                               if yes?('Authlogic gem?')

file '.testgems',
%q{config.gem 'rspec'
config.gem 'rspec-rails'
config.gem 'notahat-machinist', :lib => 'machinist',  :source => 'http://gems.github.com'
config.gem 'ianwhite-pickle',   :lib => 'pickle',     :source => 'http://gems.github.com'
config.gem 'webrat'
config.gem 'cucumber'
}
run 'cat .testgems >> config/environments/test.rb && rm .testgems'
 
rake 'gems:install', :sudo => true
rake 'gems:install', :sudo => true, :env => 'test'

generate 'rspec'
generate 'cucumber'
run "haml --rails #{run "pwd"}"

run 'mkdir -p public/javascripts/vendor'
inside('public/javascripts/vendor') do
  run 'wget http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js'
end

run 'cp config/database.yml config/database.example.yml'
 
%w{index.html favicon.ico robots.txt}.each do |f|
  run "rm public/#{f}"
end

%w{dragdrop controls effects prototype}.each do |f|
  run "rm public/javascripts/#{f}.js"
end

run 'echo TODO > README'
run 'touch tmp/.gitignore log/.gitignore vendor/.gitignore'
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore]}

file '.gitignore',
%q{.DS_Store
log/*.log
log/fiveruns
log/searchd.*
tmp/**/*
config/config.yml
config/database.yml
config/thin.yml
config/*.sphinx.conf
doc/api
doc/app
db/*.sqlite3
db/sphinx
coverage
lib/tasks/rspec.rake
lib/tasks/cucumber.rake
}

initializer 'requires.rb', 
%q{Dir[File.join(Rails.root, 'lib', '*.rb')].each do |f|
  require f
end
}

initializer 'time_formats.rb', 
%q{# Example time formats
{ :short_date => "%x", :long_date => "%a, %b %d, %Y" }.each do |k, v|
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(k => v)
end
}

file 'app/controllers/application_controller.rb', 
%q{class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  
  helper :all
 
  protect_from_forgery
 
  filter_parameter_logging :password
end
}

file 'app/views/layouts/application.html.haml', <<END
!!! Strict
%html{ :xmlns =>'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', :lang => 'en' }

  %head
    %meta{ 'http-equiv' => 'Content-Type', :content => 'text/html; charset=utf-8' }
    %title #{app_name.capitalize}
    %link{ :href => '/stylesheets/screen.css', :media => 'screen', :rel => 'stylesheet', :type => 'text/css' }
    %link{ :href => '/stylesheets/print.css',  :media => 'print',  :rel => 'stylesheet', :type => 'text/css' }
    /[if IE]
      %link{ :href => '/stylesheets/ie.css',   :media => 'screen', :rel => 'stylesheet', :type => 'text/css' }
    = yield :stylesheet_includes

    %script{ :src => '/javascripts/vendor/jquery-1.3.2.min.js', :type => 'text/javascript' }
    %script{ :src => '/javascripts/application.js',             :type => 'text/javascript' }
    = yield :javascript_includes

  %body{:class => @body_class}
    = yield :content
END

file 'app/views/layouts/main.html.haml', <<END
- content_for :content do
  #menubar
    .container
      #app-suite-links
        %ul
          %li.first
            %a{:href => 'http://www.amc.org.au/'} AMC
          %li
            %a{:href => '#'} App 1
          %li
            %a{:href => '#'} App 2
          %li
            %a{:href => '#'} App 3
      #site-actions
        %ul
          %li
            %a{:href => '#'} Login
           
  #titlebar
    .container
      #header
        %h1
          %a{:href => '/'} #{app_name.capitalize}
        
  #main.container
    #messages
      - display_flash(:notice, :error, :warning)
    = yield
    
    #footer
      = \"&copy; #{Time.now.year} Australian Medical Council\"

= render :file => 'layouts/application'
END

file 'app/stylesheets/_base.sass',
%q{@import compass/reset.sass
@import compass/utilities.sass

// All the blueprint stuff, MINUS typography, which we handle manually.
// These are all taken from the top of blueprint/screen.sass
@import blueprint/modules/colors.sass
@import blueprint/modules/grid.sass
@import blueprint/modules/utilities.sass
@import blueprint/modules/form.sass
@import blueprint/modules/interaction.sass
@import blueprint/modules/debug.sass

@import blueprint/print.sass
@import blueprint/ie.sass

// Our stuff
@import typography.sass

+blueprint-typography

body
  :font-size 85%

=has-menubar
  #menubar
    :width 100%
    :background-color #2b2b2b
    :border-bottom 1px solid #eee
    :color #fff
    a
      :color #fff
      :text-decoration none
    #app-suite-links
      :float left
      ul
        +horizontal-list
    #site-actions
      :float right
      ul
        +horizontal-list
      
=has-titlebar
  #titlebar
    :width 100%
    :min-height 3em
    :margin-bottom 1.5em
    :background #279914 url(/images/body-bg.png) repeat-x
    #header
      +column(24)
      :padding-top 1em
      h1
        :font-size 2em
        :font-weight bold
        :margin-bottom 0.75em
        :color #fff
        a
          :text-decoration none
          :color #fff

=has-footer
  #footer
    +column(24, true)
    :text-align center
    :color #999
    
=no-horizontal-table-padding
  :margin-left 0
  :margin-right 0
  :padding-left 0
  :padding-right 0
  th,td
    :margin-left 0
    :margin-right 0
    :padding-left 0
    :padding-right 0
}

file 'app/stylesheets/_typography.sass',
%q{// COPIED DIRECTLY FROM THE BLUEPRINT FRAMEWORK DIR IN THE COMPASS GEM

@import blueprint/modules/colors.sass
@import compass/utilities/links/link_colors.sass

!blueprint_font_family       ||= "Helvetica Neue, Helvetica, Arial, sans-serif"
!blueprint_fixed_font_family ||= "'andale mono', 'lucida console', monospace"

// The +blueprint-typography mixin must be mixed into the top level of your stylesheet.
// However, you can customize the body selector if you wish to control the scope
// of this mixin. Examples:
// Apply to any page including the stylesheet:
//   +blueprint-typography
// Scoped by a single presentational body class:
//   +blueprint-typography("body.blueprint")
// Semantically:
//   +blueprint-typography("body#page-1, body#page-2, body.a-special-page-type")
//   Alternatively, you can use the +blueprint-typography-body and +blueprint-typography-defaults
//   mixins to construct your own semantic style rules.

=blueprint-typography(!body_selector = "body")
  #{!body_selector}
    +blueprint-typography-body
    @if !body_selector != "body"
      +blueprint-typography-defaults
  @if !body_selector == "body"
    +blueprint-typography-defaults

=normal-text
  :font-family= !blueprint_font_family
  :color= !font_color

=fixed-width-text
  :font= 1em !blueprint_fixed_font_family
  :line-height 1.5

=header-text
  :font-weight normal
  :color= !header_color

=quiet
  :color= !quiet_color

=loud
  :color= !loud_color

=blueprint-typography-body
  +normal-text
  :font-size 75%

=blueprint-typography-defaults
  h1
    +header-text
    :font-size 3em
    :line-height 1
    :margin-bottom 0.5em
    img
      :margin 0
  h2
    +header-text
    :font-size 2em
    :margin-bottom 0.75em
  h3
    +header-text
    :font-size 1.5em
    :line-height 1
    :margin-bottom 1em
  h4
    +header-text
    :font-size 1.2em
    :line-height 1.25
    :margin-bottom 1.25em
    :height 1.25em
  h5
    +header-text
    :font-size 1em
    :font-weight bold
    :margin-bottom 1.5em
  h6
    +header-text
    :font-size 1em
    :font-weight bold
  h2 img,  h3 img,  h4 img,  h5 img,  h6 img
    :margin 0
  p
    :margin 0 0 1.5em
    /img
    /  :float left
    /  :margin 1.5em 1.5em 1.5em 0
    /  :padding 0
    /  &.right
    /    :float right
    /    :margin 1.5em 0 1.5em 1.5em
  a
    :text-decoration underline
    +link-colors(!link_color, !link_hover_color, !link_active_color, !link_visited_color, !link_focus_color)
  blockquote
    :margin 1.5em
    :color #666
    :font-style italic
  strong
    :font-weight bold
  em
    :font-style italic
  dfn
    :font-style italic
    :font-weight bold
  sup,  sub
    :line-height 0
  abbr,  acronym
    :border-bottom 1px dotted #666
  address
    :margin 0 0 1.5em
    :font-style italic
  del
    :color #666
  pre, code
    :margin 1.5em 0
    :white-space pre
    +fixed-width-text
  tt
    +fixed-width-text
  li ul,  li ol
    :margin 0 1.5em
  ul
    :margin 0 1.5em 1.5em 1.5em
    :list-style-type disc
  ol
    :margin 0 1.5em 1.5em 1.5em
    :list-style-type decimal
  dl
    :margin 0 0 1.5em 0
    dt
      :font-weight bold
  dd
    :margin-left 1.5em
  table
    :margin-bottom 1.4em
    :width 100%
  th
    :font-weight bold
    :padding 4px 10px 4px 5px
  td
    :padding 4px 10px 4px 5px
  tfoot
    :font-style italic
  caption
    :background #eee
  .quiet
    +quiet
  .loud
    +loud
}

file 'app/stylesheets/ie.sass',
%q{@import base.sass

+blueprint-ie
}

file 'app/stylesheets/print.sass',
%q{@import base.sass

+blueprint-print
}

file 'app/stylesheets/screen.sass',
%q{@import base.sass

body
  .container
    +container

h1
  +header-text
  :font-size 2em
  :margin-bottom 0.75em

body
  +has-menubar
  +has-titlebar
  +has-footer

  #sidebar
    +column(6, 'last')
    :text-align right
  #messages
    +column(18)
    .flash
      :font-weight bold
      :text-transform uppercase
      :padding 1em
      :margin-bottom 1em
    #error
      :color white
      :background-color #e35454
    #warning
      :color #e01414
      :background-color #ffd4d4
    #notice
      :color #444
      :background-color #ddffc8
}

capify!

banner = `figlet #{app_name} 2>/dev/null`.gsub(/^(.+)$/, '# \1')
banner = "# #{app_name}" if banner == ''

file 'config/deploy.rb', <<END
#{banner}

# Base Settings

set :app_name,                      '#{app_name}'
set :scm,                           'git'
set :branch,                        'master'

# Primary DB settings

set :primary_db_encoding,           'utf8'
set :primary_db_password,           Proc.new { Capistrano::CLI.password_prompt('DB Password: ') }

# App config

set :notification_recipients,       Proc.new { Capistrano::CLI.ui.ask('Notification recipients (comma-seperated): ') }
set :app_config_authsmtp_username,  Proc.new { Capistrano::CLI.ui.ask('AuthSMTP Username: ') }
set :app_config_authsmtp_password,  Proc.new { Capistrano::CLI.password_prompt('AuthSMTP Password: ') }

# Dependencies
require 'rubygems'
gem     'capistrano-amc', '>= 0.9.31
require 'capistrano/amc/base'
END

file 'config/deploy/dev.rb', <<END
set :app_hosts,   %w{dev-#{app_name}.amc.org.au}
# set :db_hosts,    %w{1.1.1.1}
set :branch,      'dev'
END

git :init
git :add => '.'
git :commit => '-a -m "Initial commit from AMC Rails template"'