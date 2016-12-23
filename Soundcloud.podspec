Pod::Spec.new do |s|
  s.name         = 'Soundcloud'
  s.version      = '1.1.0'
  s.license      =  { :type => 'MIT' }
  s.homepage     = 'https://github.com/delannoyk/SoundcloudSDK'
  s.authors      = {
    'Kevin Delannoy' => 'delannoyk@gmail.com',
    'Benjamin Chrobot' => 'benjamin.blair.chrobot@gmail.com'
  }
  s.summary      = 'SoundcloudSDK is a framework written in Swift over Soundcloud API.'

# Source Info
  s.source       =  {
    :git => 'https://github.com/delannoyk/SoundcloudSDK.git',
    :tag => s.version.to_s
  }
  s.source_files = 'sources/SoundcloudSDK/**/*.swift'

  s.ios.deployment_target = '8.0'
  s.ios.dependency 'KeychainAccess', '~> 3.0'
  s.ios.dependency '1PasswordExtension', '~> 1.8.3'

  s.osx.deployment_target = '10.10'
  s.osx.dependency 'KeychainAccess', '~> 3.0'

  s.tvos.deployment_target = '9.0'
  s.tvos.exclude_files = 'sources/SoundcloudSDK/views/SoundcloudWebViewController.swift'

  s.requires_arc = true
end
