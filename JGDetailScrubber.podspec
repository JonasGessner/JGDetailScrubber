Pod::Spec.new do |s|

  s.name         = "JGDetailScrubber"
  s.version      = "1.0"
  s.summary      = "UISlider subclass with variable scrubbing speeds."
  s.description  = <<-DESC
UISlider subclass with variable scrubbing speeds. Inspired by iOS Music app.
DESC
  s.homepage     = "https://github.com/JonasGessner/JGDetailScrubber"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = "Jonas Gessner"
  s.social_media_url   = "http://twitter.com/JonasGessner"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/JonasGessner/JGDetailScrubber.git", :tag => "v1.0" }
  s.source_files  = "JGDetailScrubber/*.{h,m}"
  s.frameworks = "Foundation", "UIKit", "CoreGraphics"
  s.requires_arc = true

end
