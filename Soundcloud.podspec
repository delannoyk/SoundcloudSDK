Pod::Spec.new do |s|
  s.name         = 'Soundcloud'
  s.version      = '0.0.2'
  s.license      =  { :type => 'MIT' }
  s.homepage     = 'https://github.com/delannoyk/Soundcloud'
  s.authors      = {
    'Kevin Delannoy' => 'delannoyk@gmail.com'
  }
  s.summary      = ''

# Source Info
  s.platform     =  :ios, '8.0'
  s.source       =  {
    :git => 'https://github.com/delannoyk/Soundcloud.git',
    :tag => s.version.to_s
  }
  s.source_files = 'sources/SoundcloudSDK/**/*.swift'
  s.framework    =  'UIKit'
  s.dependency 'UICKeyChainStore', '~> 2.0.6'
  s.dependency '1PasswordExtension', '~> 1.2'
  s.requires_arc = true
end
