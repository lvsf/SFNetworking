Pod::Spec.new do |s|
    s.name         = 'SFForm'
    s.version      = '0.0.2'
    s.summary      = '简易的表单界面构建'
    s.homepage     = 'https://github.com/lvsf/SFForm'
    s.license      = 'MIT'
    s.authors      = {'lvsf' => 'lvsf1992@163.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/lvsf/SFForm.git', :tag => s.version}
    s.source_files = 'SFForm/Class/**/*'
    s.requires_arc = true
    s.dependency 'SDWebImage'
    s.dependency 'Masonry'
    s.dependency 'YYCategories'
    s.dependency 'YYText'
end