# copy the version.yml.erb to some user editable location for example, in lib
RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../')

FileUtils.mkdir( File.join(RAILS_ROOT, 'lib/templates'))
FileUtils.cp( File.join(File.dirname(__FILE__), 'lib/templates/version.yml.erb'), File.join(RAILS_ROOT, 'lib/templates'),
  :verbose => true
)

# Show the README text file
# puts IO.read(File.join(File.dirname(__FILE__), 'README'))