#!/bin/bash

################# Precondition #############################
# # 安装 fir-cli
# sudo gem install fir-cli

# # 安装 fastlane
# sudo gem install fastlane

################# End Precondition #############################

################# Constant ############################
# Release的类型
debug_build_type='debug'
test_build_type='test'
pro_build_type='pro'

# Release 版本升级的类型
# -a 是release 大版本
# -b 是中版本
# -c 是小版本
# -d 是build号
a_build_version='a'
b_build_version='b'
c_build_version='c'
d_build_version='d'

feedback_email=""
################# End Constant ########################

################# Get Parameters ############################
build_type=$test_build_type
build_version_type=$d_build_version
need_upload="1"
uploadMessage=""

function usage()
{
  echo "Build XXX app"
  echo ""
  echo "Options for build:"
  echo "-t, --buildtype STRING The build type. Valid values are: debug, test, pro"
  echo "-v, --versiontype STRING The version type. Valid values are: a, b, c, d. Example: if version is 2.3.0 and build is 2, then a is 2, b is 2, c is 0 and d is 2."
  echo "-m, --message STRING The upload message."
  echo "-u, --upload INTEGER Should app need to be upladed? Valid values are: 1, 0"
}

# $OPTARG to get arg value
# $OPTIND to get index
# Currently donot support long parameter
while getopts "t:v:m:u:" option
do
    case "$option" in
        t)
            build_type=$OPTARG
            ;;

        buildtype)
            build_type=$OPTARG
            ;;

        v)
            build_version_type=$OPTARG
            ;;

        versiontype)
            build_version_type=$OPTARG
            ;;

        m)
            uploadMessage=$OPTARG
            ;;

        message)
            uploadMessage=$OPTARG
            ;;
        u)
            need_upload=$OPTARG
            ;;
        upload)
            need_upload=$OPTARG
            ;;

        \?)
            usage
            exit 1;;
    esac
done

shift "$((OPTIND-1))" # Shift off the options and optional --. For safety.

################# End Get Parameters ############################

################# Configuration ############################
#ipa file name
app_ipa_file='XXXApp.ipa'

#the directory store the ipas,
app_package_path='../../XXXPackage'

#workspace file path
app_workspace='./XXXApp.xcworkspace'

#info plist file path
app_info_plist='./XXXApp/info.plist'

#info plist rollback
app_info_plist_rollback='XXXApp/Info.plist'

#schema name in xcode project
app_schema='XXXApp'

#app bundle identifier
app_bundle_identifier='com.XXX.mobileapp'

#app in Test Flight
app_id='1119555378'
apple_id='xxx@XXX.com'

#app beta testing in Pgyer
#pgyer_user_key='2345a98954206971112e6a5b95c62ddf'
#pgyer_api_key='226839d884a67dc3e0fa72767784c906'

#app beta testing in Fir
fir_user_token='28aef42ddc4d3bd0ef3443276441b4d2'


################# End Configuration ########################

echo "The build type is [$build_type]"
echo "The version type is [$build_version_type]"
echo "The uplaod is [$need_upload]"

function getVersion() {
  shortVersion=`/usr/libexec/PlistBuddy -c 'print CFBundleShortVersionString' $1`
  buildVersion=`/usr/libexec/PlistBuddy -c 'print CFBundleVersion' $1`
  version=${shortVersion}'.'${buildVersion}
  echo "$version"
}

function updateVersion() {
  OLD_IFS="$IFS"
  IFS="."
  version=($2)
  IFS="$OLD_IFS"

  shortVersion="${version[0]}.${version[1]}.${version[2]}"
  buildVersion=${version[3]}

  /usr/libexec/PlistBuddy -c "set CFBundleShortVersionString $shortVersion" $1
  /usr/libexec/PlistBuddy -c "set CFBundleVersion $buildVersion" $1
}

