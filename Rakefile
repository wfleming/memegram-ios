require 'fileutils'
# require 'net/http'
# require 'uri'
require 'rubygems'
require 'httpclient'

# utility functions
def set(key, value)
  ENV[key.to_s] = value
end

def fetch(key)
  ENV[key.to_s]
end

set(:app_name, 'Memegram')

# Tasks
desc "set the staging environment"
task :staging do
  puts "=== In environment 'staging'"
  set :environment, 'staging'
  set :xcode_configuration, 'Release'
  puts
end

task :require_environment do
  env = fetch(:environment)
  if env.nil? ||  0 == env.length
    raise Exception.new("No environment specified. You need to specify an environment")
  end
end

desc "bump the current release number"
task :bump_version do
  puts "=== Bumping the build number"
  puts `agvtool bump -all`
  build_number = `agvtool vers -terse`.chomp
  puts `git commit Memegram/Memegram-Info.plist aqualab-ios.xcodeproj/project.pbxproj -m "Bumping version number to #{build_number}"`
  puts
end

desc 'Tag and push tag for current release'
task :tag_release => [:require_environment] do
  if ENV['NO_TAG'].nil?
    puts "=== Tagging the current build"
    env = fetch(:environment)

    # tag a specific tag so we can refer to this version
    build_number = `agvtool vers -terse`.chomp
    date_str = Time.now.strftime('%Y-%m-%d')
    puts `git tag -fam '' #{env}-#{date_str}-build-#{build_number} HEAD`
    puts `git push -f origin #{env}-#{date_str}-build-#{build_number}`

    # move current -> previous
    current  = `git show-ref --tags --hash --abbrev #{env}-current`.chomp
    if current && current.length > 0
      puts `git tag -fam '' #{env}-previous #{env}-current`
      puts `git push -f origin refs/tags/#{env}-previous`
    end

    # re-tag current
    puts `git tag -fam '' #{env}-current HEAD`
    puts `git push -f origin refs/tags/#{env}-current`

    puts
  end
end

desc 'Make a best guess at what the release notes for a release should be.'
task :release_notes => [:require_environment] do
  env = fetch(:environment)
  previous_tag = "#{env}-previous"
  current_tag = "#{env}-current"
  log = `git log --pretty="* %s [%an, %h]" #{previous_tag}...#{current_tag}`
  file_name = "/tmp/aqualab-rake-release-notes-#{Time.now.to_i}.txt"
  File.rm_f(file_name) if File.exists?(file_name)
  File.open(file_name, 'w') { |f| f.write(log) }
  set(:release_notes_path, file_name)
  unless fetch(:skip_showing_release_notes)
    `$EDITOR #{file_name}`
  end
end

desc 'Compile the .app'
task :compile_app => [:require_environment] do
  conf = fetch(:xcode_configuration)
  app_name = fetch(:app_name)

  puts "=== Compiling the app"
  puts "* running xcodebuild..."
  xcode_out = `xcodebuild -sdk iphoneos -configuration #{conf}`
  if 0 != $?.exitstatus
    puts "* ERROR - xcodebuild failed"
    puts "* XCode Output:\n\n#{xcode_out}\n\nEND XCode Output\n\n"
    raise Exception.new("xcodebuild failed")
  else
    puts "* xcodebuild completed."
  end
end

desc 'Create a signed .ipa from the .app'
task :sign_ipa => [:require_environment] do
  conf = fetch(:xcode_configuration)
  app_name = fetch(:app_name)

  puts "=== Building the .ipa"
  app_path = "build/#{conf}-iphoneos/#{app_name}.app"
  ipa_path = "build/#{conf}-iphoneos/#{app_name}.ipa"

  if !File.exists?(app_path)
    raise Exception.new("#{app_path} not found. Did you forgot to run compile_app?")
  end

  set(:ipa_path, ipa_path)
  FileUtils.rm_f(ipa_path) if File.exists?(ipa_path)
  puts "* Going to run: `xcrun -sdk iphoneos PackageApplication -v \"#{app_path}\" -o \"#{ipa_path}\" --sign \"William Fleming\" --embed \"provision.mobileprovision\"`" #DEBUG
  xcrun_output = `xcrun -sdk iphoneos PackageApplication -v "#{app_path}" -o "#{ipa_path}" --sign "William Fleming" --embed "provision.mobileprovision"`
  # xcrun is expected to fail because it's dumb...but it mostly gets there.
  # it just fails on the zip step because it's looking in the wrong place.
  # so we figure out the right path from the output and go after it.
  pattern = /(\/var\/.*\/Payload\/#{app_name}\.app): explicit requirement satisfied/
  match = pattern.match(xcrun_output)
  app_bundle_path = match[1]

  if !File.exists?(app_bundle_path)
    puts "* ERROR: couldn't find the signed .app - thought it was #{app_bundle_path}"
    raise Exception.new("Couldn't sign app bundle")
  else
    cwd = FileUtils.pwd
    FileUtils.cd("#{app_bundle_path}/../..")
    `/usr/bin/zip --symlinks --verbose --recurse-paths "#{cwd}/#{ipa_path}" ./Payload`
    FileUtils.cd(cwd)
  end

  if !File.exists?(ipa_path)
    puts "* ERROR: the ipa doesn't exist where it should"
    raise Exception.new("Couldn't sign the app bundle")
  end
end

desc 'Build the project & sign the .ipa'
task :build_release => [:compile_app, :sign_ipa]

desc 'upload an already-built IPA path to testflight'
task :upload_to_testflight do
  set(:skip_showing_release_notes, 'true')
  Rake::Task["release_notes"].invoke

  puts "=== Posting ipa to testflight"

  testflight_api_token = '64f86839a999f7f2d2042a6c9284eb0c_MjIyOTg4MjAxMS0xMS0xOSAxODo1Nzo1Ny4xMzgxMjc'
  testflight_team_token = '4524dec9cbbdc5c5c7d39838884e01c4_NDIxOTIyMDExLTExLTIwIDA5OjU5OjMwLjE3MjU4MQ'
  ipa_path = fetch(:ipa_path)
  release_notes_path = fetch(:release_notes_path)
  
  # allow user to edit the release notes before upload
  `$EDITOR -w #{release_notes_path}`

  if ipa_path.nil? || !File.exists?(ipa_path)
    raise Exception.new("No .ipa was found! ipa_path is '#{ipa_path}'")
  end

  testflight_endpoint = 'http://testflightapp.com/api/builds.json'
  notify_teammates = true
  # distribution_lists = fetch('DISTRIBUTION_LISTS') || 'Mints,Syrup'

  # HTTPClient
  release_notes_string = File.open(release_notes_path, 'r').read
  response = HTTPClient.post(testflight_endpoint, {
    :file => File.new(ipa_path),
    :notes => release_notes_string,
    :api_token => testflight_api_token,
    :team_token => testflight_team_token,
    :notify => notify_teammates #,
    # :distribution_lists => distribution_lists
  })
#  puts "* our distribution lists are #{distribution_lists}" #DEBUG
  if (response.status != 200)
   puts "* ERROR posting file: got a #{response.status} response:"
  else
    puts "* SUCCESS:"
  end
  puts response.body.content
end

desc 'Upload a built release to TestFlight'
task :distribute_release => [:build_release, :upload_to_testflight]

desc 'Tag, build, & release.'
task :release => [:bump_version, :tag_release, :distribute_release]