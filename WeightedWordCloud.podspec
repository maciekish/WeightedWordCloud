Pod::Spec.new do |s|
  s.name             = "WeightedWordCloud"
  s.version          = "0.1.0"
  s.summary          = "A simple word cloud renderer in Objective-C."
  s.description      = <<-DESC
                       Renders word/tag clouds. Supports weighted words.
                       No dependencies, works with app extensions and the Apple Watch (WatchKit).
                       DESC
  s.homepage         = "https://github.com/maciekish/WeightedWordCloud"
  s.screenshots      = "https://raw.githubusercontent.com/maciekish/WeightedWordCloud/master/Screenshot.png"
  s.license          = 'MIT'
  s.author           = { "Maciej Swic" => "maciej@swic.name" }
  s.source           = { :git => "https://github.com/maciekish/WeightedWordCloud.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/maciekish'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
end
