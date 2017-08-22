/*
 CDVAdMobAdsAdListener.m
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

#import <Foundation/Foundation.h>
#include "CDVAdMobAds.h"
#include "CDVAdMobAdsAdListener.h"

@interface CDVAdMobAdsAdListener()
- (NSString *) __getErrorReason:(NSInteger) errorCode;
@property(nonatomic, assign) NSInteger rewardAmount;
@property(nonatomic, assign) NSString rewardType;
@end


@implementation CDVAdMobAdsAdListener

@synthesize adMobAds;

- (instancetype)initWithAdMobAds: (CDVAdMobAds *)originalAdMobAds {
    self = [super init];
    if (self) {
        adMobAds = originalAdMobAds;
    }
    return self;
}

#pragma mark -
#pragma mark GADBannerViewDelegate implementation

// onAdLoaded
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdLoaded, { 'adType' : 'banner' }); }, 1);"];
    }];
    [adMobAds onBannerAd:adView adListener:self];
}

// onAdFailedToLoad
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s: Failed to receive ad with error: %@",
          __PRETTY_FUNCTION__, [error localizedFailureReason]);
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Since we're passing error back through Cordova, we need to set this up.
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'banner', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          (long)error.code,
                                          [self __getErrorReason:error.code]]];
    }];
    
}

- (void)adViewDidFailedToShow:(GADBannerView *)view {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'banner', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          0,
                                          @"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."]];
    }];
    
}

// onAdOpened
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdOpened, { 'adType' : 'banner' }); }, 1);"];
    }];
}

// onAdLeftApplication
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdLeftApplication, { 'adType' : 'banner' }); }, 1);"];
    }];
}

// onAdClosed
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdClosed, { 'adType' : 'banner' }); }, 1);"];
    }];
}

#pragma mark -
#pragma mark GADInterstitialDelegate implementation

// Sent when an interstitial ad request succeeded.  Show it at the next
// transition point in your application such as when transitioning between view
// controllers.
// onAdLoaded
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    if (adMobAds.interstitialView) {
        [adMobAds onInterstitialAd:interstitial adListener:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdLoaded, { 'adType' : 'interstitial' }); }, 1);"];
        }];
    }
}

- (void)interstitialDidFailedToShow:(GADInterstitial *) interstitial {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'interstitial', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          0,
                                          @"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."]];
    }];
    
}

// Sent when an interstitial ad request completed without an interstitial to
// show.  This is common since interstitials are shown sparingly to users.
// onAdFailedToLoad
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s: Failed to receive ad with error: %@",
          __PRETTY_FUNCTION__, [error localizedFailureReason]);
    adMobAds.isInterstitialAvailable = false;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'interstitial', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          (long)error.code,
                                          [self __getErrorReason:error.code]]];
    }];
    
}

// Sent just before presenting an interstitial.  After this method finishes the
// interstitial will animate onto the screen.  Use this opportunity to stop
// animations and save the state of your application in case the user leaves
// while the interstitial is on screen (e.g. to visit the App Store from a link
// on the interstitial).
// onAdOpened
- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial {
    if (adMobAds.isInterstitialAvailable) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdOpened, { 'adType' : 'interstitial' }); }, 1);"];
        }];
        adMobAds.isInterstitialAvailable = false;
    }
}

// Sent just after dismissing an interstitial and it has animated off the
// screen.
// onAdClosed
- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdClosed, { 'adType' : 'interstitial' }); }, 1);"];
    }];
    adMobAds.isInterstitialAvailable = false;
}



#pragma mark -
#pragma mark GADRewardBasedVideoAdDelegate implementation

// Sent when an interstitial ad request succeeded.  Show it at the next
// transition point in your application such as when transitioning between view
// controllers.
// onAdLoaded
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    if (adMobAds.rewardedView) {
        [adMobAds onRewardedAd:rewarded rewardedListener:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdLoaded, { 'adType' : 'rewarded' }); }, 1);"];
        }];
    }
}
- (void)rewardedDidFailedToShow:(GADRewardBasedVideoAd *) rewarded {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'rewarded', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          0,
                                          @"Advertising tracking may be disabled. To get test ads on this device, enable advertising tracking."]];
    }];
    
}

// Sent when an interstitial ad request completed without an interstitial to
// show.  This is common since interstitials are shown sparingly to users.
// onAdFailedToLoad
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s: Failed to receive ad with error: %@",
          __PRETTY_FUNCTION__, [error localizedFailureReason]);
    adMobAds.isRewardedAvailable = false;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
        @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdFailedToLoad, "
        @"{ 'adType' : 'rewarded', 'error': %ld, 'reason': '%@' }); }, 1);";
        [adMobAds.commandDelegate evalJs:[NSString stringWithFormat:jsString,
                                          (long)error.code,
                                          [self __getErrorReason:error.code]]];
    }];
    
}

// Sent just before presenting an interstitial.  After this method finishes the
// interstitial will animate onto the screen.  Use this opportunity to stop
// animations and save the state of your application in case the user leaves
// while the interstitial is on screen (e.g. to visit the App Store from a link
// on the interstitial).
// onAdOpened
- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    if (adMobAds.isRewardedAvailable) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdOpened, { 'adType' : 'rewarded' }); }, 1);"];
        }];
        adMobAds.isRewardedAvailable = false;
        self.rewardAmount = 0;
        self.rewardType = "";
    }
}


// Sent just after dismissing an rewarded and it has animated off the screen.
// onAdClosed
- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [adMobAds.commandDelegate evalJs:@"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdClosed, { 'adType' : 'rewarded' }); }, 1);"];
        NSString *jsString =
            [NSString stringWithFormat: 
            @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdClosed, { 'adType' : 'rewarded','rewardType': '%@','rewardAmount': %lf }); }, 1);"
            ,self.rewardType
            ,[self.rewardAmount doubleValue]
            ];
   
    }];
    adMobAds.isRewardedAvailable = false;
    self.rewardAmount = 0;
}


//reward the reward
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
    self.rewardAmount = reward.amount;
   self.rewardType = reward.type;
  
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *jsString =
            [NSString stringWithFormat: 
            @"setTimeout(function (){ cordova.fireDocumentEvent(admob.events.onAdRewarded, { 'adType' : 'rewarded','rewardType': '%@','rewardAmount': %lf }); }, 1);"
            ,reward.type
            ,[reward.amount doubleValue]
            ];
        [adMobAds.commandDelegate evalJs:jsString;
   
    }];
    adMobAds.isRewardedAvailable = false;
}

#pragma mark -
#pragma mark ErrorCodes

- (NSString *) __getErrorReason:(NSInteger) errorCode {
    switch (errorCode) {
        case kGADErrorServerError:
        case kGADErrorOSVersionTooLow:
        case kGADErrorTimeout:
            return @"Internal error";
            break;
            
        case kGADErrorInvalidRequest:
            return @"Invalid request";
            break;
            
        case kGADErrorNetworkError:
            return @"Network Error";
            break;
            
        case kGADErrorNoFill:
            return @"No fill";
            break;
            
        default:
            return @"Unknown";
            break;
    }
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
    adMobAds = nil;
}

@end