#!/bin/bash

meteor add-platform android
meteor build ../stitch-rocket-build --server=http://elb-stitch-2601.aptible.in
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 release-unsigned.apk stitch
#/Users/veto44/Library/Android/sdk/build-tools/23.0.2/zipalign 4 release-unsigned.apk stitch.apk
~/.meteor/android_bundle/android-sdk/build-tools/21.0.0/zipalign 4 .meteor/local/cordova-build/platforms/android/ant-build/CordovaApp-release-unsigned.apk .meteor/local/cordova-build/platforms/android/ant-build/stitch.apk
open .meteor/local/cordova-build/platforms/android/ant-build/
