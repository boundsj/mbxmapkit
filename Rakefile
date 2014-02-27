require 'pathname'
require 'tmpdir'

module Specs
  UI_SPECS_TARGET_NAME = "Specs"
  CONFIGURATION = "Release"

  ROOT = Pathname.new(File.dirname(__FILE__))
  PROJECT_ROOT = File.join(ROOT, "mbxmapkit")
  BUILD_DIR = File.join(PROJECT_ROOT, "build")

  class << self
    def in_project_dir
      original_dir = Dir.pwd
      Dir.chdir(PROJECT_ROOT)

      yield

      ensure
      Dir.chdir(original_dir)
    end

    def deployment_target_sdk_version
      in_project_dir do
        `xcodebuild -showBuildSettings -target #{UI_SPECS_TARGET_NAME} | grep IPHONEOS_DEPLOYMENT_TARGET | awk '{print $3 }'`.strip
      end
    end

    def deployment_target_sdk_dir
      @sdk_dir ||= "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{deployment_target_sdk_version}.sdk"
    end

    # Xcode 4.3 stores its /Developer inside /Applications/Xcode.app, Xcode 4.2 stored it in /Developer
    def xcode_developer_dir
      `xcode-select -print-path`.strip
    end

    def build_dir(effective_platform_name)
      File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
    end

    def system_or_exit(cmd, stdout = nil)
      puts "Executing #{cmd}"
      cmd += " >#{stdout}" if stdout
      system(cmd) or raise "******** Build failed ********"
    end

    def with_env_vars(env_vars)
      old_values = {}
      env_vars.each do |key,new_value|
        old_values[key] = ENV[key]
        ENV[key] = new_value
      end

      yield

      env_vars.each_key do |key|
        ENV[key] = old_values[key]
      end
    end

    def output_file(target)
      output_dir = if ENV['IS_CI_BOX']
        ENV['CC_BUILD_ARTIFACTS']
      else
        Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
        BUILD_DIR
      end

      output_file = File.join(output_dir, "#{target}.output")
      puts "Output: #{output_file}"
      output_file
    end

    def kill_simulator
      system %Q[killall -m -KILL "gdb"]
      system %Q[killall -m -KILL "otest"]
      system %Q[killall -m -KILL "iPhone Simulator"]
    end
  end
end

desc "Default task"
task :default => :Specs do
end

desc "Clean build directory"
task :clean_Specs do
  Specs.system_or_exit "rm -rf #{Specs::BUILD_DIR}/*", Specs.output_file("clean")
end

desc "Build Specs"
task :build_Specs => :clean_Specs do
  Specs.kill_simulator
  Specs.system_or_exit "pushd #{Specs::PROJECT_ROOT} && xcodebuild -target #{Specs::UI_SPECS_TARGET_NAME} -configuration #{Specs::CONFIGURATION} -sdk iphonesimulator build && popd", Specs.output_file("Specs")
end

desc "Run Specs"
task :Specs => :build_Specs do
  env_vars = {
    "DYLD_ROOT_PATH" => Specs.deployment_target_sdk_dir,
    "IPHONE_SIMULATOR_ROOT" => Specs.deployment_target_sdk_dir,
    "CFFIXED_USER_HOME" => Dir.tmpdir,
    "CEDAR_HEADLESS_SPECS" => "1",
    "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter"
  }

  app_path = File.join(Specs.build_dir("-iphonesimulator"), "#{Specs::UI_SPECS_TARGET_NAME}.app")

  Specs.with_env_vars(env_vars) do
    Specs.system_or_exit "#{File.join(Specs.build_dir("-iphonesimulator"), "#{Specs::UI_SPECS_TARGET_NAME}.app", Specs::UI_SPECS_TARGET_NAME)} -RegisterForSystemEvents";
  end
end

desc "Remove any focus from specs"
task :nof do
  Specs.system_or_exit %Q[ grep -l -r -e "\\(fit\\|fdescribe\\|fcontext\\)" Specs | grep -v 'Specs/Frameworks' | xargs -I{} sed -i '' -e 's/fit\(@/it\(@/g;' -e 's/fdescribe\(@/describe\(@/g;' -e 's/fcontext\(@/context\(@/g;' "{}" ]
end

