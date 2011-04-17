# copy the version.yml.erb to some user editable location for example, in lib

targetTemplateDir = File.join(Rails.root.to_s, 'lib/templates')
sourceTemplateFile = File.join(File.dirname(__FILE__), 'lib/templates/version.yml.erb')

sourceSampleFile = File.join(File.dirname(__FILE__), 'lib/templates/version.yml')
targetSampleDir = File.join(Rails.root.to_s, '/config')

FileUtils.mkdir( targetTemplateDir, :verbose => true) unless File.exists?(targetTemplateDir)
FileUtils.cp( sourceTemplateFile, targetTemplateDir,:verbose => true)
FileUtils.cp( sourceSampleFile, targetSampleDir, :verbose => true )

# Show the README text file
# puts IO.read(File.join(File.dirname(__FILE__), 'README'))
