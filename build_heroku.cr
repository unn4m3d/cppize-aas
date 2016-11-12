require "option_parser"
require "colorize"
require "yaml"
require "yaml/**"

def failed(e)
  puts "failed".colorize.fore(:red)
  puts e.message.colorize.fore(:red)
  exit 1
end

directory = "../caas_heroku"
buildpack = "https://github.com/crystal-lang/heroku-buildpack-crystal.git"
create = ""

OptionParser.parse! do |o|
  o.banner = "CaaS build script for Heroku\n\nUsage : #{__FILE__} [--create NAME] [--buildpack BUILDPACK] [DIRECTORY]"
  o.on("-cNAME","--create NAME","Create app") do |name|
    create = name
  end

  o.on("-bBUILDPACK","--buildpack BUILDPACK", "Use another buildpack") do |b|
    buildpack = b
  end
end

directory = ARGV.shift unless ARGV.empty?

puts "CaaS for Heroku".colorize.fore(:blue).bold
puts

print "Checking for directory #{directory}... "

if File.exists?(directory)
  puts "exists".colorize.fore(:green)
else
  puts "doesn't exist".colorize.fore(:yellow)
  print "Making directory #{directory}... "
  begin
    Dir.mkdir directory
    puts "done".colorize.fore(:green)
  rescue ex
    failed ex
  end
end

print "Generating Procfile... "
begin
  File.open(File.join(directory,"Procfile"),"w") do |f|
    f.truncate
    f.puts("web: ./caas -p $PORT")
  end
  puts "done".colorize.fore(:green)
rescue ex
  failed ex
end

print "Generating shard.yml..."
begin
  File.open(File.join(directory,"shard.yml"),"w") do |f|
    f.truncate
    f.puts({"name" => "dummy","license" => "Beerware","version" => "0.1.0","authors" => ["unn4m3d"]}.to_yaml)
  end
  puts "done".colorize.fore(:green)
rescue ex
  failed ex
end

print "Checking for .git folder... "
if File.exists?(File.join(directory,".git"))
  puts "exists".colorize.fore(:green)
  unless create.empty?
    print "Creating app #{create}..."
    begin
      `cd #{directory} && heroku create "#{create}" --buildpack "#{buildpack}"; cd #{File.dirname __FILE__}`
      #puts "done"
    rescue ex
      failed ex
    end
  end
else
  puts "doesn't exist"
  if create.empty?
    puts "ERROR : No git repository and no --create option specified"
    exit 1
  else
    Dir.cd directory do
      print "Creating git repo... "
      begin
        `git init`
        puts "done".colorize.fore(:green)
      rescue e
        failed e
      end

      print "Creating app #{create}..."
      begin
        `cd #{directory} && heroku create "#{create}" --buildpack "#{buildpack}"; cd #{File.dirname __FILE__}`
        #puts "done"
      rescue ex
        failed ex
      end
    end


  end
end

print "Checking for directory #{directory}/src... "

if File.exists?(File.join(directory,"src"))
  puts "exists".colorize.fore(:green)
else
  puts "doesn't exist".colorize.fore(:yellow)
  print "Making directory #{directory}/src... "
  begin
    Dir.mkdir File.join(directory,"src")
    puts "done".colorize.fore(:green)
  rescue ex
    failed ex
  end
end

print "Generating src/dummy.cr..."
begin
  File.open(File.join(directory,"src","dummy.cr"),"w") do |f|
    f.truncate
    f.puts("exit 0")
  end
  puts "done".colorize.fore(:green)
rescue e
  failed e
end

puts "Updating deps..."
system("crystal deps")
puts "Building executable..."
system("crystal build -o #{directory}/caas -s src/cppize_aas.cr --release")
puts "Deploying"
system("cd #{directory} && git add . && git commit -am 'Auto-build' && git push heroku master; cd #{File.dirname __FILE__}")
