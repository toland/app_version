# copy the version.yml.erb to some user editable location for example, in lib

targetDir = File.join(RAILS_ROOT, 'lib/templates')
sourceFile = File.join(File.dirname(__FILE__), 'lib/templates/version.yml.erb')

FileUtils.mkdir( targetDir, :verbose => true)
FileUtils.cp( sourceFile, targetDir,:verbose => true)

# Show the README text file
# puts IO.read(File.join(File.dirname(__FILE__), 'README'))