//
//  WxyNetworkTool.m
//  punchInOut
//
//  Created by 吳憲有 on 2019/1/21.
//  Copyright © 2019 吳憲有. All rights reserved.
//

#import "WxyNetworkTool.h"
#import "WxyToolBox.h"

NSString *WxyReachabilityChangedNotification = @"WxyNetworkReachabilityChangedNotification";

NSString *kSimplePingChangedNotification = @"kNetworkSimplePingChangedNotification";

@interface WxyNetworkTool()<SimplePingDelegate>

@property (nonatomic,copy) NSString *hostName;

@property (nonatomic,strong) Reachability *hostReachability;

@property (nonatomic,strong) SimplePing *pinger;

@property (nonatomic,assign) BOOL isOnline;

@property (nonatomic,assign) BOOL reachable;

@property (nonatomic,assign) NetworkStatus currentNetworkStatus;

@property (nonatomic,strong) NSMutableArray *failureTimes;

@property (nonatomic,strong) NSTimer *sendTimer;

@end

@implementation WxyNetworkTool

#pragma mark - 初始化
static WxyNetworkTool *share = nil;
+ (instancetype)shareNetworkTool {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[WxyNetworkTool alloc]init];
    });
    return share;
}

- (void)startNotifier {
    [self.hostReachability startNotifier];
    [self.pinger start];
}

- (void)dealloc{
    [self.failureTimes removeAllObjects];
    [self.hostReachability stopNotifier];
    [self.pinger stop];
}

- (Reachability *)hostReachability {
    if (!_hostReachability) {
        self.hostReachability = [Reachability reachabilityWithHostName:self.hostName];
        self.currentNetworkStatus = [self.hostReachability currentReachabilityStatus];
        //註冊通知，異步加載，判斷網絡連接情況
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    }
    return _hostReachability;
}

- (SimplePing *)pinger {
    if (!_pinger) {
        self.pinger = [[SimplePing alloc] initWithHostName:self.hostName];
        self.pinger.addressStyle = SimplePingAddressStyleAny;
        self.pinger.delegate = self;
        //註冊通知，異步加載，判斷網絡連接情況
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kSimplePingChangedNotification object:nil];
    }
    return _pinger;
}

- (NSMutableArray *)failureTimes{
    if (!_failureTimes) {
        self.failureTimes = [NSMutableArray array];
    }
    return _failureTimes;
}

- (void)sendPing {
    [self.pinger sendPingWithData:nil];
}

- (void)stopPing {
    [self.pinger stop];
    [self.sendTimer invalidate];
    self.sendTimer = nil;
}

#pragma mark - SimplePingDelegate
// 解析 HostName 拿到 ip 地址之後，發送封包
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [self sendPing];
    if (self.sendTimer == nil) {
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    }
}

// ping 功能啓動失敗
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    //根據failuretimes判斷是否有網
    self.reachable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingChangedNotification object:nil];
    if (self.failureTimes.count >= FailureTimeMax) {
        [self.failureTimes removeAllObjects];
        [self stopPing];
    }
    else {
        [self.failureTimes addObject:error];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.pinger start];
        });
    }
    
}

// ping 成功發送封包
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    if(sequenceNumber == 0) {//重置
        [self.failureTimes removeAllObjects];
    }
    //根據failuretimes判斷是否有網
    if (self.failureTimes.count >= FailureTimeMax) {
        self.reachable = NO;
        [self.failureTimes removeAllObjects];
        [self stopPing];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingChangedNotification object:nil];
    }
    //將本次記錄加入
    [self.failureTimes addObject:@(sequenceNumber)];
}

// ping 發送封包失敗
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    self.reachable = NO;
    [self.failureTimes removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingChangedNotification object:nil];
}

// ping 發送封包之後收到響應
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    self.reachable = YES;
    [self.failureTimes removeAllObjects];
    [self stopPing];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingChangedNotification object:nil];
}

// ping 接收響應封包發生異常
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    self.reachable = NO;
    [self.failureTimes removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSimplePingChangedNotification object:nil];
}

