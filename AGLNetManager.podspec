#
#  Be sure to run `pod spec lint AGLNetManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "AGLNetManager"
  s.version      = "0.0.5"
  s.summary      = "Net work"
  s.description  = <<-DESC
一个自己在项目中用到的二次网络封装。
                   DESC

  s.homepage     = "https://github.com/AngryLi/NetManager"

  s.license      = "MIT"

  s.author             = { "李亚洲" => "liyazhou0301@gmail.com" }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/AngryLi/NetManager.git", :tag => "#{s.version}" }

  s.source_files  = "NetManager"

  s.public_header_files = "NetManager/{*.h}"

  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.1.0"

end
