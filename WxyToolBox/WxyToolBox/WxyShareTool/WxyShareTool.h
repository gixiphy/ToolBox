//
//  WxyShareTool.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/20.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>

/**
 分享功能
 
 - ShareToolTypeOthers: 其他
 - ShareToolTypeWeChat: 微信
 - ShareToolTypeQQ: 腾讯QQ
 - ShareToolTypeTencentWeibo: 腾讯微博
 - ShareToolTypeSinaWeibo: 新浪微博
 - ShareToolTypeFacebook: Facebook
 - ShareToolTypeVimeo: Vimeo
 - ShareToolTypeTwitter: Twitter
 - ShareToolTypeFlickr: Flickr
 */
typedef NS_ENUM(NSInteger, ShareToolType) {
    ShareToolTypeOthers,
    ShareToolTypeWeChat,
    ShareToolTypeQQ,
    ShareToolTypeTencentWeibo,
    ShareToolTypeSinaWeibo,
    ShareToolTypeFacebook,
    ShareToolTypeVimeo,
    ShareToolTypeTwitter,
    ShareToolTypeFlickr,
};

NS_ASSUME_NONNULL_BEGIN

@interface WxyShareTool : NSObject
#pragma mark - 分享工具
/**
 使用UIActivityViewController
 
 @param activityItems 分享內容
 @param activities 自定義UIActivity對象
 @param excludedActivityTypes 不顯示哪些分享平台
 UIActivityTypePostToFacebook,
 UIActivityTypePostToTwitter,
 UIActivityTypePostToWeibo,//新浪微博
 UIActivityTypeMessage,//信息
 UIActivityTypeMail,
 UIActivityTypePrint,//打印
 UIActivityTypeCopyToPasteboard,//拷貝
 UIActivityTypeAssignToContact,//指定聯繫人
 UIActivityTypeSaveToCameraRoll,//保存到相機膠卷
 UIActivityTypeAddToReadingList,//加入閱讀列表
 UIActivityTypePostToFlickr,
 UIActivityTypePostToVimeo,
 UIActivityTypePostToTencentWeibo,//騰訊微博
 UIActivityTypeAirDrop,
 UIActivityTypeOpenInIBooks,
 
 @param block UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError
 */
+ (void)xyShareWithActivityItems:(NSArray *)activityItems
            applicationActivities:(NSArray *)activities
            excludedActivityTypes:(NSArray *)excludedActivityTypes
                        CallBlock:(void (^)(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError))block;
/**
使用SLComposeViewController

@param type 分享功能
@param serviceType 自定義分享APP
@param activityItems 分享內容
@param block SLComposeViewControllerResult result
*/
+ (void)xyShareWithShareToolType:(ShareToolType)type
                      ServiceType:(NSString *)serviceType
                    ActivityItems:(NSArray *)activityItems
                        CallBlock:(void (^)(SLComposeViewControllerResult result))block;
@end

NS_ASSUME_NONNULL_END