#pragma mark - ReachabilityDelegate
- (void)reachabilityChanged:(NSNotification *)notification {
    //獲取兩種方法得到的聯網狀態,並轉為BOOL值
    BOOL status1 = [self.hostReachability currentReachabilityStatus];
    BOOL status2 = self.reachable;
    if ((self.currentNetworkStatus != [self.hostReachability currentReachabilityStatus]) && status1) {
        [self.pinger start];
    }
    self.currentNetworkStatus = [self.hostReachability currentReachabilityStatus];
    //綜合判斷網絡,判斷原則:Reachability -> pinger
    self.isOnline = (status1 && status2);
    WxyNetworkInfo *currentNetworkInfo = [WxyNetworkInfo new];
    currentNetworkInfo.hostName = self.hostName;
    currentNetworkInfo.isOnline = self.isOnline;
    currentNetworkInfo.networkStatus = [WxyNetworkTool xyNetworkStatusForFlags:self.currentNetworkStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:WxyReachabilityChangedNotification object:currentNetworkInfo];
}

// 判斷是2G/3G/4G/WiFi
+ (NetWorkStatus)xyNetworkStatusForFlags:(NetworkStatus)flags {
    switch (flags) {
        case NotReachable:
            return NetWorkStatusNotReachable;
            break;
        case ReachableViaWiFi:
            return NetWorkStatusWiFi;
            break;
        case ReachableViaWWAN: {
            NSArray *typeStrings2G = @[CTRadioAccessTechnologyEdge,
                                       CTRadioAccessTechnologyGPRS,
                                       CTRadioAccessTechnologyCDMA1x];
            
            NSArray *typeStrings3G = @[CTRadioAccessTechnologyHSDPA,
                                       CTRadioAccessTechnologyWCDMA,
                                       CTRadioAccessTechnologyHSUPA,
                                       CTRadioAccessTechnologyCDMAEVDORev0,
                                       CTRadioAccessTechnologyCDMAEVDORevA,
                                       CTRadioAccessTechnologyCDMAEVDORevB,
                                       CTRadioAccessTechnologyeHRPD];
            
            NSArray *typeStrings4G = @[CTRadioAccessTechnologyLTE];

            CTTelephonyNetworkInfo *teleInfo= [[CTTelephonyNetworkInfo alloc] init];
            NSString *accessString = teleInfo.currentRadioAccessTechnology;
            if ([typeStrings4G containsObject:accessString]) {
                return NetWorkStatusWWAN4G;
            }
            else if ([typeStrings3G containsObject:accessString]) {
                return NetWorkStatusWWAN3G;
            }
            else if ([typeStrings2G containsObject:accessString]) {
                return NetWorkStatusWWAN2G;
            }
            else {
                return NetWorkStatusUnknown;
            }
        }
            break;
        default:
            return NetWorkStatusNotReachable;
            break;
    }
}

#pragma mark - 取得wifi路由器資訊 <在iOS 12+中使用此方法需要在Xcode中為應用授權獲取WiFi信息的能力。授權後，Xcode會自動在App ID和應用的權限列表中增加獲取WiFi信息的權限。>
+ (NSDictionary *)xyWiFiNetworkInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
    }
    return info;
}

+ (NSString *)xyWiFiSSID {
    NSString *ssid = nil;
    NSDictionary *info = [self xyWiFiNetworkInfo];
    if (info[@"SSID"]) {
        ssid = info[@"SSID"];
    }
    return ssid;
}

+ (NSString *)xyWiFiMacAddress {
    NSString *bssid = nil;
    NSDictionary *info = [self xyWiFiNetworkInfo];
    if (info[@"BSSID"]) {
        bssid = info[@"BSSID"];
    }
    return bssid;
}

#pragma mark - IPAddresses
+ (NSDictionary *)xyIPInfo {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for (interface=interfaces; interface; interface=interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if (addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = @"IPv4";
                    }
                }
                else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = @"IPv6";
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)xyIPAddress {
    NSDictionary *addresses = [self xyIPInfo];
    __block NSString *address;
    NSArray *searchArray = addresses.allKeys;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         //筛选出IP地址格式
         if ([self xyIsValidatIP:address]) *stop = YES;
     }];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)xyIsValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        if (firstMatch) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 網路檢查
