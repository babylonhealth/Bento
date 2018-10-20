Pod::Spec.new do |s|

s.name          = "StyleSheets"
s.version       = "0.3"
s.summary       = "StyleSheets for your UIViews 💅"

s.description   = <<-DESC
Provides a declarative way to define styles for your UIViews
DESC

s.homepage      = "https://github.com/Babylonpartners/Bento"
s.license       = { :type => "MIT", :file => "LICENSE" }
s.author        = { "Babylon iOS" => "ios.development@babylonhealth.com" }
s.ios.deployment_target = '10.0'
s.source        = { :git => "https://github.com/Babylonpartners/Bento.git", :tag => "#{s.version}" }
s.source_files  = 'StyleSheets/StyleSheets/*.swift'
end

