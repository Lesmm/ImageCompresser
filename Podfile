# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'ImageCompresser' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ImageCompresser

end

# for Xcode15
# https://github.com/pichillilorenzo/flutter_inappwebview/issues/1735
# https://github.com/pichillilorenzo/flutter_inappwebview/issues/1807
post_integrate do |installer|
  compiler_flags_key = 'COMPILER_FLAGS'
  project_path = 'Pods/Pods.xcodeproj'

  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    target.build_phases.each do |build_phase|
      if build_phase.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase)
        build_phase.files.each do |file|
          if !file.settings.nil? && file.settings.key?(compiler_flags_key)
            compiler_flags = file.settings[compiler_flags_key]
            file.settings[compiler_flags_key] = compiler_flags.gsub(/-DOS_OBJECT_USE_OBJC=0\s*/, '')
          end
        end
      end
    end
  end
  project.save()
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`
     end
  end
end
