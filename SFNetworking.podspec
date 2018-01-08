Pod::Spec.new do |s|
    s.name         = 'SFNetworking'
    s.version      = '0.0.1'
    s.summary      = '简易的请求库'
    s.homepage     = 'https://github.com/lvsf/SFNetworking'
    s.license      = 'MIT'
    s.authors      = {'lvsf' => 'lvsf1992@163.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/lvsf/SFNetworking.git', :tag => s.version}
    s.source_files = 'SFNetworking/Class/**/*'
    s.requires_arc = true
    s.dependency 'AFNetworking'
    s.dependency 'YYCache'
end