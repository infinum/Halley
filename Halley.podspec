Pod::Spec.new do |s|
  s.name             = 'Halley'
  s.version          = '2.0.0'
  s.summary          = 'Lightweight JSON HAL parser and traverser.'
  s.description      = <<-DESC
  Halley provides a simple way on iOS to parse and traverse models according to JSON Hypertext Application Language specification also known just as HAL.
                       DESC

  s.homepage         = 'https://github.com/Infinum/Halley'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Infinum' => 'ios@infinum.hr', 'Filip Gulan' => 'filip.gulan@infinum.com', 'Zoran Turk' => 'zoran.turk@infinum.com' }
  s.source           = { :git => 'https://github.com/infinum/Halley.git', :tag => s.version.to_s }

  s.platform = :ios
  s.ios.deployment_target = '15.0'
  s.swift_version = '6.0'
  s.source_files = 'Halley/**/*'
  s.frameworks = 'Foundation', 'Combine'
end