+ (NetWorkStatus)xyNetworkStatus {
    WxyNetworkTool *networkTool = [WxyNetworkTool shareNetworkTool];
    networkTool.hostName = HostName;
    return [self xyNetworkStatusForFlags:[networkTool.hostReachability currentReachabilityStatus]];
}

+ (BOOL)xyNetworkOnline {
    WxyNetworkTool *networkTool = [WxyNetworkTool shareNetworkTool];
    networkTool.hostName = HostName;
    return [networkTool.hostReachability currentReachabilityStatus] != NotReachable;
}

+ (void)xyNetworkStatusWithHostName:(NSString *)hostName
                   completionHandler:(void (^)(BOOL isOnLine,NetWorkStatus curStatus))completionHandler {
    WxyNetworkTool *networkTool = [WxyNetworkTool shareNetworkTool];
    networkTool.hostName = hostName;
    [networkTool startNotifier];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:WxyReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            WxyNetworkInfo *networkInfo = note.object;
            completionHandler(networkInfo.isOnline,networkInfo.networkStatus);
        }];
    });
}

+ (void)xyNetworkStatus:(void (^)(BOOL isOnLine,NetWorkStatus curStatus))completionHandler {
    [self xyNetworkStatusWithHostName:HostName completionHandler:completionHandler];
}

#pragma mark - 網路請求
+ (NSString *)xyParseParams:(NSDictionary *)params
                   URLEncode:(BOOL)encode  {
    NSMutableString *result = [NSMutableString new];
    //實例化一個key枚舉器用來存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    NSString *keyValueFormat;
    //urlEncode編碼
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet];
    id key;
    while (key = [keyEnum nextObject]) {
        NSString *value = [params valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            value = encode ? [value stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters] : value;
        }
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&",key,value];
        [result appendString:keyValueFormat];
    }
    return result;
}

+ (NSString *)xyJSONParams:(NSDictionary *)params {
    //解析請求參數，用NSDictionary來存參數，並轉換JSON格式
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *result = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return result;
}

+ (void)xyNetworkDataTransType:(NetworkType)type
                            URL:(NSString *)URL
                  RequestParams:(NSDictionary *)params
                    FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    NSString *methodType;
    switch (type) {
        case GET:
            methodType = @"GET";
            break;
        case POST:
            methodType = @"POST";
            break;
        case PUT:
            methodType = @"PUT";
            break;
        case PATCH:
            methodType = @"PATCH";
            break;
        case DELETE:
            methodType = @"DELETE";
            break;
        default:
            break;
    }
    if (type == GET && params) {
        URL = [NSString stringWithFormat:@"%@?%@",URL,[self xyParseParams:params URLEncode:NO]];
    }
    //處理URL的特殊字元
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:URL];
    //建立請求，設立緩存時間30秒
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:TimeoutInterval];
    if (type > GET) {
        //解析请求参数，把NSDictionary解析成post格式的NSString字符串
        NSString *parseParamsResult = [self xyParseParams:params URLEncode:YES];
        NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPMethod:methodType];
        [request setHTTPBody:postData];
    }
    //使用NSURLSession
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    //建立任務
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:block];
    //開始任務
    [dataTask resume];
}

+ (void)xyGet:(NSString *)URL RequestParams:(NSDictionary *)params
   FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    [self xyNetworkDataTransType:GET URL:URL RequestParams:params FinishBlock:block];
}

+ (void)xyPost:(NSString *)URL RequestParams:(NSDictionary *)params
    FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    [self xyNetworkDataTransType:POST URL:URL RequestParams:params FinishBlock:block];
}

#pragma mark - 下載請求
+ (void)xyDownloadWithURLCache:(NSString *)url
                   onCompletion:(void (^)(NSData *data, NSError *error))completion {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLCache *URLCache =
        [[NSURLCache alloc] initWithMemoryCapacity:MemoryCapacity * 1024 * 1024
                                      diskCapacity:DiskCapacity * 1024 * 1024
                                          diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    });
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (cachedResponse.data) {
        completion(cachedResponse.data, nil);
        return;
    }
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
        }
        completion(data, error);
    }];
    [downloadTask resume];
}

