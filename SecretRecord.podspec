

Pod::Spec.new do |s|
  s.name             = 'SecretRecord'
  s.version          = '0.1.0'
  s.summary          = 'audio record tool'


  s.description      = <<-DESC
this is a great audio record tool
                       DESC

  s.homepage         = 'https://github.com/liucheng520/SecretRecord'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liucheng2011@yeah.net' => 'liucheng2016@chaoxing.com' }
  s.source           = { :git => 'https://github.com/liucheng520/SecretRecord.git', :tag => s.version.to_s }


  s.ios.deployment_target = '9.0'

  s.source_files = 'SecretRecord/Classes/*.{h,m,c,a}'
  s.vendored_libraries  = 'SecretRecord/Classes/*.{a}'
  s.resource_bundles = {
    'SecretRecord' => ['SecretRecord/Assets/*.png']
  }
end
