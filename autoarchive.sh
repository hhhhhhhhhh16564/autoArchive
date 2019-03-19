 #!/bin/sh

# target   0 BB  1 JJ
# env  0 Prod  1  Dev  2. UAT
# configuration   0  Release  1 Debug
# Role 角色      0 Parent  1 Teacher
target=0
env=0
configuration=0
role=0
while getopts 't:e:c:r' OPT; 
do
	case $OPT in
		t)
 		temp="$OPTARG"
 		if [ $temp -ne 0 -a $temp -ne 1 ]; then
 			echo 't: 参数输入不合格'
 			exit 1;
 		fi
 		target=$temp
		;;
	 	e)
 		temp="$OPTARG"
 		if [ $temp -ne 0 -a $temp -ne 1 -a $temp -ne 2 ]; then
 			echo 'e: 参数输入不合格'
 			exit 1;
 		fi
 		env=$temp
 		;;
 		c)
 		temp="$OPTARG"
 		if [ $temp -ne 0 -a $temp -ne 1 ]; then
 			echo 'c : 参数输入不合格'
 			exit 1
 		fi
 		configuration=$temp
 		;;
 		r)
 		if [ $temp -ne 0 -a $temp -ne 1 ]; then
 			echo 'r: 参数输入不合格'
 			exit 1
 		fi
 		role=$temp
 		;;
 		?)
 		echo '参数输入错误'
 		exit 1
 		;;
	esac	 
done

targetArray=(BB JJ)
envArray=(Prod Dev UAT)
#对应三种证书的名称
proFileArray=(Adhot Dev AppStore)
configurationArray=(Release Debug)
RoleArray=(Parent Teacher)

proType=${proFileArray[$env]}
target=${targetArray[$target]}
env=${envArray[$env]}
configuration=${configurationArray[$configuration]}
role=${RoleArray[$role]}



projectName="HHParent"

scheme="${target}${role}_${env}"

ROOT_PATH=$(cd `dirname $0`; pwd)
log_path="${ROOT_PATH}/log.txt"
autoBuildDate=`date +%Y-%m-%d——%H-%M-%S`
archiveRootPath="${ROOT_PATH}/archive"
autoBuildName="${autoBuildDate}_${scheme}"
archiveFilePath="${archiveRootPath}/${autoBuildName}.xcarchive"
ExportOptionsPlistName="${target}_$proType.plist"
ExportOptionsPlistPath="${ROOT_PATH}/ExportOptions/$ExportOptionsPlistName"
echo $archiveFilePath
echo $ExportOptionsPlistPath

#exit 0
ipaSourcePath="${archiveRootPath}/${scheme}.ipa"
ipaChangePath="${archiveRootPath}/${autoBuildName}.ipa"


plistRootPath="${ROOT_PATH}/${projectName}/plist/${target}.plist"

# echo $plistRootPath



buildVersionAdd(){
bundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${plistRootPath})
bundleVersion=`expr $bundleVersion + 1 `
/usr/libexec/PlistBuddy -c "Set CFBundleVersion $bundleVersion" ${plistRootPath}
# echo $bundleVersion
}


#1.clean
buildClean(){
  xcodebuild  -workspace  ${projectName}.xcworkspace \
  -scheme ${scheme} \
  -configuration $configuration \
  clean
}


 
 #2 .archive
buildArchive(){
xcodebuild -workspace ${projectName}.xcworkspace \
-scheme ${scheme} \
-archivePath $archiveFilePath \
archive

}


 #3.  打包ipa
buildExport(){
 xcodebuild -exportArchive -archivePath $archiveFilePath \
 -exportPath  ${archiveRootPath} \
 -exportOptionsPlist  $ExportOptionsPlistPath
}

#4. 对ipa文件重命名
changeName(){
	ipaSourcePath="${archiveRootPath}/${scheme}.ipa"
    ipaChangePath="${archiveRootPath}/${autoBuildName}.ipa"
	mv $ipaSourcePath $ipaChangePath
}
removeFile(){
rm -rf ${archiveRootPath}/DistributionSummary.plist
rm -rf ${archiveRootPath}/ExportOptions.plist
rm -rf ${archiveRootPath}/Packaging.log
}

buildClean
buildArchive
buildExport
buildExport
changeName
removeFile





