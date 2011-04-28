namespace :app do
  require 'erb'

  desc 'Report the application version.'
  task :version do
    require File.join(File.dirname(__FILE__), "../app_version.rb")
    puts "Application version: " << AppVersion.load("#{Rails.root.to_s}/config/version.yml").to_s
  end

  desc 'Configure for initial install.'
  task :install do
    require File.join(File.dirname(__FILE__), "../../install.rb")
  end

  desc 'Clean up prior to removal.'
  task :uninstall do
    require File.join(File.dirname(__FILE__), "../../uninstall.rb")
  end

  desc 'Render the version.yml from its template.'
  task :render do
    template = File.read(Rails.root.to_s+ "/lib/templates/version.yml.erb")
    result   = ERB.new(template).result(binding)
    File.open(Rails.root.to_s+ "/config/version.yml", 'w') { |f| f.write(result)}
  end
end
