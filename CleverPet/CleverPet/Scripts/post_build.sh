versionString=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" ${PROJECT_DIR}/${INFOPLIST_FILE})

revision=`git rev-parse --short HEAD`
echo $revision

buildVersion=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ${PROJECT_DIR}/${INFOPLIST_FILE})
finalVersionString="$versionString (""$buildVersion"")"
echo $finalVersionString

/usr/libexec/PlistBuddy "$CODESIGNING_FOLDER_PATH/Settings.bundle/Root.plist" -c "set PreferenceSpecifiers:0:DefaultValue $finalVersionString"
/usr/libexec/PlistBuddy "$CODESIGNING_FOLDER_PATH/Settings.bundle/Root.plist" -c "set PreferenceSpecifiers:1:DefaultValue $revision"