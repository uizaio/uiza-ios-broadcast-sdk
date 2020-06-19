
Pod::Spec.new do |s|

  s.name         = "UZBroadcast"
  s.version      = "1.2.2"
  s.summary      = "Uiza ios Live. UZBroadcast"
  s.summary = 'UZBroadcast'
  s.homepage = 'https://uiza.io/'
  s.documentation_url = 'https://uizaio.github.io/uiza-ios-broadcast-sdk/'
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author       = { "developer" => "developer@uiza.io" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source = { :git => "https://github.com/uizaio/uiza-ios-broadcast-sdk.git", :tag => "v" + s.version.to_s }	
  s.source_files  = "UZBroadcast/**/*.{h,m,mm,cpp,c}"
  s.public_header_files = ['UZBroadcast/*.h', 'UZBroadcast/objects/*.h', 'UZBroadcast/configuration/*.h']

  s.frameworks = "VideoToolbox", "AudioToolbox","AVFoundation","Foundation","UIKit"
  s.libraries = "c++", "z"

  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/Headers/Private/OpenSSL_Universal/** ${PODS_ROOT}/Headers/Public/OpenSSL_Universal/**' }

  s.dependency 'OpenSSL-Universal', '1.0.2.20'
  s.static_framework = true
  s.requires_arc = true
end
