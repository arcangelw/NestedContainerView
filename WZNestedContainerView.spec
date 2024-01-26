Pod::Spec.new do |spec|
  spec.name = "WZNestedContainerView"
  spec.version = "0.0.1"
  spec.license = ""
  spec.summary = "WZNestedContainerView"

  spec.description = <<-DESC
`WZNestedContainerView`
                   DESC
  spec.source = { :git => "https://github.com/arcangelw/NestedContainerView.git", :tag => "v#{spec.version}" }
  spec.homepage = "https://github.com/arcangelw/NestedContainerView"
  spec.authors = { "WU ZHE" => "wuzhezmc@gmail.com" }
  spec.social_media_url = "https://github.com/arcangelw"
  spec.swift_version = "5.8"
  spec.ios.deployment_target = '13.0'
  spec.frameworks = 'UIKit', 'Foundation'
  spec.source_files = "Sources/**/*.{swift,h,m}"
  spec.private_header_files = 'Sources/Proxy/include/*.h'
end

