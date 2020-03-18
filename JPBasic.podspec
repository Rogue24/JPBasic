#
# Be sure to run `pod lib lint JPBasic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JPBasic'
  s.version          = '0.1.0'
  s.summary          = 'Develop commonly used category, tool, macros, constants.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    开发常用的分类、工具类、加载图片类、宏、常量。
                       DESC

  s.homepage         = 'https://github.com/Rogue24/JPBasic'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhoujianping24@hotmail.com' => 'zhoujianping24@hotmail.com' }
  s.source           = { :git => 'https://github.com/Rogue24/JPBasic.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.subspec 'JPConst' do |a|
      a.source_files = 'JPBasic/Classes/JPConst/**/*'
  end

  s.subspec 'JPCategory' do |b|
      b.source_files = 'JPBasic/Classes/JPCategory/**/*'
      b.dependency 'pop'
      b.dependency 'Masonry'
      b.dependency 'JPBasic/JPConst'
  end

  s.subspec 'JPTool' do |c|
      c.source_files = 'JPBasic/Classes/JPTool/**/*'
      c.dependency 'YYText'
      c.dependency 'JPBasic/JPConst'
      c.dependency 'JPBasic/JPCategory'
  end

  s.subspec 'JPProgressHUD' do |d|
      d.source_files = 'JPBasic/Classes/JPProgressHUD/**/*'
      d.dependency 'SVProgressHUD'
  end
  
  s.subspec 'JPCustomUnit' do |e|
      e.source_files = 'JPBasic/Classes/JPCustomUnit/**/*'
      e.dependency 'JPBasic/JPConst'
      e.dependency 'JPBasic/JPCategory'
      e.dependency 'JPBasic/JPTool'
  end
  
  # s.resource_bundles = {
  #   'JPBasic' => ['JPBasic/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
