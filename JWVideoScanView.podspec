
Pod::Spec.new do |s|
  s.name     = 'JWVideoScanView'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'the animation for angle'
  s.homepage = 'https://github.com/upworldcjw'
  s.author   = { 'upowrld' => '1042294579@qq.com' }
  s.source   = { :git => 'https://github.com/upworldcjw/JWVideoScanView.git', :tag => '0.0.1' }
  s.source_files = 'JWVideoScanView/*.{h,m,mm}'
  s.resource      = 'JWVideoScanView/JWVideoScanView.bundle'
  s.ios.frameworks = 'Foundation', 'UIKit','AVFoundation'
  s.ios.deployment_target = '6.0' 
  s.requires_arc = true
end