+ (void)xyDownloadTaskWithURL:(NSString *)URL
                    FolderName:(NSString *)fileName
                      FullPath:(NSString *)fullPath
                   FinishBlock:(void (^)(NSString *fileName, NSString *fullPath, NSError *error))block {
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *request =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:TimeoutInterval];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask =
    [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *savefileName = fileName ? : response.suggestedFilename;;
        NSString *savefullPath = fullPath ? : [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Downloads"];
        savefullPath = [fullPath stringByAppendingPathComponent:savefileName];
        if (!error) {
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:savefullPath] error:nil];
        }
        block(savefileName,savefullPath,error);
    }];
    [downloadTask resume];
}

#pragma mark - 上傳請求
+ (void)xyUploadFilesWithURL:(NSString *)URL
                      FileArr:(NSMutableArray<WxyUploadDataInfo *>*)files
                RequestParams:(NSDictionary *)params
                  FinishBlock:(void (^)(NSData *data, NSURLResponse *response, NSError *error))block {
    URL = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:URL];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:TimeoutInterval];
    NSString *boundaryConstant = [NSUUID UUID].UUIDString;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self getDataBodyWithFileArr:files RequestParams:params BoundaryConstant:boundaryConstant]];
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request completionHandler:block];
    [dataTask resume];
}

/**
 編譯上傳資訊數據

 @param files 上傳檔案
 @param params post
 @param boundaryConstant boundaryConstant
 @return 上傳資訊數據
 */
+ (NSData *)getDataBodyWithFileArr:(NSMutableArray *)files RequestParams:(NSDictionary *)params BoundaryConstant:(NSString *)boundaryConstant {
    NSMutableData *postData = [NSMutableData data];
    // 循环拼接文件二进制信息
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WxyUploadDataInfo *uploadDataInfo = obj;
        // 用于字符串信息
        NSMutableString *stringM = [NSMutableString string];
        // 拼接文件开始的分隔符
        [stringM appendFormat:@"\r\n--%@\r\n",boundaryConstant];
        // 拼接表单数据
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",uploadDataInfo.key,uploadDataInfo.fileName];
        // 拼接文件类型
        [stringM appendFormat:@"Content-Type: %@\r\n\r\n",@"application/octet-stream"];
        // 把前面的字符串信息拼接到请求体里面
        [postData appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
        // 拼接文件的二进制数据到dataM
        [postData appendData:uploadDataInfo.data];
    }];
    // 拼接上傳資訊的信息
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 用于拼接文本信息
        NSMutableString *stringM = [NSMutableString string];
        // 拼接文本信息的开始分割符
        [stringM appendFormat:@"\r\n--%@\r\n",boundaryConstant];
        // 拼接表单数据
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",key];
        // 拼接文本信息
        [stringM appendFormat:@"%@",obj];
        // 把文本信息拼接到请求体
        [postData appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    // 拼接文件上传的结束分隔符
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",boundaryConstant];
    [postData appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    return postData;
}
@end

@implementation WxyNetworkInfo

@end

@implementation WxyUploadDataInfo
+ (instancetype)initWithKey:(NSString *)key
                   FileName:(NSString *)fileName
                       File:(id)file {
    WxyUploadDataInfo *uploadDataInfo = [WxyUploadDataInfo new];
    uploadDataInfo.key = key;
    if ([file isKindOfClass:[NSString class]]) {
        uploadDataInfo.fileName = (fileName) ? : [file lastPathComponent];
        uploadDataInfo.data = [NSData dataWithContentsOfFile:file];
    }
    else if ([file isKindOfClass:[NSURL class]]) {
        uploadDataInfo.fileName = (fileName) ? : [file lastPathComponent];
        uploadDataInfo.data = [NSData dataWithContentsOfURL:file];
    }
    else if ([file isKindOfClass:[UIImage class]]) {
        uploadDataInfo.fileName = [NSString stringWithFormat:@"%@.jpg",[NSUUID UUID].UUIDString];
        uploadDataInfo.data = UIImageJPEGRepresentation(file, 0.5);
    }
    else if ([file isKindOfClass:[NSData class]]) {
        uploadDataInfo.fileName = fileName;
        uploadDataInfo.data = file;
    }
    return uploadDataInfo;
}
@end
