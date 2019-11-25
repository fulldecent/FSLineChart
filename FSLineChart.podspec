Pod::Spec.new do |s|
	s.name = "FSLineChart"
	s.version = "0.1.8"
	s.summary = "FSLineChart is a simple chart library for iOS."
	s.description = <<-DESC
	FSLineChart is a simple chart library for iOS. You can change whatever you want: size, color, units,...
	DESC
	s.homepage = "https://github.com/fulldecent/FSLineChart"
	s.screenshots = "https://github.com/fulldecent/FSLineChart/raw/master/Screenshots/fslinechart.png"
	s.author = { "William Entriken" => "github.com@phor.net" }
	s.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
	s.platform = :ios, '8.0'
	s.source = { :git => "https://github.com/ArthurGuibert/FSLineChart.git",:tag => "#{s.version}" }
	s.source_files = 'Sources/FSLineChart/**/*.swift'
	s.requires_arc = true
	s.swift_version = '5.0'
end
