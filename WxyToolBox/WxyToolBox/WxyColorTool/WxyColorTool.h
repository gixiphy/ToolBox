//
//  WxyColorTool.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/20.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WxyColorTool : NSObject

//隨機取色
+ (UIColor *)xyRainbowColor;

/**
十六進位值轉換UIColor

@param hexString 色票
*/
+ (UIColor *)xyColorFromHexString:(NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
