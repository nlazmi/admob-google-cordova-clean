This is a fork of the plugin by AppFeel that doesn't take 2% of your impressions. Changes were originally made by https://github.com/TheBosZ/admob-google-cordova . But, removed the dependency on another project for Google Admob Frameowork for iOS.

## Quick start ##

To install this plugin, follow the [Command-line Interface Guide](http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface). You can use one of the following command lines:

* `cordova plugin add https://github.com/jamesfdickinson/admob-google-cordova-clean.git --variable ADMOB_APP_ID="123456789"`
* Note: If you add the correct ADMOB_APP_ID after the build you may need to remove the plugin and re-add it as the original value is saved in the plugin folder and overrides the config settings.

## Change Log ##
4.4.0

- Added required android AndroidManifest.xml meta-data tag.use the variable in the config add your abmob's appid. `<meta-data       android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="[ADMOB_APP_ID]"/>`.  See: https://developers.google.com/admob/android/quick-start
- MobileAds.initialize(appid) is executed internally as required by the current admob sdk

Cordova AdMob plugin
====================

Monetize your Cordova/Phonegap/XDK apps with AdMob ads, **using latest Google AdMob SDK**.
With this Cordova/Phonegap/XDK plugin you can show AdMob ads as easy as:

    admob.createBannerView({bannerAdId: "ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB"});

Or

    admob.requestInterstitialAd({interstitialAdId: "ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII"});

