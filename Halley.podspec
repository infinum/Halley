Pod::Spec.new do |s|
  s.name             = 'Halley'
  s.version          = '1.2.0'
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
  s.default_subspec = 'Core'

    s.subspec 'Core' do |sp|
      sp.source_files = 'Halley/Classes/Core/**/*'
      sp.frameworks = 'Foundation', 'Combine'
      sp.dependency 'CombineExt'
    end

    s.subspec 'Codable' do |sp|
      sp.source_files = 'Halley/Classes/Codable/**/*'
      sp.dependency 'Halley/Core'
    end

    s.subspec 'URITemplate' do |sp|
      sp.source_files = 'Halley/Classes/URITemplate/**/*'
      sp.dependency 'Halley/Codable'
      sp.dependency 'URITemplate'
    end
end
