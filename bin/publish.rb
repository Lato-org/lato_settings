output = system("gem build lato_settings.gemspec")
raise "Impossible to build gem" unless output

files = Dir.glob("*.gem")
raise "Impossible to find gem" unless files.first

output = system("gem push #{files.first}")
raise "Impossible to push gem" unless output

output = system("rm -rf #{files.first}")
raise "Impossible to delete gem" unless output

version = files.first.gsub('lato_settings-', '').gsub('.gem', '')
system("git tag #{version}")
system("git add -A")
system("git commit -m \"Publish version #{version}\"")
system("git push origin #{version}")
system("git push origin main")
