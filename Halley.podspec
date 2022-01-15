Pod::Spec.new do |s|
  s.name             = 'Halley'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Halley.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Filip Gulan/Halley'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Filip Gulan' => 'gulan.filip@gmail.com' }
  s.source           = { :git => 'https://github.com/Filip Gulan/Halley.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Halley/Classes/**/*'

  s.frameworks = 'Foundation', 'Combine'
  s.dependency 'URITemplate'
  s.dependency 'CombineExt'
end
