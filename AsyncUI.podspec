
Pod::Spec.new do |spec|
  spec.name         = 'AsyncUI'
  spec.version      = '1.0.2'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/gwh111/AsyncUI'
  spec.authors      = { 'apple' => '173695508@qq.com' }
  spec.summary      = 'IOS bench tool for developer'
  spec.source       = { :git  => 'https://github.com/gwh111/AsyncUI.git' }
  spec.frameworks   = 'UIKit'

  spec.ios.deployment_target  = '10.0'

  spec.source_files       = 'AsyncUI/Core/**/*'
  # spec.resources          = 'bench_ios/bench/bench_ios.bundle'
  # spec.source_files     = 'bench_ios/bench/**/*'
  # spec.resources    = 'bench_ios/bench/debugPluginList/debug_function.plist'

end
