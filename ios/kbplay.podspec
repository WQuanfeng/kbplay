#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint kbplay.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kbplay'
  s.version          = '0.0.1'
  s.summary          = '科百监控视频专用播放器（萤石、大华、乐橙等）'
  s.description      = <<-DESC
科百监控视频专用播放器（萤石、大华、乐橙等）
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'EZOpenSDK', '5.13.4'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
