//
//  WxyUIScreenTool.m
//  punchInOut
//
//  Created by willy.wu on 2019/5/10.
//  Copyright © 2019 吳憲有. All rights reserved.
//

#import "WxyUIScreenTool.h"
#import "WxyToolBox.h"

@implementation WxyUIScreenTool

#pragma mark 檢查螢幕尺寸
+ (InchScreenType)xyIsInchScreenTypeWithDeviceModel {
    NSString *machine = [WxySystemTool xyDeviceModel];
    NSArray *InchScreen65s = @[@"iPhone11,6",@"iPhone11,4"];
    NSArray *InchScreen61s = @[@"iPhone11,8"];
    NSArray *InchScreen58s = @[@"iPhone10,3",@"iPhone10,6",@"iPhone11,2"];
    NSArray *InchScreen55s = @[@"iPhone7,2",@"iPhone8,1",@"iPhone9,1",@"iPhone9,3",@"iPhone10,1",@"iPhone10,4"];
    NSArray *InchScreen47s = @[@"iPhone7,1",@"iPhone8,2",@"iPhone9,2",@"iPhone9,4",@"iPhone10,2",@"iPhone10,5"];
    NSArray *InchScreen40s = @[@"iPhone5,1",@"iPhone5,2",@"iPhone5,3",@"iPhone5,4",@"iPhone6,1",@"iPhone6,2",@"iPhone8,4"];
    NSArray *InchScreen35s = @[@"iPhone1,1",@"iPhone1,2",@"iPhone2,1",@"iPhone3,1",@"iPhone3,2",@"iPhone3,3",@"iPhone4,1"];
    NSArray *InchScreen129s = @[@"iPad6,7",@"iPad6,8",@"iPad7,1",@"iPad7,2",@"iPad8,5",@"iPad8,6",@"iPad8,7",@"iPad8,8"];
    NSArray *InchScreen111s = @[@"iPad8,1",@"iPad8,2",@"iPad8,3",@"iPad8,4"];
    NSArray *InchScreen105s = @[@"iPad7,3",@"iPad7,4",@"iPad11,3",@"iPad11,4"];
    NSArray *InchScreen97s = @[@"iPad1,1",@"iPad2,1",@"iPad2,2",@"iPad2,3",@"iPad2,4",@"iPad3,1",@"iPad3,2",@"iPad3,3",@"iPad3,4",@"iPad3,5",@"iPad3,6",@"iPad4,1",@"iPad4,2",@"iPad4,3",@"iPad5,3",@"iPad5,4",@"iPad6,3",@"iPad6,4",@"iPad6,11",@"iPad6,12",@"iPad7,5",@"iPad7,6"];
    NSArray *InchScreen79s = @[@"iPad2,5",@"iPad2,6",@"iPad2,7",@"iPad4,4",@"iPad4,5",@"iPad4,6",@"iPad4,7",@"iPad4,8",@"iPad4,9",@"iPad5,1",@"iPad5,2",@"iPad11,1",@"iPad11,2"];
    InchScreenType inchScreenType = InchScreenUnknown;
    if ([machine hasPrefix:@"iPhone"]) {
        if ([InchScreen65s containsObject:machine]) {
            inchScreenType = InchScreen65;
        }
        else if ([InchScreen61s containsObject:machine]) {
            inchScreenType = InchScreen61;
        }
        else if ([InchScreen58s containsObject:machine]) {
            inchScreenType = InchScreen58;
        }
        else if ([InchScreen55s containsObject:machine]) {
            inchScreenType = InchScreen55;
        }
        else if ([InchScreen47s containsObject:machine]) {
            inchScreenType = InchScreen47;
        }
        else if ([InchScreen40s containsObject:machine]) {
            inchScreenType = InchScreen40;
        }
        else if ([InchScreen35s containsObject:machine]) {
            inchScreenType = InchScreen35;
        }
    }
    else {
        if ([InchScreen129s containsObject:machine]) {
            inchScreenType = InchScreen129;
        }
        else if ([InchScreen111s containsObject:machine]) {
            inchScreenType = InchScreen111;
        }
        else if ([InchScreen105s containsObject:machine]) {
            inchScreenType = InchScreen105;
        }
        else if ([InchScreen97s containsObject:machine]) {
            inchScreenType = InchScreen97;
        }
        else if ([InchScreen79s containsObject:machine]) {
            inchScreenType = InchScreen79;
        }
    }
    return inchScreenType;
}

+ (InchScreenType)xyIsInchScreenTypeWithUIScreen {
    CGSize screenSizeForDevice = CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT);
    CGSize screenSizeFor61or65Inch = CGSizeMake(414, 896);
    CGSize screenSizeFor58Inch = CGSizeMake(375, 812);
    CGSize screenSizeFor55Inch = CGSizeMake(414, 736);
    CGSize screenSizeFor47Inch = CGSizeMake(375, 667);
    CGSize screenSizeFor40Inch = CGSizeMake(320, 568);
    CGSize screenSizeFor35Inch = CGSizeMake(320, 480);
    CGSize screenSizeFor129Inch = CGSizeMake(1024, 1366);
    CGSize screenSizeFor111Inch = CGSizeMake(834, 1194);
    CGSize screenSizeFor105Inch = CGSizeMake(834, 1112);
    CGSize screenSizeFor79or97Inch = CGSizeMake(768, 1024);
    InchScreenType inchScreenType = InchScreenUnknown;
    if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor61or65Inch)) {
        inchScreenType = InchScreen61or65;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor58Inch)) {
        inchScreenType = InchScreen58;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor55Inch)) {
        inchScreenType = InchScreen55;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor47Inch)) {
        inchScreenType = InchScreen47;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor40Inch)) {
        inchScreenType = InchScreen40;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor35Inch)) {
        inchScreenType = InchScreen35;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor129Inch)) {
        inchScreenType = InchScreen129;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor111Inch)) {
        inchScreenType = InchScreen111;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor105Inch)) {
        inchScreenType = InchScreen105;
    }
    else if (CGSizeEqualToSize(screenSizeForDevice, screenSizeFor79or97Inch)) {
        inchScreenType = InchScreen79or97;
    }
    return inchScreenType;
}

+ (InchScreenType)xyIsInchScreenType {
    InchScreenType inchScreenType = InchScreenUnknown;
    InchScreenType inchScreenTypeForUIScreen = [self xyIsInchScreenTypeWithUIScreen];
    InchScreenType inchScreenTypeForDeviceModel = [self xyIsInchScreenTypeWithDeviceModel];
    if (inchScreenTypeForDeviceModel == inchScreenTypeForUIScreen) {
        inchScreenType = inchScreenTypeForDeviceModel;
    }
    else if (inchScreenTypeForUIScreen == InchScreen61or65 && inchScreenTypeForDeviceModel != InchScreenUnknown) {
        inchScreenType = inchScreenTypeForDeviceModel;
    }
    else if (inchScreenTypeForUIScreen == InchScreen79or97 && inchScreenTypeForDeviceModel != InchScreenUnknown) {
        inchScreenType = inchScreenTypeForDeviceModel;
    }
    else {
        inchScreenType = inchScreenTypeForUIScreen;
    }
    return inchScreenType;
}

#pragma mark 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
+ (BOOL)xyIsNotchedScreen {
    InchScreenType inchScreenType = [self xyIsInchScreenType];
    BOOL isNotchedScreen =  inchScreenType == InchScreen58 ||
                            inchScreenType == InchScreen61 ||
                            inchScreenType == InchScreen65 ||
                            inchScreenType == InchScreen61or65;
    return isNotchedScreen;
}

@end
