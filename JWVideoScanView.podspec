
Pod::Spec.new do |s|
  s.name     = 'JWVideoScanView'
  s.version  = '0.0.2'
  s.license  = 'MIT'
  s.summary  = 'selcte image frame from video'
  s.homepage = 'https://github.com/upworldcjw'
  s.author   = { 'upowrld' => '1042294579@qq.com' }
  s.source   = { :git => 'https://github.com/upworldcjw/JWVideoScanView.git', :tag => '0.0.2' }
  s.source_files = 'JWVideoScanView/*.{h,m,mm}'
  s.resource      = 'JWVideoScanView/JWVideoScanView.bundle'
  s.ios.frameworks = 'Foundation', 'UIKit','AVFoundation'
  s.ios.deployment_target = '6.0' 
  s.requires_arc = true
end
