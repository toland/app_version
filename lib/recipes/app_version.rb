# this is a capistrano recipe that will use the templated version.yml.erb
# to produce the actual version.yml that the app_version plugin uses to 
# store version information.

namespace :app_version do

  desc "Generate version.yml from variables"
  task :generate_version_info, :roles => :app do
    result = render_erb_template(RAILS_ROOT + "/lib/templates/version.yml.erb")
    put result, "#{release_path}/config/version.yml"
  end
  after "deploy:update_code", "app_version:generate_version_info"

end