function incVersion() {
  OLD_IFS="$IFS"
  IFS="."
  version=($1)
  IFS="$OLD_IFS"
  build_version_type=$2

  if [[ $build_version_type = $d_build_version ]]; then
    version[3]=`expr 1 + ${version[3]}`
  elif [[ $build_version_type = $c_build_version ]]; then
    version[2]=`expr 1 + ${version[2]}`
  elif [[ $build_version_type = $b_build_version ]]; then
    version[1]=`expr 1 + ${version[1]}`
    version[2]=0
  elif [[ $build_version_type = $a_build_version ]]; then
    version[0]=`expr 1 + ${version[0]}`
    version[1]=0
    version[2]=0
  fi

  echo "${version[0]}.${version[1]}.${version[2]}.${version[3]}"
}


echo 'release XXXApp build'
echo 'get XXXApp build version'

version=`getVersion $app_info_plist`
echo "build version $version"

newVersion=`incVersion $version $build_version_type`
echo "update to new version $newVersion";
updateVersion $app_info_plist $newVersion

#  echo '-----------git status here ------------'
#  git status
#  echo '-----------git status end--------------'

#remove the old file if exsited
outputDir="$app_package_path/$build_type/$newVersion"
outputPath="$outputDir/$app_ipa_file"
outputArchivePath="$outputDir/$newVersion.xcarchive"
echo $outputPath

rm -rf "$outputPath"

if [[ $build_type = $debug_build_type ]]; then
  echo 'build XXXApp dev build now, please wait.................'
  fastlane gym --silent --workspace ${app_workspace} --scheme ${app_schema} --clean --xcargs 'GCC_PREPROCESSOR_DEFINITIONS="$GCC_PREPROCESSOR_DEFINITIONS DEBUG=1 COCOAPODS=1"' --export_method development --output_directory ${outputDir} --output_name ${app_ipa_file}
elif [[ $build_type = $test_build_type ]]; then
  echo 'build XXXApp test build now, please wait.................'
  fastlane gym --silent --workspace ${app_workspace} --scheme ${app_schema} --clean --xcargs 'GCC_PREPROCESSOR_DEFINITIONS="$GCC_PREPROCESSOR_DEFINITIONS TEST=1 COCOAPODS=1"' --export_method development --output_directory ${outputDir} --output_name ${app_ipa_file}
elif [[ $build_type = $pro_build_type ]]; then
  echo 'build XXXApp pro build now, please wait.................'
  fastlane gym --silent --workspace ${app_workspace} --scheme ${app_schema} --clean --xcargs 'GCC_PREPROCESSOR_DEFINITIONS="$GCC_PREPROCESSOR_DEFINITIONS PRO=1 COCOAPODS=1"' --archive_path ${outputArchivePath} --export_method app-store --output_directory ${outputDir} --output_name ${app_ipa_file}
fi

if [[ -e $outputPath ]]; then
  echo 'build ipa successfully, commit code'
  #svn ci -m "update XXXApp build to version  $newVersion"

  git commit -am "update XXXApp build to version  $newVersion"
  git push

  if [[ $need_upload = "1" ]]; then
      if [[ $uploadMessage = "" ]]; then
        uploadMessage="新版本测试 $newVersion (描述必须要十个字)"
      fi

      if [[ $build_type = $debug_build_type ]]; then
        echo 'uploading to Fir'
        fir publish $outputPath -T $fir_user_token -c $uploadMessage --verbose
      elif [[ $build_type = $test_build_type ]]; then
        echo 'uploading to Fir'
        fir publish $outputPath -T $fir_user_token -c $uploadMessage --verbose
      elif [[ $build_type = $pro_build_type ]]; then
        git tag "XXXApp_${newVersion}"
        git push origin "XXXApp_${newVersion}"

        echo 'uploading to Test Flight'
        fastlane pilot upload --username $apple_id --app_identifier $app_bundle_identifier --app_platform "ios" --ipa $outputPath --changelog $uploadMessage --beta_app_description $uploadMessage --beta_app_feedback_email $feedback_email
      fi

      osascript -e 'display notification "app上传成功" with title "通知"'
  fi
else
  echo 'build ipa failed, rollback info'
  git checkout $app_info_plist_rollback
fi