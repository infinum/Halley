Pod::Spec.new do |s|
  s.name             = 'HalleyMacro'
  s.version          = '1.8.0'
  s.summary          = 'Halley Macro Plugin'
  s.description      = 'Halley Macro Plugin'

  s.homepage         = 'https://github.com/Infinum/Halley'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.hr', 'Filip Gulan' => 'filip.gulan@infinum.com', 'Zoran Turk' => 'zoran.turk@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/Halley.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'

  s.dependency 'Halley'

  s.source_files = ['Macro/**/*']
  s.preserve_paths = ["macros/HalleyMacroPlugin"]

  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-load-plugin-executable ${PODS_ROOT}/HalleyMacro/macros/HalleyMacroPlugin#HalleyMacroPlugin'
  }
  s.user_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-load-plugin-executable ${PODS_ROOT}/HalleyMacro/macros/HalleyMacroPlugin#HalleyMacroPlugin'
  }

end
