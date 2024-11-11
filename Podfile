# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'
project 'Hearing Aid App.xcodeproj'

target 'Hearing Aid App' do
  use_frameworks!
  pod 'AAInfographics', '~> 9.0.0'
  pod 'GoogleMLKit/Translate', '~> 2.3.0'
  
  pod 'Firebase/Analytics', '~> 8.7.0'
  pod 'Firebase/Crashlytics', '~> 8.7.0'
  pod 'Amplitude', '~> 7.2.0'
  pod 'ApphudSDK', '2.8.5'
  pod 'lottie-ios', '3.2.3'
  pod 'ASATools', '~> 1.2.0'
  
  pod 'FBSDKCoreKit', '13.2.0'
  pod 'JXPageControl'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
