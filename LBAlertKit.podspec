#
# Be sure to run `pod lib lint LBAlertKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name = 'LBAlertKit'
    s.version = '1.0.0'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.summary = 'a kit for kinds of alerts.'
    s.homepage = 'https://github.com/s2eker/LBAlertKit'
    s.author           = { 's2eker' => '294842586@qq.com' }
    s.source           = { :git => 'https://github.com/s2eker/LBAlertKit.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.source_files = 'Source/**/*'
    s.swift_version = '3.2'
end
