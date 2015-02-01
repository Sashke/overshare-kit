Pod::Spec.new do |s|
  s.name         = "OvershareKit"
  s.version      = "1.2.0"
  s.summary      = "A soup-to-nuts sharing library for iOS."
  s.homepage     = "https://github.com/overshare/overshare-kit"
  s.license      = { :type => 'MIT', :file => 'LICENSE'  }
  s.author       = { "Jared Sinclair" => "desk@jaredsinclair.com", "Justin Williams" => "justin@carpeaqua.com" }
  s.source       = { :git => "https://github.com/Sashke/overshare-kit.git"}
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.frameworks   = 'UIKit', 'AddressBook', 'CoreMotion', 'CoreLocation'
  
  s.compiler_flags = "-fmodules"
  
  s.ios.deployment_target = '7.0'
  
  s.source_files = ['Overshare Kit/*.{h,m}']
  s.resources    = ['Overshare Kit/Images/*', 'Overshare Kit/*.xib']

  s.dependency 'ADNLogin'
  s.dependency 'PocketAPI'
  s.dependency 'VK-ios-sdk'
  s.dependency 'google-plus-ios-sdk'
  s.dependency 'Evernote-SDK-iOS'
end
