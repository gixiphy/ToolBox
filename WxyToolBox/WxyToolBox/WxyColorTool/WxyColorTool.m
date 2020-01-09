//
//  WxyColorTool.m
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/20.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import "WxyColorTool.h"
#import "WxyToolBox.h"

@implementation WxyColorTool

#pragma mark 隨機取色
+ (UIColor *)xyRainbowColor {
    return [UIColor colorWithDisplayP3Red:((double)arc4random()/UINT32_MAX)
                                    green:((double)arc4random()/UINT32_MAX)
                                     blue:((double)arc4random()/UINT32_MAX)
                                    alpha:0.1+arc4random_uniform(10)*0.1];;
}

#pragma mark 十六進位值轉換UIColor
+ (UIColor *)xyColorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if ([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    return [UIColor colorWithDisplayP3Red:red green:green blue:blue alpha:alpha];
}

@end
