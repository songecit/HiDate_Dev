
#!/bin/sh
# sudo chmod -R 777 build.sh  #修改权限

export LANG=en_US.UTF-8
security unlock-keychain "-p" "12345"

projectpath=$(pwd)
basepath="/Users/Shared/Jenkins"

#svn更新并删除老的ipa文件
packagepath="$basepath/AppPackages/HiDate/production"
cd $packagepath
svn update
svn rm *.ipa || true

#cd到工程目录下
cd $projectpath

#pod安装
/usr/local/bin/pod install
#pod update --verbose --no-repo-update

#clean
xcodebuild -workspace "HiDate.xcworkspace" -scheme "HiDate" -configuration "Release" clean
#build
xcodebuild -workspace "HiDate.xcworkspace"  -scheme "HiDate" -sdk iphoneos -configuration "Release" CODE_SIGN_IDENTITY="iPhone Distribution: Shanghai 830clock Network Technology Co., Ltd."

#获取版本号
bundleversion=$(/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" "$projectpath/HiDate/Info.plist")
ipaname="hidate-ipa_$bundleversion.ipa"
#打包
basepath="/Users/Shared/Jenkins"
xcrun -sdk iphoneos PackageApplication "$basepath/Library/Developer/Xcode/DerivedData/HiDate-fpghcefzfdiikxgdbwqecnucxldq/Build/Products/Release-iphoneos/HiDate.app" -o "$packagepath/$ipaname"

cd $packagepath
svn add $ipaname
svn commit -m "update ipa file $ipaname"
