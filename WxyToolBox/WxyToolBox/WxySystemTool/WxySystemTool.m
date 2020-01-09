//
//  WxySystemTool.m
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/16.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import "WxySystemTool.h"
#import "WxyToolBox.h"

@implementation WxySystemTool

#pragma mark 獲取系統UUID(使用KeyChain記錄)
+ (NSString *)xyGetDeviceUUID {
    NSString *UUID = [self readKeyChain];
    if (UUID) {
        return UUID;
    }
    else {
        UUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        [self saveKeyChain:UUID];
        return UUID;
    }
}

#pragma mark 設備型號
+ (NSString *)xyDeviceModel {
#if TARGET_OS_SIMULATOR
    // Simulator doesn't return the identifier for the actual physical model, but returns it as an environment variable
    return [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
#else
    // See https://www.theiphonewiki.com/wiki/Models for identifiers
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
#endif
}

#pragma mark 判斷是否為可NFC執行設備
+ (BOOL)xyIsNFCWorking {
    NSString *deviceModel = [self xyDeviceModel];;
    deviceModel = [deviceModel stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if ([deviceModel hasPrefix:@"iPhone"]) {
        deviceModel = [deviceModel stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        return (deviceModel.floatValue > 9.0);
    }
    else {
        return NO;
    }
}

#pragma mark - 檔案存取類
#pragma 取得應用沙盒位置
+ (NSString *)xyGetSandBox:(SandBoxs)key
                   FileName:(NSString *)fileName {
    NSString *sandBox = nil;
    NSArray *arry = nil;
    switch (key) {
        case Root:
            sandBox = NSHomeDirectory();
            break;
        case Documents:
            arry = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            sandBox = [arry lastObject];
            break;
        case Libaray:
            arry = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
            sandBox = [arry lastObject];
            break;
        case Caches:
            arry = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
            sandBox = [arry lastObject];
            break;
        case Preferences:
            arry = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            sandBox = [[arry lastObject] stringByAppendingPathComponent:@"Preferences"];
            break;
        case Tmp:
            sandBox = NSTemporaryDirectory();
            break;
        default:
            break;
    }
    if (fileName.length > 0) {
        // 创建数据库目录
        NSString *dirPath = [sandBox stringByAppendingPathComponent:fileName];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        BOOL isCreated = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
        if ((isCreated == NO) || (isDir == NO)) {
            NSError* error = nil;
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
            NSDictionary* attributes = @{ NSFileProtectionKey : NSFileProtectionNone };
#else
            NSDictionary* attributes = nil;
#endif
            BOOL success = [fileManager createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:attributes
                                                        error:&error];
            if (success) {
                NSLog(@"dirPath:%@",dirPath);
                return dirPath;
            }
            else {
                NSLog(@"sandBox:%@",sandBox);
                return sandBox;
            }
        }
        else {
            NSLog(@"dirPath:%@",dirPath);
            return dirPath;
        }
    }
    else {
        NSLog(@"sandBox:%@",sandBox);
        return sandBox;
    }
}

#pragma mark 建立檔案路經
+ (NSString *)xySetFileName:(NSString *)fileName
                saveFilePath:(NSString *)FilePathName
             saveFilePathKey:(SandBoxs)key {
    return [[self xyGetSandBox:key FileName:FilePathName] stringByAppendingPathComponent:fileName];
}

#pragma mark 檢查檔案存在
+ (BOOL)xyCheckingFile:(NSString *)filePath {
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath: filePath];
}
#pragma mark 刪除檔案
+ (void)xyDeleteFile:(NSString *)filePath {
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if ([self xyCheckingFile:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

#pragma mark - NSUserDefaults存取類
#pragma mark 將變量存至NSUserDefaults
+ (void)xySaveNSUserDefaults:(id)value
                          Key:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}

#pragma mark 從NSUserDefaults讀取變量
+ (id)xyReadNSUserDefaults:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:key]) {
        return [userDefaults objectForKey:key];
    }
    else {
        return nil;
    }
}

#pragma mark 從NSUserDefaults刪除資料
+ (void)xyDeleteNSUserDefaults:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

#pragma mark 判斷NSUserDefaults 某個key值是否存
+ (BOOL)xyDetermineNSUserDefaultExist:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[[userDefaults dictionaryRepresentation] allKeys] containsObject:key];
}

