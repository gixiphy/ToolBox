//
//  WxyNetworkTool.h
//  punchInOut
//
//  Created by 吳憲有 on 2019/1/21.
//  Copyright © 2019 吳憲有. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/utsname.h>
#include <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/stat.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AddressBook/AddressBook.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#import "Reachability.h"
#import "SimplePing.h"

NS_ASSUME_NONNULL_BEGIN

#define FailureTimeMax      2
#define HostName            @"www.apple.com"

#define TimeoutInterval     30
#define MemoryCapacity      40
#define DiskCapacity        200

@class  WxyNetworkInfo,WxyUploadDataInfo;

/**
 網路狀態

 - NetWorkStatusNotReachable: 網路不可用
 - NetWorkStatusUnknown: 未知網路
 - NetWorkStatusWWAN2G: 2G
 - NetWorkStatusWWAN3G: 3G
 - NetWorkStatusWWAN4G: 4G
 - NetWorkStatusWiFi: WiFi
 */
typedef NS_ENUM(NSUInteger, NetWorkStatus) {
    NetWorkStatusNotReachable = 0,
    NetWorkStatusUnknown = 1,
    NetWorkStatusWWAN2G = 2,
    NetWorkStatusWWAN3G = 3,
    NetWorkStatusWWAN4G = 4,
    
    NetWorkStatusWiFi = 9,
};

/**
 網路資料傳遞方式

 - GET: GET
 - POST: POST
 - PUT: PUT
 - PATCH: PATCH
 - DELETE: DELETE
 */
typedef NS_ENUM(NSUInteger, NetworkType) {
    GET = 0,
    POST,
    PUT,
    PATCH,
    DELETE
};

@interface WxyNetworkTool : NSObject

#pragma mark - 取得wifi路由器資訊 <在iOS 12+中使用此方法需要在Xcode中為應用授權獲取WiFi信息的能力。授權後，Xcode會自動在App ID和應用的權限列表中增加獲取WiFi信息的權限。>
/**
 取得wifi路由器資訊

 @return wifi路由器資訊
 */
+ (NSDictionary *)xyWiFiNetworkInfo;

/**
 取得wifi SSID
 
 @return wifi SSID
 */
+ (NSString *)xyWiFiSSID;

/**
 取得wifi Mac Address[BSSID]
 
 @return wifi Mac Address[BSSID]
 */
+ (NSString *)xyWiFiMacAddress;

#pragma mark - IP資訊
/**
 IP Info

 @return IP Info
 */
+ (NSDictionary *)xyIPInfo;

/**
 IP Address

 @return IP Address
 */
+ (NSString *)xyIPAddress;

/**
 檢查是否符合IP格式

 @param ipAddress ipAddress
 @return 是否符合IP格式
 */
+ (BOOL)xyIsValidatIP:(NSString *)ipAddress;
#pragma mark - 網路檢查
/**
 網路狀態

 @return 網路狀態
 */
+ (NetWorkStatus)xyNetworkStatus;

/**
 是否聯網「僅判斷NetworkStatus!=NotReachabl，不代表可以聯通網路」

 @return 是否聯網
 */
+ (BOOL)xyNetworkOnline;

/**
 網路狀態監聽檢查

 @param hostName 自定義地址："www.apple.com"
 @param completionHandler BOOL isOnLine,NetWorkStatus curStatus
 */
+ (void)xyNetworkStatusWithHostName:(NSString *)hostName
                   completionHandler:(void (^)(BOOL isOnLine,NetWorkStatus curStatus))completionHandler;

/**
 網路狀態監聽檢查

 @param completionHandler BOOL isOnLine,NetworkStatus curStatus
 */
+ (void)xyNetworkStatus:(void (^)(BOOL isOnLine,NetWorkStatus curStatus))completionHandler;

#pragma mark - 網路請求
/**
 把NSDictionary解析成post格式的NSString字符串

 @param params 傳送數據字典
 @param encode 是否使用encode
 @return post格式的NSString
 */
+ (NSString *)xyParseParams:(NSDictionary *)params
                   URLEncode:(BOOL)encode;

