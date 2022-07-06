def proton_core_path
  'git@gitlab.protontech.ch:apple/shared/protoncore.git'
end

def proton_core_version
  "3.20.0"
end

def pmtest_path
  'git@gitlab.protontech.ch:apple/shared/pmtestautomation.git'
end

def pmtest_commit
  "2bc09250d65786c316aa8a2a203404ada745bea2"
end

def core_and_ios_pods
  pod 'ProtonCore-Log', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Utilities', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Doh', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-DataModel', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Crypto', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Keymaker/UsingCrypto', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Login/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version
end

target 'Client' do
  platform :ios, '14.0'
  use_frameworks!
  target 'ClientTests' do
  end

end

target 'Core' do
  platform :ios, '14.0'
  use_frameworks!

  core_and_ios_pods
  pod 'ProtonCore-KeyManager/UsingCrypto', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Settings-V5', :git => proton_core_path, :tag => proton_core_version

  target 'CoreTests' do
  end

end

target 'iOS' do
  platform :ios, '14.0'
  use_frameworks!

  core_and_ios_pods
  pod 'ProtonCore-OpenPGP', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Foundations', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-UIFoundations-V5', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-CoreTranslation', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-CoreTranslation-V5', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Challenge', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Authentication/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Authentication-KeyGeneration/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Payments/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-PaymentsUI-V5/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-HumanVerification-V5/Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-ForceUpgrade-V5/Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-APIClient/Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Services/Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Networking/Alamofire', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-Hash', :git => proton_core_path, :tag => proton_core_version
  pod 'ProtonCore-LoginUI-V5/UsingCrypto+Alamofire', :git => proton_core_path, :tag => proton_core_version

end

target 'macOS' do
  platform :macos, '11.0'
  use_frameworks!
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'No'
    end
  end
end
