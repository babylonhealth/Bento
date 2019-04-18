Pod::Spec.new do |s|

  s.name             = "Bento"
  s.version          = "0.3"
  s.summary          = "Component based abstraction on top of UITableView and UICollectionView"

  s.description      = <<-DESC
                       Component-based abstraction on top of UITableView and UICollectionView.
                       Provides a declarative way to render data in UITableView and UICollectionView
                       DESC

  s.homepage         = "https://github.com/Babylonpartners/Bento"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Babylon iOS" => "ios.development@babylonhealth.com" }
  s.ios.deployment_target = '10.0'
  s.source           = { :git => "https://github.com/Babylonpartners/Bento.git", :tag => "#{s.version}" }
  s.source_files     = 'Bento/*.swift', 'Bento/**/*.swift', 'Common/*.swift'
  s.resource_bundles =  { 'Bento' => 'Bento/Resources/Media.xcassets' }
  s.exclude_files    = 'Bento/Components.playground/**/*'
  s.swift_version    = "4.2"

  s.dependency "FlexibleDiff", "= 0.0.8"
end
