// This section sets up some basic app metadata,
// the entire section is optional.
App.info({
  id: 'com.teamstitch.stitch-meteor',
  version: '1.0.7',
  name: 'Stitch',
  description: 'Healthcare team messaging app',
  author: 'Bharat Kilaru',
  email: 'bharat@teamstitch.com',
  website: 'http://teamstitch.com'
});

// Set up resources such as icons and launch screens.
App.icons({
  iphone: 'private/images/icons/icon-60.png',
  iphone_2x: 'private/images/icons/icon-60@2x.png',
  iphone_3x: 'private/images/icons/icon-60@3x.png',
  ipad: 'private/images/icons/icon-76.png',
  ipad_2x: 'private/images/icons/icon-76@2x.png',

  android_ldpi: 'private/images/icons/icon-36x36.png',
  android_mdpi: 'private/images/icons/icon-48x48.png',
  android_hdpi: 'private/images/icons/icon-72.png',
  android_xhdpi:'private/images/icons/icon-96x96.png'
});

App.launchScreens({
  iphone: 'private/images/splash/Default.png',
  iphone_2x: 'private/images/splash/Default@2x.png',
  iphone5: 'private/images/splash/Default-568h@2x.png',
  iphone6: 'private/images/splash/Default-667h@2x.png',
  iphone6p_portrait: 'private/images/splash/Default-Portrait-736h@3x.png',
  iphone6p_landscape: 'private/images/splash/iphone6p_landscape.png',
  ipad_portrait: 'private/images/splash/Default-Portrait.png',
  ipad_portrait_2x: 'private/images/splash/Default-Portrait@2x.png',
  ipad_landscape: 'private/images/splash/Default-Landscape.png',
  ipad_landscape_2x: 'private/images/splash/Default-Landscape@2x.png',

  android_ldpi_portrait: 'private/images/splash/splash-200x320.png',
  android_ldpi_landscape: 'private/images/splash/splash-320x200.png',
  android_mdpi_portrait: 'private/images/splash/Default.png',
  android_mdpi_landscape: 'private/images/splash/splash-480x320.png',
  android_hdpi_portrait: 'private/images/splash/splash-480x800.png',
  android_hdpi_landscape: 'private/images/splash/splash-800x480.png',
  android_xhdpi_portrait: 'private/images/splash/splash-720x1280.png',
  android_xhdpi_landscape: 'private/images/splash/splash-1280x720.png'
});

// Set PhoneGap/Cordova preferences
App.setPreference('HideKeyboardFormAccessoryBar', true);
App.setPreference('StatusBarOverlaysWebView', false);
App.setPreference('StatusBarStyle', 'lightcontent');
App.setPreference('StatusBarBackgroundColor', '#003366');
App.setPreference('ShowSplashScreenSpinner', false);
App.setPreference('android-targetSdkVersion', '22');
App.setPreference('android-minSdkVersion', '19');
App.accessRule('*');
App.accessRule('blob:*');

App.configurePlugin('io.branch.sdk.branch', {
  'scheme': 'teamstitch',
  'host':'open'
});
