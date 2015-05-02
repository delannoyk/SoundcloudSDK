Pod::Spec.new do |s|
  s.name         = 'Soundcloud'
  s.version      = '0.0.1'
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

  s.requires_arc = true
end
