Pod::Spec.new do |s|
    s.name = 'UZBroadcast'
    s.version = '1.1.0'
    s.summary = 'UZBroadcast'
    s.homepage = 'https://uiza.io/'
    s.documentation_url = 'https://uizaio.github.io/uiza-ios-broadcast-sdk/'
    s.author = { 'Uiza' => 'namnh@uiza.io' }
    s.license = { :type => "BSD", :file => "LICENSE" }
    s.source = { :git => "https://github.com/uizaio/uiza-ios-broadcast-sdk.git", :tag => "v" + s.version.to_s }
    s.source_files = 'UZBroadcast/*.*'
    s.ios.deployment_target = '10.0'
    s.requires_arc  = true
    s.swift_version = '4.2'
    
    s.ios.dependency "LFLiveKit_", '2.8'
    
end