![Integrate cordova admob plugin](https://github.com/appfeel/admob-google-cordova/wiki/demo/integrate-admob-cordova.gif)




---
## Platform SDK supported ##

* iOS, using AdMob SDK for iOS, v7.12.1
* Android, using Google Play Service for Android, v7.5

---
## Quick start ##

To install this plugin, follow the [Command-line Interface Guide](http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface). You can use one of the following command lines:

* `cordova plugin add https://github.com/jamesfdickinson/admob-google-cordova-clean.git --variable ADMOB_APP_ID="123456789"`

To start showing ads, place the following code in your `onDeviceReady` callback. Replace corresponding id's with yours:

*Note: ensure you have a proper [AdMob](https://apps.admob.com/admob/signup) aaccount and get your admob's appid id's*.

```javascript
    
    function onDeviceReady() {
      document.removeEventListener('deviceready', onDeviceReady, false);
      
      // Set AdMobAds options:
      admob.setOptions({
        appId:                "ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA",  // Required, refer to AdMob's App ID
        bannerAdId:           "ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB",  // Optional
        interstitialAdId:     "ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII",  // Optional
        tappxIdiOS:           "/XXXXXXXXX/Pub-XXXX-iOS-IIII",            // Optional
        tappxIdAndroid:       "/XXXXXXXXX/Pub-XXXX-Android-AAAA",        // Optional
        tappxShare:           0.5                                        // Optional
      });
      
      // Start showing banners (atomatic when autoShowBanner is set to true)
      admob.createBannerView();
      
      // Request interstitial (will present automatically when autoShowInterstitial is set to true)
      admob.requestInterstitialAd();
    }
    
    document.addEventListener("deviceready", onDeviceReady, false);
```




If you don't specify tappxId, no tappx requests will be placed (even if you specify a tappxShare). [See Tappx configuration](https://github.com/appfeel/admob-google-cordova/wiki/Tappx-configuration) for more detailed info.

:warning: Be sure to only fire on "deviceready" otherwise, the plugin would not work.

---
## Full documentation ##

Visit the [wiki](https://github.com/appfeel/admob-google-cordova/wiki) of Google AdMob Cordova plugin. Table of contents:

* [Home](https://github.com/appfeel/admob-google-cordova/wiki)
* [Table of contents](https://github.com/appfeel/admob-google-cordova/wiki/Table-of-contents)
* [Change Log](https://github.com/appfeel/admob-google-cordova/wiki/Change-Log)
* [Testimonials](https://github.com/appfeel/admob-google-cordova/wiki/Testimonials)
* [Setup](https://github.com/appfeel/admob-google-cordova/wiki/Setup)
* [Angular.js, Ionic apps](https://github.com/appfeel/admob-google-cordova/wiki/Angular.js,-Ionic-apps)
* [Tappx configuration](https://github.com/appfeel/admob-google-cordova/wiki/Tappx-configuration)
* [Javascript API](https://github.com/appfeel/admob-google-cordova/wiki/Javascript-API)
  * [setOptions](https://github.com/appfeel/admob-google-cordova/wiki/setOptions)
  * Banners
    * [createBannerView](https://github.com/appfeel/admob-google-cordova/wiki/createBannerView)
    * [showBannerAd](https://github.com/appfeel/admob-google-cordova/wiki/showBannerAd)
    * [destroyBannerView](https://github.com/appfeel/admob-google-cordova/wiki/destroyBannerView)
  * Interstitials
    * [requestInterstitialAd](https://github.com/appfeel/admob-google-cordova/wiki/requestInterstitialAd)
    * [showInterstitialAd](https://github.com/appfeel/admob-google-cordova/wiki/showInterstitialAd)
  * In app purchase
    * [recordResolution](https://github.com/appfeel/admob-google-cordova/wiki/recordResolution)
    * [recordPlayBillingResolution](https://github.com/appfeel/admob-google-cordova/wiki/recordPlayBillingResolution)
  * [Events](https://github.com/appfeel/admob-google-cordova/wiki/Events)
    * [onAdLoaded](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsonadloaded)
    * [onAdFailedToLoad](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsonadfailedtoload)
    * [onAdOpened](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsonadopened)
    * [onAdClosed](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsonadclosed)
    * [onAdLeftApplication](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsonadleftapplication)
    * [onInAppPurchaseRequested](https://github.com/appfeel/admob-google-cordova/wiki/Events#admobeventsoninapppurchaserequested)
* [Complete example code](https://github.com/appfeel/admob-google-cordova/wiki/Complete-example-code)
* [Contributing](https://github.com/appfeel/admob-google-cordova/wiki/Contributing)
* [Screenshots](https://github.com/appfeel/admob-google-cordova/wiki/Screenshots)

---
## Complete example code ##
Note that the admob ads are configured inside `onDeviceReady()`. This is because only after device ready the AdMob Cordova plugin will be working.

```javascript

    var isAppForeground = true;
    
    function initAds() {
      if (admob) {
        var adPublisherIds = {
          ios : {
            app : "ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA",
            banner : "ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB",
            interstitial : "ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII"
          },
          android : {
            app : "ca-app-pub-XXXXXXXXXXXXXXXX~AAAAAAAAAA",
            banner : "ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB",
            interstitial : "ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII"
          }
        };
        
        var admobid = (/(android)/i.test(navigator.userAgent)) ? adPublisherIds.android : adPublisherIds.ios;
            
        admob.setOptions({
          appId:            admobid.app,
          bannerAdId:       admobid.banner,
          interstitialAdId: admobid.interstitial,
          tappxIdiOS:       "/XXXXXXXXX/Pub-XXXX-iOS-IIII",
          tappxIdAndroid:   "/XXXXXXXXX/Pub-XXXX-Android-AAAA",
          tappxShare:       0.5,
          
        });

        registerAdEvents();
        
      } else {
        alert('AdMobAds plugin not ready');
      }
    }
    
    function onAdLoaded(e) {
      if (isAppForeground) {
        if (e.adType === admob.AD_TYPE.INTERSTITIAL) {
          console.log("An interstitial has been loaded and autoshown. If you want to load the interstitial first and show it later, set 'autoShowInterstitial: false' in admob.setOptions() and call 'admob.showInterstitialAd();' here");
        } else if (e.adType === admob.AD_TYPE_BANNER) {
          console.log("New banner received");
        }
      }
    }
    
    function onPause() {
      if (isAppForeground) {
        admob.destroyBannerView();
        isAppForeground = false;
      }
    }
    
    function onResume() {
      if (!isAppForeground) {
        setTimeout(admob.createBannerView, 1);
        setTimeout(admob.requestInterstitialAd, 1);
        isAppForeground = true;
      }
    }
    
    // optional, in case respond to events
    function registerAdEvents() {
      document.addEventListener(admob.events.onAdLoaded, onAdLoaded);
      document.addEventListener(admob.events.onAdFailedToLoad, function (e) {});
      document.addEventListener(admob.events.onAdOpened, function (e) {});
      document.addEventListener(admob.events.onAdClosed, function (e) {});
      document.addEventListener(admob.events.onAdLeftApplication, function (e) {});
      document.addEventListener(admob.events.onInAppPurchaseRequested, function (e) {});
      
      document.addEventListener("pause", onPause, false);
      document.addEventListener("resume", onResume, false);
    }
        
    function onDeviceReady() {
      document.removeEventListener('deviceready', onDeviceReady, false);
      initAds();

      // display a banner at startup
      admob.createBannerView();
        
      // request an interstitial
      admob.requestInterstitialAd();
    }
    
    document.addEventListener("deviceready", onDeviceReady, false);
```



---
## Screenshots ##
#### iPhone:

<img src="https://github.com/appfeel/admob-google-cordova/wiki/demo/iphone.png" border="10" alt="Phonegp Cordova admob plugin in iPhone" />

#### iPad Banner Portrait:

<img src="https://github.com/appfeel/admob-google-cordova/wiki/demo/banner-ipad.png" border="10" alt="Phonegp Cordova admob plugin in iPad" />

#### iPad Banner Landscape:

<img src="https://raw.githubusercontent.com/wiki/appfeel/admob-google-cordova/demo/banner-landscape-ipad.png" border="10" alt="Phonegp Cordova banner admob plugin" />

---
## License ##
```
The MIT License

Copyright (c) 2014 AppFeel

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---
## Credits ##

* [appFeel](http://www.appfeel.com)
