Pod::Spec.new do |s|
  s.name             = 'Halley'
  s.version          = '1.8.0'
  s.summary          = 'Lightweight JSON HAL parser and traverser.'
  s.description      = <<-DESC
  Halley provides a simple way on iOS to parse and traverse models according to JSON Hypertext Application Language specification also known just as HAL.
                       DESC

  s.homepage         = 'https://github.com/Infinum/Halley'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.hr', 'Filip Gulan' => 'filip.gulan@infinum.com', 'Zoran Turk' => 'zoran.turk@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/Halley.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.9'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Halley/**/*'
    ss.frameworks = 'Foundation', 'Combine'
  end

  s.subspec 'Macro' do |ss|
    ss.dependency 'Halley/Core'

    ss.source_files = ['Macro/**/*']
    ss.preserve_paths = ["macros/HalleyMacroPlugin"]

    ss.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-load-plugin-executable ${PODS_ROOT}/Halley/macros/HalleyMacroPlugin#HalleyMacroPlugin'
    }
    ss.user_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '-load-plugin-executable ${PODS_ROOT}/Halley/macros/HalleyMacroPlugin#HalleyMacroPlugin'
    }
  end

end
