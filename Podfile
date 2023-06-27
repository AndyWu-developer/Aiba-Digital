# Uncomment the next line to define a global platform for your project
 platform :ios, '14.6'

target 'Aiba Digital' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Aiba Digital
    pod 'FirebaseAuth'
    pod 'FirebaseFirestore'
    pod 'FirebaseStorage'
    pod 'FirebaseDatabase'
    pod 'GoogleSignIn'
    pod 'FirebaseFirestoreSwift'
    pod "Mobile-Buy-SDK"

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
  end
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
    end
  end
end