//
//  WxyToolBox.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/16.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WxyNetworkTool.h"
#import "WxyUIScreenTool.h"
#import "WxySystemTool.h"
#import "WxyShareTool.h"
#import "WxyColorTool.h"
#import "WxyCryptorTool.h"
#import "WxyStringTool.h"

NS_ASSUME_NONNULL_BEGIN

//獲取系統對象
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

//-------------------獲取屏幕寬高-------------------------
#define kScreen_Bounds [UIScreen mainScreen].bounds
//是否橫豎屏，用戶界面橫屏了才會返回YES
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([kApplication statusBarOrientation])
//無論支不支持橫屏，只要設備橫屏了，就會返回YES
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([kApplication orientation])
//屏幕寬度，會根據橫豎屏的變化而變化
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//屏幕高度，會根據橫豎屏的變化而變化
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
//屏幕寬度，跟橫豎屏無關
#define DEVICE_WIDTH (IS_LANDSCAPE ? SCREEN_HEIGHT : SCREEN_WIDTH)
//屏幕高度，跟橫豎屏無關
#define DEVICE_HEIGHT (IS_LANDSCAPE ? SCREEN_WIDTH :SCREEN_HEIGHT)

//-------------------根據ip6的屏幕佈局-------------------------
#define Iphone6ScaleWidth DEVICE_WIDTH/375.0
#define Iphone6ScaleHeight DEVICE_HEIGHT/667.0
//根據ip6的屏幕來拉伸
#define kRealValue(with) ((with)*Iphone6ScaleWidth)

//強弱引用
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;

///IOS 版本判斷
#define IOSAVAILABLEVERSION(version) ([[UIDevice currentDevice] availableVersion:version] < 0)
// 當前系統版本
#define CurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
//當前語言
#define CurrentLanguage ([[NSLocale preferredLanguages] firstObject])

//-------------------打印日誌-------------------------
//DEBUG 模式下打印日誌,當前行
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

//字體
#define BOLDSYSTEMFONT(FONTSIZE)[UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)    [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME, FONTSIZE)    [UIFont fontWithName:(NAME) size:(FONTSIZE)]

//隨機取色
#define kRandomColor [WxyColorTool xyRainbowColor]

//十六進位值轉換UIColor
#define KColorChart(hex) [WxyColorTool xyColorFromHexString:hex]

//數據驗證
#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define SafeStr(f) (StrValid(f) ? f:@"")
#define HasString(str,key) ([str rangeOfString:key].location!=NSNotFound)

#define ValidStr(f) StrValid(f)
#define ValidDict(f) (f!=nil && [f isKindOfClass:[NSDictionary class]])
#define ValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define ValidNum(f) (f!=nil && [f isKindOfClass:[NSNumber class]])
#define ValidClass(f,cls) (f!=nil && [f isKindOfClass:[cls class]])
#define ValidData(f) (f!=nil && [f isKindOfClass:[NSData class]])

//獲取一段時間間隔
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTime  NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)

//打印當前方法名
#define ITTDPRINTMETHODNAME() ITTDPRINT(@"%s", __PRETTY_FUNCTION__)

//發送通知
#define KPostNotification(name,obj) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];

@interface WxyToolBox : NSObject

@end

NS_ASSUME_NONNULL_END