/**
 把NSDictionary解析成json格式的NSString字符串
 
 @param params 傳送數據字典
 @return json格式的NSString
 */
+ (NSString *)xyJSONParams:(NSDictionary *)params;

/**
 異步網路資料請求封裝函數(NSURLSession)
 
 @param type 網路資料傳遞方式
 @param URL 請求URL
 @param params post參數
 @param block void (^)(NSData *data, NSURLResponse *response, NSError *error)
 */
+ (void)xyNetworkDataTransType:(NetworkType)type
                            URL:(NSString *)URL
                  RequestParams:(NSDictionary *)params
                    FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

/**
 異步GET封裝函數(NSURLSession)
 
 @param URL 請求URL
 @param params GET參數
 @param block void (^)(NSData *data, NSURLResponse *response, NSError *error)
 */
+ (void)xyGet:(NSString *)URL RequestParams:(NSDictionary *)params
   FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

/**
 異步POST封裝函數(NSURLSession)
 
 @param URL 請求URL
 @param params post參數
 @param block void (^)(NSData *data, NSURLResponse *response, NSError *error)
 */
+ (void)xyPost:(NSString *)URL RequestParams:(NSDictionary *)params
    FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

#pragma mark - 下載請求
/**
 下載（緩存機制)

 @param url 請求URL
 @param completion void (^)(NSData *data, NSError *error)
 */
+ (void)xyDownloadWithURLCache:(NSString *)url
                   onCompletion:(void (^)(NSData *data, NSError *error))completion;

/**
 下載（存入本機)

 @param URL 請求URL
 @param fileName 自定義存檔名，默認為下載檔案名稱
 @param fullPath 自定義存擋路徑，默認路徑為Documents/Downloads
 @param block void (^)(NSString *fileName, NSString *fullPath, NSError *error)
 */
+ (void)xyDownloadTaskWithURL:(NSString *)URL
                    FolderName:(NSString *)fileName
                      FullPath:(NSString *)fullPath
                   FinishBlock:(void (^)(NSString *fileName, NSString *fullPath, NSError *error))block;

#pragma mark - 上傳請求
/**
 上傳請求

 @param URL 請求URL
 @param files 上傳專用物件
 @param params post參數
 @param block void (^)(NSData *data, NSURLResponse *response, NSError *error)
 */
+ (void)xyUploadFilesWithURL:(NSString *)URL
                      FileArr:(NSMutableArray<WxyUploadDataInfo *>*)files
                RequestParams:(NSDictionary *)params
                  FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block;

@end

/**======= WxyNetworkInfo 網路狀態 ========*/
@interface WxyNetworkInfo : NSObject

/**
 host
 */
@property (nonatomic,copy) NSString *hostName;

/**
 網路狀態
 */
@property (nonatomic,assign) NetWorkStatus networkStatus;

/**
 網路是否聯通
 */
@property (nonatomic,assign) BOOL isOnline;

@end

/**======= WxyUploadDataInfo 上傳檔案用物件。支援NSString,NSURL「檔案路徑」(建議使用)，UIImage「自動轉成jpg格式，UUID命名，壓縮率0.5」，NSData「需命名檔案名稱 ***.***」 ========*/
@interface WxyUploadDataInfo : NSObject

/**
 服務器接收文件的字段名,開發中由服務器那邊提供
 */
@property (nonatomic,copy) NSString *key;

/**
 檔案名稱
 */
@property (nonatomic,copy) NSString *fileName;

/**
 檔案數據
 */
@property (nonatomic,copy) NSData *data;

/**
 上傳檔案用物件

 @param key 服務器接收文件的字段名,服務器提供
 @param fileName 自定義檔案名稱「檔案名稱.附檔名」
 @param file 上傳檔案：支援NSString,NSURL「檔案路徑」(建議使用)，UIImage「自動轉成jpg格式，UUID命名，壓縮率0.5」，NSData「需命名檔案名稱 ***.***」
 @return 上傳檔案用物件
 */
+ (instancetype)initWithKey:(NSString *)key
                   FileName:(NSString *)fileName
                       File:(id)file;

@end

NS_ASSUME_NONNULL_END
