//
//  WxyUIScreenTool.h
//  punchInOut
//
//  Created by willy.wu on 2019/5/10.
//  Copyright © 2019 吳憲有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 螢幕尺寸

 - InchScreenUnknown: 未知
 - InchScreen35: 3.5'
 - InchScreen40: 4.0'
 - InchScreen47: 4.7'
 - InchScreen55: 5.5'
 - InchScreen79: 7.9
 - InchScreen97: 9.7'
 - InchScreen79or97: 7.9' or 9.7'
 - InchScreen105: 10.5'
 - InchScreen111: 11.1'
 - InchScreen129: 12.9'
 - InchScreen58: 5.8'
 - InchScreen61: 6.1'
 - InchScreen65: 6.5'
 - InchScreen61or65: 6.1' or 6.5'
 */
typedef NS_ENUM(NSInteger) {
    InchScreenUnknown,
    InchScreen35,
    InchScreen40,
    InchScreen47,
    InchScreen55,
    InchScreen79,
    InchScreen97,
    InchScreen79or97,
    InchScreen105,
    InchScreen111,
    InchScreen129,
    InchScreen58,
    InchScreen61,
    InchScreen65,
    InchScreen61or65,
} InchScreenType;

@interface WxyUIScreenTool : NSObject

#pragma mark 檢查螢幕尺寸
/**
 檢查螢幕尺寸（設備型號）

 @return 檢查螢幕尺寸
 */
+ (InchScreenType)xyIsInchScreenTypeWithDeviceModel;

/**
 檢查螢幕尺寸（設備尺寸）
 
 @return 檢查螢幕尺寸
 */
+ (InchScreenType)xyIsInchScreenTypeWithUIScreen;

/**
 檢查螢幕尺寸（設備型號＋設備尺寸）
 
 @return 檢查螢幕尺寸
 */
+ (InchScreenType)xyIsInchScreenType;

#pragma mark 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
/**
 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备

 @return 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
 */
+ (BOOL)xyIsNotchedScreen;

@end

NS_ASSUME_NONNULL_END
