namespace :app do
  desc 'Report the application version.'
  task :version do
    require File.join(File.dirname(__FILE__), "../lib/app_version.rb")
    puts "Application version: " << Version.load("#{RAILS_ROOT}/config/version.yml").to_s
  end

  desc 'Configure for initial install.'
  task :install do
    require File.join(File.dirname(__FILE__), "../install.rb")
  end

  desc 'Clean up prior to removal.'
  task :uninstall do
    require File.join(File.dirname(__FILE__), "../uninstall.rb")
  end
end
