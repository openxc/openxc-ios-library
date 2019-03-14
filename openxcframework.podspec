#
# Be sure to run `pod lib lint openxcframework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'openxcframework'
  s.version          = '1.1.3'
  s.summary          = 'A short description of openxcframework.'
  s.swift_version    = '3.2'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#s.description      = ''

  s.homepage         = 'https://github.com/openxc/openxc-ios-library'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kranjanford' => 'kranjan@ford.com' }
  s.source           = { :git => 'https://github.com/openxc/openxc-ios-library.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.exclude_files = 'openxcframework/*.plist'
  s.source_files = 'openxcframework/*.{swift}'
  s.dependency 'protobufSwift', '~> 1.3.3'
  s.module_name = 'openXCiOSFramework'
  s.frameworks = 'ExternalAccessory', 'CoreBluetooth', 'Foundation'

  # s.resource_bundles = {
  #   'openxcframework' => ['openxcframework/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'

  # s.dependency 'AFNetworking', '~> 2.3'
end
