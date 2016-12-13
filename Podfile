#
#  Podfile
#
#  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
#

# Pod sources
require './scripts/inbbbox_keys.rb'
require './scripts/acknowledgements.rb'
source 'https://github.com/CocoaPods/Specs.git'

# Initial configuration
platform :ios, '8.2'
swift_version = '3.0'
inhibit_all_warnings!
use_frameworks!

project 'Inbbbox', 'Development' => :debug, 'Production' => :release, 'Staging' => :release, 'Test' => :debug, 'Release' => :release

plugin 'cocoapods-keys', {
  :project => 'Inbbbox',
  :keys => InbbboxKeys.new.all_keys
}

target 'Inbbbox' do

  pod 'AsyncSwift', '~> 2.0'
  pod 'KeychainAccess', '~> 3.0'
  pod 'PromiseKit', '~> 4.0'
  pod 'SwiftyJSON', '~> 3.1'
  pod 'HockeySDK', '~> 4.1'
  pod 'PureLayout', '~> 3.0'
  pod 'SwiftyUserDefaults', '~> 3.0'
  #for older swift version 
  pod 'DeviceKit', '~> 1.0'
  pod 'GPUImage', '~> 0.1'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'ZFDragableModalTransition', '~> 0.6'
  pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-3'
  pod 'DZNEmptyDataSet', '~> 1.7'
  pod 'GoogleAnalytics', '~> 3.14'
  pod 'TTTAttributedLabel', '~> 2.0'
  #fork until this will be merged: https://github.com/MailOnline/ImageViewer/pull/91
  pod 'ImageViewer', :git => 'https://github.com/Siemian/ImageViewer'
  #fork because of styling private properties
  pod 'AOAlertController', :git => 'https://github.com/0legAdamov/AOAlertController', :tag => 'v1.2.1'
  pod 'Solar', '~> 1.0.0'
  #fork until this will be discussed and merged https://github.com/marmelroy/PeekPop/pull/32/
  pod 'PeekPop', :git => 'https://github.com/Myrenkar/PeekPop', :tag => '0.1.9'

  target 'Unit Tests' do
    inherit! :search_paths
    pod 'Quick', '~> 0.10', :configurations => ['Test']
    pod 'Nimble', '~> 5.0', :configurations => ['Test']
    pod 'Dobby', :git => 'https://github.com/trivago/Dobby.git', :tag => '0.7.0', :configurations => ['Test']
    pod 'Mockingjay', '~> 2.0', :configurations => ['Test']
  end

end

post_install do |installer|

  Acknowledgements.new.generate_html_acknowlegements('Inbbbox/Resources/Acknowledgements.html')

  puts 'Setting appropriate code signing identities'
  installer.pods_project.targets.each { |target|
    {
      'iPhone Developer' => ['Debug', 'Development', 'Test'],
      'iPhone Distribution' => ['Release', 'Staging', 'Production'],
      }.each { |value, configs|
        target.set_build_setting('CODE_SIGN_IDENTITY[sdk=iphoneos*]', value, configs)
      }
      target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    }

  end

  class Xcodeproj::Project::Object::PBXNativeTarget

    def set_build_setting setting, value, config = nil
      unless config.nil?
        if config.kind_of?(Xcodeproj::Project::Object::XCBuildConfiguration)
          config.build_settings[setting] = value
        elsif config.kind_of?(String)
          build_configurations
          .select { |config_obj| config_obj.name == config }
          .each { |config| set_build_setting(setting, value, config) }
        elsif config.kind_of?(Array)
          config.each { |config| set_build_setting(setting, value, config) }
        else
          raise 'Unsupported configuration type: ' + config.class.inspect
        end
      else
        set_build_setting(setting, value, build_configurations)
      end
    end
  end
