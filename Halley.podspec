Pod::Spec.new do |s|
  s.name             = 'Halley'
  s.version          = '1.3.0'
  s.summary          = 'A short description of Halley.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Infinum/Halley'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.hr', 'Filip Gulan' => 'filip.gulan@infinum.com', 'Zoran Turk' => 'zoran.turk@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/Halley.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Halley/**/*'
  s.frameworks = 'Foundation', 'Combine'
end
