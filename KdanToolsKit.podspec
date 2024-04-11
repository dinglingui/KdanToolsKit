#
# Be sure to run `pod lib lint KdanToolsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KdanToolsKit'
  s.version          = '0.1.5'
  s.summary          = 'A short description of toolsUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/dinglingui/KdanToolsKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'git' => 'dinglingui@kdanmobile.com' }
  s.source           = { :git => 'https://github.com/dinglingui/KdanToolsKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = '5.0'

  s.subspec 'Secure' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Secure/**/*.swift'
  end

  s.subspec 'Annotations' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Annotations/**/*.swift'
  end

s.subspec 'Common' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Common/**/*.swift'
  end

s.subspec 'ContentEditor' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/ContentEditor/**/*.swift'
  end

s.subspec 'DigitalSignature' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/DigitalSignature/**/*.swift'
  end

s.subspec 'DocsEditor' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/DocsEditor/**/*.swift'
  end

s.subspec 'Forms' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Forms/**/*.swift'
  end

s.subspec 'Viewer' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Viewer/**/*.swift'
  end

s.subspec 'Watermark' do |ss|
    ss.source_files = 'KdanToolsKit/Classes/Watermark/**/*.swift'
  end

  s.source_files = 'KdanToolsKit/Classes/*'


  s.resource_bundles = {
  'KdanToolsKit' => ['KdanToolsKit/Assets/**/*.xcassets','KdanToolsKit/Assets/**/*.plist','KdanToolsKit/Assets/**/*.png']
    }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'ComPDFKit'

end
