//
//  WxyShareTool.m
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/20.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import "WxyShareTool.h"
#import "WxyToolBox.h"

@implementation WxyShareTool

#pragma mark - 分享工具
#pragma mark 使用UIActivityViewController
+ (void)xyShareWithActivityItems:(NSArray *)activityItems
            applicationActivities:(NSArray *)activities
            excludedActivityTypes:(NSArray *)excludedActivityTypes
                        CallBlock:(void (^)(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError))block {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:activities];
    activityVC.excludedActivityTypes = excludedActivityTypes;
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        block(activityType,completed,returnedItems,activityError);
    };
    UIViewController *vc = [WxySystemTool xyGetViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityVC.popoverPresentationController.sourceView = vc.view;
    }
    [vc presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark 使用SLComposeViewController
+ (void)xyShareWithShareToolType:(ShareToolType)type
                      ServiceType:(NSString *)serviceType
                    ActivityItems:(NSArray *)activityItems
                        CallBlock:(void (^)(SLComposeViewControllerResult result))block {
    NSString *postServiceType = [self serviceTypeWithType:type] ? : serviceType;
    if (![SLComposeViewController isAvailableForServiceType:postServiceType]) {
        return;
    }
    SLComposeViewController *composeVc = [SLComposeViewController composeViewControllerForServiceType:postServiceType];
    for ( id obj in activityItems){
        if ([obj isKindOfClass:[UIImage class]]) {
            [composeVc addImage:(UIImage *)obj];
        }
        else if ([obj isKindOfClass:[NSURL class]]) {
            [composeVc addURL:(NSURL *)obj];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            [composeVc setInitialText:(NSString *)obj];
        }
    }
    composeVc.completionHandler = ^(SLComposeViewControllerResult result) {
        block(result);
    };
    UIViewController *vc = [WxySystemTool xyGetViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        composeVc.popoverPresentationController.sourceView = vc.view;
    }
    [vc presentViewController:composeVc animated:YES completion:nil];
}

+ (NSString *)serviceTypeWithType:(ShareToolType)type{
    NSString * serviceType;
    if (type!= 0){
        switch (type){
            case ShareToolTypeWeChat:
                serviceType = @"com.tencent.xin.sharetimeline";
                break;
            case ShareToolTypeQQ:
                serviceType = @"com.tencent.mqq.ShareExtension";
                break;
            case ShareToolTypeSinaWeibo:
                serviceType = @"com.apple.share.SinaWeibo.post";
                break;
            case ShareToolTypeTencentWeibo:
                serviceType = @"com.apple.share.TencentWeibo.post";
                break;
            case ShareToolTypeFacebook:
                serviceType = @"com.apple.share.Facebook.post";
                break;
            case ShareToolTypeVimeo:
                serviceType = @"com.apple.share.Vimeo.post";
                break;
            case ShareToolTypeTwitter:
                serviceType = @"com.apple.share.Twitter.post";
                break;
            case ShareToolTypeFlickr:
                serviceType = @"com.apple.share.Flickr.post";
                break;
            default:
                break;
        }
    }
    return serviceType;
}
@end