#pragma mark 刪除所有UserDefault資料
+ (void)xyRemoveAllDefaultData {
    NSUserDefaults *userDefatlut = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatlut dictionaryRepresentation];
    for (NSString* key in [dictionary allKeys]) {
        [userDefatlut removeObjectForKey:key];
        [userDefatlut synchronize];
    }
}

#pragma mark - 獲取當前ViewController
+ (UIViewController *)xyGetViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    // modal
    if (vc.presentedViewController) {
        if ([vc.presentedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navVc = (UINavigationController *)vc.presentedViewController;
            vc = navVc.visibleViewController;
        }
        else if ([vc.presentedViewController isKindOfClass:[UITabBarController class]]){
            UITabBarController *tabVc = (UITabBarController *)vc.presentedViewController;
            if ([tabVc.selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)tabVc.selectedViewController;
                return navVc.visibleViewController;
            }
            else{
                return tabVc.selectedViewController;
            }
        }
        else{
            vc = vc.presentedViewController;
        }
    }
    // push
    else{
        if ([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabVc = (UITabBarController *)vc;
            if ([tabVc.selectedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navVc = (UINavigationController *)tabVc.selectedViewController;
                return navVc.visibleViewController;
            }
            else{
                return tabVc.selectedViewController;
            }
        }
        else if([vc isKindOfClass:[UINavigationController class]]){
            UINavigationController *navVc = (UINavigationController *)vc;
            vc = navVc.visibleViewController;
        }
    }
    return vc;
}

#pragma mark - 打開SFSafariViewController
+ (void)xyPushSFSafariViewController:(NSURL *)url {
    SFSafariViewController *safariView = [[SFSafariViewController alloc]initWithURL:url];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self xyGetViewController] presentViewController:safariView animated:YES completion:nil];
    });
}

#pragma mark - 返回上一頁
+ (void)xyBackPreviouPageView {
    UIViewController *vc = [self xyGetViewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (vc.presentingViewController) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    });
}

#pragma mark - 跳轉系統頁面
+ (void)xyGoGeneral {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString: UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    });
}

#pragma mark - app内部直接评分
+ (void)xyShowAppStoreScore {
    if ([self xyReadNSUserDefaults:@"AppStoreScore"]) {
        NSTimeInterval new = [[NSDate date] timeIntervalSince1970];
        NSNumber *appStoreScore = [self xyReadNSUserDefaults:@"AppStoreScore"];
        if ([SKStoreReviewController respondsToSelector:@selector(requestReview)] && new >= appStoreScore.doubleValue) {
            //防止键盘遮挡
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [SKStoreReviewController requestReview];
            [self setAppStoreScoreMax:365 min:180];
        }
    }
    else {
        [self setAppStoreScoreMax:30 min:7];
    }
}
/**
 設定詢問時間點
 
 @param Max 設定最大詢問天數
 @param min 設定最小詢問天數
 */
+ (void)setAppStoreScoreMax:(int)Max min:(int)min {
    NSDate *date = [NSDate dateWithTimeInterval:arc4random_uniform(60*60*24*Max)+(60*60*24*min) sinceDate:[NSDate date]];
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
    [self xySaveNSUserDefaults:[NSNumber numberWithDouble:timeStamp] Key:@"AppStoreScore"];
}

#pragma mark - KeyChain公用方法
#pragma mark KeyChain使用字典
+ (NSMutableDictionary *)getKeyChainQuery {
    NSString *key = [[NSBundle mainBundle]bundleIdentifier];
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)(kSecClassGenericPassword),kSecClass,
            key, kSecAttrService,
            key, kSecAttrAccount,
            kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
}
#pragma mark UUID寫入KeyChain中
+ (void)saveKeyChain:(id)UUID {
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:UUID requiringSecureCoding:true error:NULL]
                      forKey:(__bridge id<NSCopying>)(kSecValueData)];
    SecItemAdd((__bridge CFDictionaryRef)(keychainQuery), NULL);
}
#pragma mark 從KeyChain讀取UUID
+ (id)readKeyChain {
    id UUID = nil;
    NSMutableDictionary *keychainQuery = [self getKeyChainQuery];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [keychainQuery setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    CFTypeRef result = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, &result) == noErr){
        UUID = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:(__bridge NSData*)result error:NULL];
    }
    return UUID;
}

@end
