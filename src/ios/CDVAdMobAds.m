/*
 CDVAdMobAds.m
 Copyright 2015 AppFeel. All rights reserved.
 http://www.appfeel.com
 
 AdMobAds Cordova Plugin (cordova-admob)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "CDVAdMobAds.h"
#import "MainViewController.h"

@interface CDVAdMobAds() <GADRewardedAdDelegate>

@property (assign) BOOL isBannerRequested;
@property (assign) BOOL isInterstitialRequested;
@property (assign) BOOL isRewardedRequested;
@property (assign) BOOL isAppOpenRequested;

@property( assign) NSInteger rewardAmount;
@property( assign) NSString* rewardType;

- (void) __setOptions:(NSDictionary*) options;
- (BOOL) __createBanner:(NSString *)_pid withAdListener:(CDVAdMobAdsAdListener *)adListener isTappx:(BOOL)isTappx;
- (BOOL) __showBannerAd:(BOOL)show;
- (BOOL) __createInterstitial:(NSString *)_iid withAdListener:(CDVAdMobAdsAdListener *)adListener;
- (BOOL) __showInterstitial:(BOOL)show;
- (BOOL) __createRewarded:(NSString *)_iid withAdListener:(CDVAdMobAdsAdListener *)adListener;
- (BOOL) __showRewarded:(BOOL)show;
- (GADRequest*) __buildAdRequest;
- (NSString*) __md5: (NSString*) s;
- (NSString *) __admobDeviceID;
- (NSString *) __getPublisherId;
- (NSString *) __getPublisherId:(BOOL)isTappx;
- (NSString *) __getInterstitialId:(BOOL)isBackFill;
- (NSString *) __getRewardedId;
- (NSString *) __getAppOpenId;

- (void)resizeViews;

- (GADAdSize)__adSizeFromString:(NSString *)string;

- (void)deviceOrientationChange:(NSNotification *)notification;

@end

@implementation CDVAdMobAds

#define INTERSTITIAL                @"interstitial";
#define REWARDED                    @"rewarded";
#define BANNER                      @"banner";
#define APP_OPEN                    @"app_open";

#define OPT_PUBLISHER_ID            @"bannerAdId"
#define OPT_INTERSTITIAL_ADID       @"interstitialAdId"
#define OPT_REWARDED_ADID           @"rewardedAdId"
#define OPT_APP_OPEN_ADID           @"appOpenAdId"
#define OPT_AD_SIZE                 @"adSize"
#define OPT_BANNER_AT_TOP           @"bannerAtTop"
#define OPT_OVERLAP                 @"overlap"
#define OPT_OFFSET_STATUSBAR        @"offsetStatusBar"
#define OPT_IS_TESTING              @"isTesting"
#define OPT_AD_EXTRAS               @"adExtras"
#define OPT_AUTO_SHOW_BANNER        @"autoShowBanner"
#define OPT_AUTO_SHOW_INTERSTITIAL  @"autoShowInterstitial"
#define OPT_AUTO_SHOW_REWARDED      @"autoShowRewarded"
#define OPT_TAPPX_ID_IOS            @"tappxIdiOS"
#define OPT_TAPPX_SHARE             @"tappxShare"

@synthesize isInterstitialAvailable;
@synthesize isRewardedAvailable;
@synthesize isAppOpenAvailable;

@synthesize bannerView;
@synthesize interstitialView;
@synthesize rewardedView;
@synthesize adsListener;
@synthesize bannerAdId, interstitialAdId,rewardedAdId, appOpenAdId,  tappxId, adSize, tappxShare;
@synthesize isBannerAtTop, isBannerOverlap, isOffsetStatusBar;
@synthesize isTesting, adExtras;

@synthesize isBannerVisible, isBannerInitialized, isBannerRequested, isInterstitialRequested, isRewardedRequested, isAppOpenRequested;
@synthesize isBannerShow, isBannerAutoShow, isInterstitialAutoShow,isRewardedAutoShow, hasTappx;
@synthesize  rewardAmount,rewardType ;

#pragma mark Cordova JS bridge

- (void)pluginInitialize {
    // These notifications are required for re-placing the ad on orientation
    // changes. Start listening for notifications here since we need to
    // translate the Smart Banner constants according to the orientation.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationChange:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    isBannerShow = true;
    bannerAdId = nil;
    interstitialAdId = nil;
    rewardedAdId = nil;
    appOpenAdId = nil;
    adSize = [self __adSizeFromString:@"SMART_BANNER"];
    
    isBannerAtTop = false;
    isBannerOverlap = false;
    isOffsetStatusBar = false;
    isTesting = false;
    
    isBannerAutoShow = true;
    isInterstitialAutoShow = true;
    isRewardedAutoShow = false;
    
    isBannerInitialized = false;
    isBannerVisible = false;
    
    isBannerRequested = false;
    isInterstitialRequested = false;
    isRewardedRequested = false;
    isAppOpenRequested = false;
    
    hasTappx = false;
    tappxShare = 0.5;
    
    adsListener = [[CDVAdMobAdsAdListener alloc] initWithAdMobAds:self];
    
    rewardAmount = 0;
    rewardType = @"";
    
    srand((unsigned)time(NULL));
}


- (void)setOptions:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSArray* args = command.arguments;
    
    NSUInteger argc = [args count];
    if (argc >= 1) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:options];
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)createBannerView:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    NSArray* args = command.arguments;
    
    NSUInteger argc = [args count];
    if (argc >= 1) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:options];
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        isBannerRequested = true;
        NSString *_pid = [self __getPublisherId:false];
        
        if (![self __createBanner:_pid withAdListener:adsListener  isTappx:[_pid isEqualToString:tappxId]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
        }
        
        isBannerShow = isBannerAutoShow;
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)destroyBannerView:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        if (self.bannerView) {
            [self.bannerView setDelegate:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.bannerView removeFromSuperview];
                self.bannerView = nil;
                [self resizeViews];
            });
        }
        
        isBannerRequested = false;
        // Call the success callback that was passed in through the javascript.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)showBannerAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    
    BOOL show = YES;
    NSUInteger argc = [arguments count];
    if (argc >= 1) {
        NSString* showValue = [arguments objectAtIndex:0];
        show = (showValue != nil) ? [showValue boolValue] : YES;
    }
    isBannerShow = show;
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        if (!self.bannerView) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"adView is null, call createBannerView first."];
            
        } else {
            if (![self __showBannerAd:show]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

-(void)showAppOpenAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        
        if (!self.isAppOpenAvailable && self.appOpenAd) {
            self.appOpenAd = nil;
        }
        
        if (!self.appOpenAd) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"App Open Ad is null, call requestAppOpenAd first."];
        } else {
            if(![self __showAppOpenAd:YES]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to show App Open ad"];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)showInterstitialAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        
        if (!isInterstitialAvailable && interstitialView) {
            self.interstitialView.delegate = nil;
            self.interstitialView = nil;
        }
        
        if (!self.interstitialView) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"interstitialAd is null, call requestInterstitialAd first."];
            
        } else {
            if (![self __showInterstitial:YES]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)showRewardedAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult;
        
        if (!isRewardedAvailable && rewardedView) {
            ////self.rewardedView.delegate = nil;
            self.rewardedView = nil;
        }
        
        if (!self.rewardedView) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"rewardedView is null, call requestRewardedAd first."];
            
        } else {
            if (![self __showRewarded:YES]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)onBannerAd:(GADBannerView *)adView adListener:(CDVAdMobAdsAdListener *)adListener {
    if (self.isBannerShow) {
        [self.commandDelegate runInBackground:^{
            if (![self __showBannerAd:YES]) {
                [adListener adViewDidFailedToShow:adView];
            } else {
                [adListener adViewWillPresentScreen:adView];
            }
        }];
    }
}

- (void)onInterstitialAd:(GADInterstitial *)interstitial adListener:(CDVAdMobAdsAdListener *)adListener {
    self.isInterstitialAvailable = true;
    if (self.isInterstitialAutoShow) {
        [self.commandDelegate runInBackground:^{
            if (![self __showInterstitial:YES]) {
                [adListener interstitialDidFailedToShow:interstitial];
            }
        }];
    }
}

- (void)onRewardedAd:(GADRewardedAd *)rewarded adListener:(CDVAdMobAdsAdListener *)adListener {
    self.isRewardedAvailable = true;
    if (self.isRewardedAutoShow) {
        [self.commandDelegate runInBackground:^{
            if (![self __showRewarded:YES]) {
                [self rewardedDidFailedToShow:rewarded];
            }
        }];
    }
}

- (void)onAppOpenAd:(GADAppOpenAd *)appOpenAd adListener:(CDVAdMobAdsAdListener *)adListener {
    self.isAppOpenAvailable = true;
    self.appOpenAd = appOpenAd;
}

- (void)requestInterstitialAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    NSArray* args = command.arguments;
    
    NSUInteger argc = [args count];
    if (argc >= 1) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:options];
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        isInterstitialRequested = true;
        
        if (!isInterstitialAvailable && interstitialView) {
            self.interstitialView.delegate = nil;
            self.interstitialView = nil;
        }
        
        if (isInterstitialAvailable) {
            [adsListener interstitialDidReceiveAd:interstitialView];
            
        } else if (!self.interstitialView) {
            NSString *_iid = [self __getInterstitialId:false];
            
            if (![self __createInterstitial:_iid withAdListener:adsListener]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
            }
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

-(void)requestAppOpenAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    NSArray* args = command.arguments;
    
    NSUInteger argc = [args count];
    if (argc >= 1) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:options];
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        self.isAppOpenRequested = true;
        if (!self.isAppOpenAvailable && self.appOpenAd) {
            self.appOpenAd = nil;
        }
        
        if (self.isAppOpenAvailable) {
//            [adsListener appOpenDidReceiveAd:appOpenAd];
        } else if (!self.appOpenAd) {
            NSString *_iid = [self __getAppOpenId];
            if (![self __createAppOpen:_iid withAdListener:self.adsListener]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unable to create App Open ad"];
            }
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}

- (void)requestRewardedAd:(CDVInvokedUrlCommand *)command {
    NSString *callbackId = command.callbackId;
    NSArray* args = command.arguments;
    
    NSUInteger argc = [args count];
    if (argc >= 1) {
        NSDictionary* options = [command argumentAtIndex:0 withDefault:[NSNull null]];
        [self __setOptions:options];
    }
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        isRewardedRequested = true;
        
        if (!isRewardedAvailable && rewardedView) {
            ////self.rewardedView.delegate = nil;
            self.rewardedView = nil;
        }
        
        if (isRewardedAvailable) {
              [adsListener rewardAdDidReceiveAd:rewardedView];
            
        } else if (!self.rewardedView) {
            NSString *_iid = [self __getRewardedId];
            
            if (![self __createRewarded:_iid withAdListener:self]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."];
            }
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    }];
}


- (GADAdSize)__adSizeFromString:(NSString *)string {
    if ([string isEqualToString:@"BANNER"]) {
        return kGADAdSizeBanner;
        
    } else if ([string isEqualToString:@"IAB_MRECT"]) {
        return kGADAdSizeMediumRectangle;
        
    } else if ([string isEqualToString:@"IAB_BANNER"]) {
        return kGADAdSizeFullBanner;
        
    } else if ([string isEqualToString:@"IAB_LEADERBOARD"]) {
        return kGADAdSizeLeaderboard;
        
    } else if ([string isEqualToString:@"SMART_BANNER"]) {
        CGRect pr = self.webView.superview.bounds;
        if (pr.size.width > pr.size.height) {
            return kGADAdSizeSmartBannerLandscape;
        }
        else {
            return kGADAdSizeSmartBannerPortrait;
        }
        
    } else {
        return kGADAdSizeInvalid;
    }
}

- (NSString*) __md5:(NSString *) s {
    const char *cstr = [s UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)__admobDeviceID {
    NSUUID* adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *output = [self __md5:adid.UUIDString];
    
    return output;
}

- (NSString *) __getPublisherId {
    return [self __getPublisherId:hasTappx];
}

- (NSString *) __getPublisherId:(BOOL)isTappx {
    NSString *_publisherId = bannerAdId;
    
    if (hasTappx && rand()%100 <= (tappxShare * 100)) {
        if (tappxId != nil && tappxId.length > 0) {
            _publisherId = tappxId;
        }
    }
    return _publisherId;
}

- (NSString *) __getInterstitialId:(BOOL)isBackFill {
    NSString *_interstitialAdId = interstitialAdId;
    
    if (hasTappx && rand()%100 <= (tappxShare * 100)) {
        if (tappxId != nil && tappxId.length > 0) {
            _interstitialAdId = tappxId;
        }
    }
    return _interstitialAdId;
}
- (NSString *) __getRewardedId {
    NSString *_rewardedAdId = rewardedAdId;
    
    return _rewardedAdId;
}

- (NSString *) __getAppOpenId {
    NSString *_appOpenAdId = appOpenAdId;
    
    return _appOpenAdId;
}


#pragma mark Ad Banner logic

- (void) __setOptions:(NSDictionary*) options {
    if ((NSNull *)options == [NSNull null]) {
        return;
    }
    
    NSString* str = nil;
    
    str = [options objectForKey:OPT_PUBLISHER_ID];
    if (str && ![str isEqual:[NSNull null]] && [str length] > 0) {
        bannerAdId = str;
    }
    
    str = [options objectForKey:OPT_INTERSTITIAL_ADID];
    if (str && ![str isEqual:[NSNull null]] && [str length] > 0) {
        interstitialAdId = str;
    }
    
    str = [options objectForKey:OPT_REWARDED_ADID];
    if (str && ![str isEqual:[NSNull null]] && [str length] > 0) {
        rewardedAdId = str;
    }
    
    str = [options objectForKey:OPT_APP_OPEN_ADID];
    if (str && ![str isEqual:[NSNull null]] && [str length] > 0) {
        appOpenAdId = str;
    }
    
    str = [options objectForKey:OPT_AD_SIZE];
    if (str && ![str isEqual:[NSNull null]]) {
        adSize = [self __adSizeFromString:str];
    }
    
    str = [options objectForKey:OPT_BANNER_AT_TOP];
    if (str && ![str isEqual:[NSNull null]]) {
        isBannerAtTop = [str boolValue];
    }
    
    str = [options objectForKey:OPT_OVERLAP];
    if (str && ![str isEqual:[NSNull null]] ) {
        isBannerOverlap = [str boolValue];
    }
    
    str = [options objectForKey:OPT_OFFSET_STATUSBAR];
    if (str && ![str isEqual:[NSNull null]]) {
        isOffsetStatusBar = [str boolValue];
    }
    
    str = [options objectForKey:OPT_IS_TESTING];
    if (str && ![str isEqual:[NSNull null]]) {
        isTesting = [str boolValue];
    }
    
    NSDictionary* dict = [options objectForKey:OPT_AD_EXTRAS];
    if (dict && ![dict isEqual:[NSNull null]]) {
        adExtras = dict;
    }
    
    str = [options objectForKey:OPT_AUTO_SHOW_BANNER];
    if (str && ![str isEqual:[NSNull null]]) {
        isBannerAutoShow = [str boolValue];
    }
    
    str = [options objectForKey:OPT_AUTO_SHOW_INTERSTITIAL];
    if (str && ![str isEqual:[NSNull null]]) {
        isInterstitialAutoShow = [str boolValue];
    }
    
    str = [options objectForKey:OPT_AUTO_SHOW_REWARDED];
    if (str && ![str isEqual:[NSNull null]]) {
        isRewardedAutoShow = [str boolValue];
    }
    
    str = [options objectForKey:OPT_TAPPX_ID_IOS];
    if (str && ![str isEqual:[NSNull null]]) {
        tappxId = str;
        hasTappx = true;
        tappxShare = 0.5;
    }
    
    str = [options objectForKey:OPT_TAPPX_SHARE];
    if (str && ![str isEqual:[NSNull null]]) {
        tappxShare = [str doubleValue];
        hasTappx = true;
    }
}

- (BOOL) __createBanner:(NSString *)_pid withAdListener:(CDVAdMobAdsAdListener *)adListener isTappx:(BOOL)isTappx {
    BOOL succeeded = false;
    __block NSString *__pid = _pid;
    
    if (self.bannerView && ![self.bannerView.adUnitID isEqualToString:_pid]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.bannerView removeFromSuperview];
            self.bannerView = nil;
            // [self resizeViews];
        });
    }
    
    if (!self.bannerView) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (isTappx) {
                if (CGSizeEqualToSize(adSize.size, kGADAdSizeBanner.size)) {
                    self.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
                    
                } else if (CGSizeEqualToSize(adSize.size, kGADAdSizeMediumRectangle.size)) {
                    __pid = [self __getPublisherId:false];
                    self.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
                    
                } else if (CGSizeEqualToSize(adSize.size, kGADAdSizeFullBanner.size)) {
                    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
                    
                } else if (CGSizeEqualToSize(adSize.size, kGADAdSizeLeaderboard.size)) {
                    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
                    
                } else if (CGSizeEqualToSize(adSize.size, kGADAdSizeSmartBannerLandscape.size) || CGSizeEqualToSize(adSize.size, kGADAdSizeSmartBannerPortrait.size)) {
                    CGRect pr = self.webView.superview.bounds;
                    if (pr.size.width >= 768.0) {
                        self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(768, 90))];
                    } else {
                        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
                    }
                }
            } else {
                self.bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
            }
            
        });
        self.bannerView.rootViewController = self.viewController;
        
        self.isBannerInitialized = YES;
        self.isBannerVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resizeViews];
        });
    }
    
    self.bannerView.adUnitID = __pid;
    self.bannerView.delegate = adListener;
    
    GADRequest *request = [self __buildAdRequest];
    if (!request) {
        succeeded = false;
        if (self.bannerView) {
            [self.bannerView setDelegate:nil];
            [self.bannerView removeFromSuperview];
            self.bannerView = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resizeViews];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bannerView loadRequest:request];
        });
        succeeded = true;
    }
    
    return succeeded;
}

- (GADRequest*) __buildAdRequest {
    GADRequest *request = [GADRequest request];
    
    if (self.isTesting) {
        ASIdentifierManager *am = [ASIdentifierManager sharedManager];
        if (!am.advertisingTrackingEnabled) {
            return nil;
        }
        
        // Make the request for a test ad. Put in an identifier for the simulator as
        // well as any devices you want to receive test ads.
        // @"02b0ce0fda9a1f681188ca40e7fa71e1"
        // @"9a6658d2afbc898171e38c6e8080e20de4e4dc42",
        // @"9A6658D2AFBC898171E38C6E8080E20DE4E4DC42",
        NSString *admobDeviceId = [[self __admobDeviceID] lowercaseString];
        request.testDevices = [NSArray arrayWithObjects:
                               admobDeviceId,
                               kGADSimulatorID,
                               nil];
    }
    
    if (self.adExtras) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            GADExtras *extras = [[GADExtras alloc] init];
            NSMutableDictionary *modifiedExtrasDict =
            [[NSMutableDictionary alloc] initWithDictionary:self.adExtras];
            
            [modifiedExtrasDict removeObjectForKey:@"cordova"];
            [modifiedExtrasDict setValue:@"1" forKey:@"cordova"];
            extras.additionalParameters = modifiedExtrasDict;
            [request registerAdNetworkExtras:extras];
        });
    }
    
    return request;
}

- (BOOL) __showBannerAd:(BOOL)show {
    BOOL succeeded = false;
    
    if (!self.isBannerInitialized) {
        NSString *_pid = [self __getPublisherId:false];
        
        succeeded = [self __createBanner:_pid withAdListener:adsListener  isTappx:[_pid isEqualToString:tappxId]];
        self.isBannerAutoShow = true; // Banner will be shown when loaded
        
    } else if (show == self.isBannerVisible) { // same state, nothing to do
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resizeViews];
        });
        succeeded = true;
        
    } else if (show) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView* parentView;
            if (self.isBannerOverlap) {
                parentView = self.webView;
            } else {
                parentView = [self.webView superview];
            }
        
            [parentView addSubview:self.bannerView];
            [parentView bringSubviewToFront:self.bannerView];
            [self resizeViews];
            self.isBannerVisible = YES;
        });
        succeeded = true;
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.bannerView removeFromSuperview];
            [self resizeViews];
            
            self.isBannerVisible = NO;
        });
        
        succeeded = true;
    }
    
    return succeeded;
}

- (BOOL) __createAppOpen:(NSString *)_appOpenId withAdListener:(CDVAdMobAdsAdListener *) adListener {
    BOOL succeeded = false;
    
    if (self.appOpenAd) {
        self.appOpenAd = nil;
    }
    
    GADRequest *request = [self __buildAdRequest];
    if (!request) {
        succeeded = false;
        if (self.appOpenAd) {
            self.appOpenAd = nil;
            
        }
    } else {
        [GADAppOpenAd loadWithAdUnitID:_appOpenId request:request orientation:UIInterfaceOrientationPortrait completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to load app open ad: %@", error);
              
            }
            [adListener appOpenDidReceiveAd:appOpenAd];
//            self.appOpenAd = appOpenAd;
        }];
    }
    
    return succeeded;
}

- (BOOL) __showAppOpenAd:(BOOL)show {
    BOOL succeeded = false;
    
    if (!self.appOpenAd) {
        NSString *_iid = [self __getAppOpenId];
        
        succeeded = [self __createAppOpen:_iid withAdListener:adsListener];
        isAppOpenRequested = true;
        
    } else {
        succeeded = true;
    }
    
    if (self.appOpenAd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.appOpenAd presentFromRootViewController:self.viewController];
            self.isAppOpenRequested = false;
        });
    }
    
    return succeeded;
}

- (BOOL) __createInterstitial:(NSString *)_iid withAdListener:(CDVAdMobAdsAdListener *) adListener {
    BOOL succeeded = false;
    
    // Clean up the old interstitial...
    if (self.interstitialView) {
        self.interstitialView.delegate = nil;
        self.interstitialView = nil;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.interstitialView = [[GADInterstitial alloc] initWithAdUnitID:_iid];
    });
    self.interstitialView.delegate = adListener;
    
    GADRequest *request = [self __buildAdRequest];
    if (!request) {
        succeeded = false;
        if (self.interstitialView) {
            [self.interstitialView setDelegate:nil];
            self.interstitialView = nil;
        }
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.interstitialView loadRequest:request];
        });
        succeeded = true;
        self.isInterstitialAvailable = false;
    }
    
    
    return succeeded;
}

- (BOOL) __showInterstitial:(BOOL)show {
    BOOL succeeded = false;
    
    if (!self.interstitialView) {
        NSString *_iid = [self __getInterstitialId:false];
        
        succeeded = [self __createInterstitial:_iid withAdListener:adsListener];
        isInterstitialRequested = true;
        
    } else {
        succeeded = true;
    }
    
    if (self.interstitialView && self.interstitialView.isReady) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.interstitialView presentFromRootViewController:self.viewController];
            isInterstitialRequested = false;
        });
    }
    
    return succeeded;
}


- (BOOL) __createRewarded:(NSString *)_iid withAdListener:(CDVAdMobAdsAdListener *) adListener {
    BOOL succeeded = false;
    
    // Clean up the old rewardedAd...
    if (self.rewardedView) {
        ////self.rewardedView.delegate = nil;
        self.rewardedView = nil;
    }
    
    
   // dispatch_sync(dispatch_get_main_queue(), ^{
        //Initialize Google Mobile Ads SDK
        //note: will this cause an issue if called more than once?
       GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"52338ec92deaa332f0af451c672602f0" ];
        self.rewardedView = [[GADRewardedAd alloc]  initWithAdUnitID:_iid];
    //});
    ////self.rewardedView.delegate = adListener;
    GADRequest *request = [GADRequest request];
   
    if (!request) {
        succeeded = false;
        if (self.rewardedView) {
            self.rewardedView = nil;
        }
        
    } else {
       // dispatch_async(dispatch_get_main_queue(), ^{
            [self.rewardedView loadRequest:request   completionHandler:^(GADRequestError * _Nullable error) {
                if (error) {
                  // Handle ad failed to load case.
                } else {
                  // Ad successfully loaded.
                    self.isRewardedAvailable = true;
                    //todo: send even ad loaded
                    [self rewardAdDidReceiveAd:self.rewardedView];
                }
            }];
       // });
        succeeded = true;
        self.isRewardedAvailable = false;
    }
    
    
    return succeeded;
}

- (BOOL) __showRewarded:(BOOL)show {
    BOOL succeeded = false;
    
    if (!self.rewardedView) {
        NSString *_iid = [self __getRewardedId];
        
        succeeded = [self __createRewarded:_iid withAdListener:adsListener];
        isRewardedRequested = true;
        
    } else {
        succeeded = true;
    }
    
    if (self.rewardedView && self.rewardedView.isReady) {
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self.rewardedView presentFromRootViewController:self.viewController delegate:self];
            isRewardedRequested = false;
        //});
    }
    
    return succeeded;
}

#pragma mark GADRewardedAdDelegate implementation

/// onAdLoaded
- (void)rewardAdDidReceiveAd:(GADRewardedAd *)rewarded {
    if (self.rewardedView) {
        [self onRewardedAd:rewarded adListener:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdLoaded, { 'adType' : 'rewarded' }); }, 1);"];
        }];
    }
}
- (void)rewardedDidFailedToShow:(GADRewardedAd *) rewarded {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'rewarded', 'error': %ld, 'reason': '%@' }); }, 1);";
        [self.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          0,
                                          @"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."]];
   }];
    
}

/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
  //Reward the user.
  NSLog(@"rewardedAd:userDidEarnReward:");
    self.rewardAmount = [reward.amount integerValue];
    self.rewardType = reward.type;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        [NSString stringWithFormat:
         @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdRewarded, { 'adType' : 'rewarded','rewardType': '%@','rewardAmount': %ld }); }, 1);"
         ,self.rewardType
         ,(long)self.rewardAmount
         ];
        [self.commandDelegate evalJs:jsString];
        self.isRewardedAvailable = false;
    }];
}

/// Tells the delegate that the rewarded ad was presented.
- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
  NSLog(@"rewardedAdDidPresent:");
    if (self.isRewardedAvailable) {
           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               [self.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdOpened, { 'adType' : 'rewarded' }); }, 1);"];
           }];
           self.isRewardedAvailable = false;
           self.rewardAmount = 0;
           self.rewardType = @"";
       }
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      NSString *jsString =
      @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
      @"{ 'adType' : 'rewarded', 'error': %ld, 'reason': '%@' }); }, 1);";
      [self.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                        0,
                                        @"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."]];
  }];
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
  NSLog(@"rewardedAdDidDismiss:");
     [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
         NSString *jsString =
         [NSString stringWithFormat:
          @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdClosed, { 'adType' : 'rewarded','rewardType': '%@','rewardAmount': %ld }); }, 1);"
          ,self.rewardType
          ,(long)self.rewardAmount
          ];
          [self.commandDelegate evalJs:jsString];
     }];
     self.isRewardedAvailable = false;
    
}

#pragma mark -


- (void)resizeViews {
    // Frame of the main container view that holds the Cordova webview.
    CGRect pr = self.webView.superview.bounds;
    CGRect wf = pr;
    //NSLog(@"super view: %d x %d", (int)pr.size.width, (int)pr.size.height);
    
    // iOS7 Hack, handle the Statusbar
    BOOL isIOS7 = ([[UIDevice currentDevice].systemVersion floatValue] >= 7);
    CGRect sf = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat top;
    
    if (isIOS7 && self.isOffsetStatusBar) {
        top = MIN(sf.size.height, sf.size.width);
    } else {
        top = 0.0;
    }
    
    wf.origin.y = top;
    wf.size.height = pr.size.height - top;
    
    if (self.bannerView) {
        
        // Rotate banner if screen has rotated
        if (pr.size.width > pr.size.height) {
            if (GADAdSizeEqualToSize(self.bannerView.adSize, kGADAdSizeSmartBannerPortrait)) {
                self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
            }
        } else {
            if (GADAdSizeEqualToSize(self.bannerView.adSize, kGADAdSizeSmartBannerLandscape)) {
                self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
            }
        }
        
        CGRect bf = self.bannerView.frame;
        UIView* parentView;
        
        if (self.isBannerOverlap) {
            parentView = self.webView;
        } else {
            parentView = [self.webView superview];
        }
        
        // If the ad is not showing or the ad is hidden, we don't want to resize anything.
        BOOL isAdShowing = ([self.bannerView isDescendantOfView:parentView]) && (!self.bannerView.hidden);
        if (isAdShowing) {
            if (isBannerAtTop) {
                if (isBannerOverlap) {
                    wf.origin.y = top;
                    bf.origin.y = 0; // banner is subview of webview
                } else {
                    bf.origin.y = top;
                    wf.origin.y = bf.origin.y + bf.size.height;
                }
                
            } else {
                // move webview to top
                wf.origin.y = top;
                
                if (isBannerOverlap) {
                    bf.origin.y = wf.size.height - bf.size.height; // banner is subview of webview
                } else {
                    bf.origin.y = pr.size.height - bf.size.height;
                }
            }
            
            if (!isBannerOverlap) {
                wf.size.height -= bf.size.height;
            }
            
            bf.origin.x = (pr.size.width - bf.size.width) * 0.5f;
            
            self.bannerView.frame = bf;
            
            //NSLog(@"x,y,w,h = %d,%d,%d,%d", (int) bf.origin.x, (int) bf.origin.y, (int) bf.size.width, (int) bf.size.height );
        }
    }
    
    self.webView.frame = wf;
    
    //NSLog(@"superview: %d x %d, webview: %d x %d", (int) pr.size.width, (int) pr.size.height, (int) wf.size.width, (int) wf.size.height );
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resizeViews];
    });
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    bannerView.delegate = nil;
    bannerView = nil;
    
    interstitialView.delegate = nil;
    interstitialView = nil;
    
    ////rewardedView.delegate = nil;
    rewardedView = nil;
    
    adsListener = nil;
    
    adExtras = nil;
}

@end
