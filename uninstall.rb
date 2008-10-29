targetDir = File.join(RAILS_ROOT, 'lib/templates')
targetFile = File.join(RAILS_ROOT, 'lib/templates/version.yml.erb')

FileUtils.rm( targetFile, :verbose => true)
if Dir.entries( targetDir ).empty? then FileUtils.rmdir( targetDir, :verbose => true ) end
