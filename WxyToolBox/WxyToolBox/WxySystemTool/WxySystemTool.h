//
//  WxySystemTool.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/16.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import <StoreKit/StoreKit.h>                   //App Store 内部直接評分

/**
 沙盒位置
 
 - Root: 根目錄
 - Documents: 保存應用運行時生成的需要持久化的數據，iTunes會自動備份該目錄。
 - Libaray: 存儲程序的默認設置和其他狀態信息，iTunes會自動備份該目錄。
 - Caches: 存放緩存文件，iTunes不會備份此目錄，此目錄下文件不會在應用退出刪除，一般存放體積比較大，不是很重要的資源。
 - Preferences: 保存應用的所有偏好設置，ios的Settings（設置）應用會在該目錄中查找應用的設置信息，iTunes會自動備份該目錄。
 - Tmp: 保存應用運行時所需的臨時數據，使用完畢後再將相應的文件從該目錄刪除，應用沒有運行時，系統也可能會自動清理該目錄下的文件，iTunes不會同步該目錄，iPhone重啟時該目錄下的文件會丟失。
 */
typedef NS_ENUM(NSInteger, SandBoxs) {
    Root = 0,
    Documents,
    Libaray,
    Caches,
    Preferences,
    Tmp,
};

NS_ASSUME_NONNULL_BEGIN

@interface WxySystemTool : NSObject

#pragma mark - 獲取系統UUID(使用KeyChain記錄)
/**
  獲取系統UUID(使用KeyChain記錄)

 @return  UUID(
 */
+ (NSString *)xyGetDeviceUUID;

#pragma mark - 設備型號
/**
 設備型號
 
 @return 設備型號
 */
+ (NSString *)xyDeviceModel;

#pragma mark - 判斷是否為可NFC執行設備
/**
 判斷是否為可NFC執行設備
 
 @return 判斷是否為可NFC執行設備
 */
+ (BOOL)xyIsNFCWorking;

#pragma mark - 檔案存取類
/**
 *  取得應用沙盒位置:0.Root;1.Documents;2.Libaray;3.Caches;4.Preferences;5.Tmp;
 *
 *  @param key      文件目錄選擇
 *  @param fileName 文件資料夾名稱
 *  @return 應用沙盒文件目錄位置
 */
+ (NSString *)xyGetSandBox:(SandBoxs)key
                   FileName:(NSString *)fileName;

/**
 *  建立檔案路經:0.Root;1.Documents;2.Libaray;3.Caches;4.Preferences;5.Tmp;
 *
 *  @param fileName     檔案名稱
 *  @param FilePathName 文件資料夾名稱
 *  @param key          文件目錄選擇參數
 *
 *  @return 建立檔案路經
 */
+ (NSString *)xySetFileName:(NSString *)fileName
                saveFilePath:(NSString *)FilePathName
             saveFilePathKey:(SandBoxs)key;

/**
 *  檢查檔案存在
 *
 *  @param filePath 檢查檔案路徑
 *
 *  @return         是否存在
 */
+ (BOOL)xyCheckingFile:(NSString *)filePath;

/**
 *  刪除檔案
 *
 *  @param filePath 刪除檔案路徑
 */
+ (void)xyDeleteFile:(NSString *)filePath;

#pragma mark - NSUserDefaults存取類
/**
 *  將變量存至NSUserDefaults
 *
 *  @param value 儲存變量
 *  @param key   儲存變量名
 */
+ (void)xySaveNSUserDefaults:(id)value
                          Key:(NSString *)key;

/**
 *  從NSUserDefaults讀取變量
 *
 *  @param key 讀取變量名
 *
 *  @return 讀取變量
 */
+ (id)xyReadNSUserDefaults:(NSString *)key;

/**
 從NSUserDefaults刪除資料
 
 @param key 刪除變量名
 */
+ (void)xyDeleteNSUserDefaults:(NSString *)key;

/**
 判斷NSUserDefaults 某個key值是否存
 
 @param key 判斷變量名
 @return 是否存
 */
+ (BOOL)xyDetermineNSUserDefaultExist:(NSString *)key;

/**
 刪除所有NSUserDefaults
 */
+ (void)xyRemoveAllDefaultData;

#pragma mark - 獲取當前ViewController
/**
 獲取當前ViewController
 方法出處：XHTeng/XHCryptorTools https://github.com/gitkong/NSObject-UIViewController
 @return 當前ViewController
 */
+ (UIViewController *)xyGetViewController;

#pragma mark - 打開SFSafariViewController
/**
 打開SFSafariViewController
 
 @param url 網址
 */
+ (void)xyPushSFSafariViewController:(NSURL *)url;

#pragma mark - 返回上一頁
/**
 返回上一頁
 */
+ (void)xyBackPreviouPageView;

#pragma mark - 跳轉系統頁面
/**
 跳轉系統頁面
 */
+ (void)xyGoGeneral;

#pragma mark - app内部直接评分
/**
 app内部直接评分
 */
+ (void)xyShowAppStoreScore;

@end

NS_ASSUME_NONNULL_END
