Pod::Spec.new do |s|
  s.name          = "SWRevealViewController"
  s.version       = "1.1.1"
  s.summary       = "A UIViewController subclass for presenting two view controllers inspired in the Facebook app, done right."
  s.homepage      = "https://github.com/antoinerabanes/SWRevealViewController"
  s.license       = "MIT"
  s.author        = { "John Lluch Zorrilla" => "joan.lluch@sweetwilliamsl.com" }
  s.source        = { :git => "https://github.com/antoinerabanes/SWRevealViewController.git", :tag =>  "v#{s.version}" }
  s.platform      = :ios, "5.1"
  s.source_files  = "SWRevealViewController/*.{h,m}"
  s.framework     = "CoreGraphics"
  s.requires_arc  = true
end
