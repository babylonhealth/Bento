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

# Switch back to use the version tag when we release 0.4.
s.source        = { :git => "https://github.com/Babylonpartners/Bento.git", :branch => "develop" } #, :tag => "#{s.version}" }
s.swift_version = "4.2"
s.source_files  = 'StyleSheets/StyleSheets/*.swift'
end

