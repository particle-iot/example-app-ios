source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

target 'SparkSetupExample-Swift' do 

    xcodeproj 'SparkSetupExample-Swift'
    pod "SparkSetup", :path => "../spark-setup-ios"
    pod "Spark-SDK", :path => "../spark-sdk-ios"
    plugin 'cocoapods-keys', {
        :project => "SparkSetupExample-Swift",
        :keys => [
        "OAuthClientId",
        "OAuthSecret"
        ]}
end

