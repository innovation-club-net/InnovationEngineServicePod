#
# Be sure to run `pod lib lint InnovationEngineService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InnovationEngineService'
  s.version          = '1.2.1'
  s.summary          = 'The library to integrate experiments from the Innovation Engine into your app.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  Use this library to allow your app to load and run behavioral experiments designed in the Innovation Engine.
  https://fehradvice.com/
  DESC
  
  s.homepage         = 'https://github.com/innovation-club-net/InnovationEngineServicePod.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Commercial', :file => 'LICENSE' }
  s.author           = { 'Fred Klein' => 'support@innovation-club.net' }
  s.source           = { :git => 'https://github.com/innovation-club-net/InnovationEngineServicePod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '13.0'
  
  s.source_files = 'InnovationEngineService/Classes/**/*'
  
  # s.resource_bundles = {
  #   'InnovationEngineService' => ['InnovationEngineService/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.swift_versions = ['4.0', '4.1', '4.2', '5.0']

end
