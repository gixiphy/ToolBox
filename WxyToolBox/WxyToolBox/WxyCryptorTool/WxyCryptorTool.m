//
//  WxyCryptorTool.m
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/23.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import "WxyCryptorTool.h"
#import "WxyToolBox.h"

@implementation WxyCryptorTool

#pragma mark MD5
+ (NSString *)xyMD5:(NSString *)str {
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char output[outputLength];
    CC_MD5(str.UTF8String, [self UTF8Length:str], output);
    return [self toHexString:output length:outputLength];
}

#pragma mark SHA256
+ (NSString *)xySHA256:(NSString *)str {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];
    CC_SHA256(str.UTF8String, [self UTF8Length:str], output);
    return [self toHexString:output length:outputLength];
}

#pragma mark SHA512
+ (NSString *)xySHA512:(NSString *)str {
    unsigned int outputLength = CC_SHA512_DIGEST_LENGTH;
    unsigned char output[outputLength];
    CC_SHA512(str.UTF8String, [self UTF8Length:str], output);
    return [self toHexString:output length:outputLength];
}

#pragma mark  Base64加密（NSString）
+ (NSString *)xyBase64EncodedString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self xyBase64EncodingWithData:data];
}

#pragma mark Base64加密（NSData）
+ (NSString *)xyBase64EncodingWithData:(NSData *)sourceData {
    return [sourceData base64EncodedStringWithOptions:
            NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark  Base64解密（NSString）
+ (NSString *)xyBase64DecodedString:(NSString *)string {
    NSData *data = [self xyBase64EncodingWithString:string];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark Base64解密（NSData）
+ (id)xyBase64EncodingWithString:(NSString *)sourceString {
    return [[NSData alloc]initWithBase64EncodedString:sourceString options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

#pragma mark  DES加密（NSData）
+ (NSData *)xyDESEncryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString {
    NSData *iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
    return [self CCCryptData:data algorithm:kCCAlgorithmDES operation:kCCEncrypt keyString:keyString iv:iv];
}

#pragma mark  DES加密（NSString）
+ (NSString *)xyDESEncryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [self xyDESEncryptData:data keyString:keyString iv:ivString];
    //BASE64編碼
    return [self xyBase64EncodingWithData:result];
}

#pragma mark  DES解密（NSData）
+ (NSData *)xyDESDecryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString {
    NSData *iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
    return [self CCCryptData:data algorithm:kCCAlgorithmDES operation:kCCDecrypt keyString:keyString iv:iv];
}

#pragma mark  DES解密（NSString）
+ (NSString *)xyDESDecryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString {
    //BASE64解碼
    NSData *data = [self xyBase64EncodingWithString:string];
    NSData *result = [self xyDESDecryptData:data keyString:keyString iv:ivString];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

#pragma mark  AES加密（NSData）
+ (NSData *)xyAESEncryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString {
    NSData *iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
    return [self CCCryptData:data algorithm:kCCAlgorithmAES operation:kCCEncrypt keyString:keyString iv:iv];
}

#pragma mark  AES加密（NSString）
+ (NSString *)xyAESEncryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [self xyAESEncryptData:data keyString:keyString iv:ivString];
    //BASE64編碼
    return [self xyBase64EncodingWithData:result];
}

#pragma mark  AES解密（NSData）
+ (NSData *)xyAESDecryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString {
    NSData *iv = [ivString dataUsingEncoding:NSUTF8StringEncoding];
    return [self CCCryptData:data algorithm:kCCAlgorithmAES operation:kCCDecrypt keyString:keyString iv:iv];
}

#pragma mark  AES解密（NSString）
+ (NSString *)xyAESDecryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString {
    //BASE64解碼
    NSData *data = [self xyBase64EncodingWithString:string];
    NSData *result = [self xyAESDecryptData:data keyString:keyString iv:ivString];
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

#pragma mark - 加密公用方法
#pragma mark 取得字串長度
+ (unsigned int)UTF8Length:(NSString *)str {
    return (unsigned int) [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}
#pragma mark 將加密結果編成字串
+ (NSString*) toHexString:(unsigned char*) data
                   length: (unsigned int) length {
    NSMutableString *hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02x", data[i]];
        data[i] = 0;
    }
    return hash;
}
#pragma mark AES/DES加密＆解密核心方法
/**
 *  AES/DES加密＆解密核心方法
 *
 *  @param data      加密/解密的數據
 *  @param algorithm 加密算法
 *  @param operation 加密/解密操作
 *  @param keyString 密鑰字符串
 *  @param iv        向量
 *
 *  @return 加密/解密結果
 */
+ (NSData *)CCCryptData:(NSData *)data
              algorithm:(CCAlgorithm)algorithm
              operation:(CCOperation)operation
              keyString:(NSString *)keyString
                     iv:(NSData *)iv {
    int keySize = (algorithm == kCCAlgorithmAES) ? kCCKeySizeAES128 : kCCKeySizeDES;
    int blockSize = (algorithm == kCCAlgorithmAES) ? kCCKeySizeAES128: kCCBlockSizeDES;
    // 設置密鑰
    NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t cKey[keySize];
    bzero(cKey, sizeof(cKey));
    [keyData getBytes:cKey length:keySize];
    // 設置IV向量
    uint8_t cIv[blockSize];
    bzero(cIv, blockSize);
    int option = kCCOptionPKCS7Padding | kCCOptionECBMode;
    if (iv) {
        [iv getBytes:cIv length:blockSize];
        option = kCCOptionPKCS7Padding;
    }
    // 設置輸出緩衝
    size_t bufferSize = [data length] + blockSize;
    void *buffer = malloc(bufferSize);
    // 加/解密
    size_t cryptorSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          algorithm,
                                          option,
                                          cKey,
                                          keySize,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &cryptorSize);
    NSData *result = nil;
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:cryptorSize];
    } else {
        free(buffer);
        NSLog(@"[錯誤] 加密或解密失敗 | 狀態編碼:\n%d", cryptStatus);
    }
    return result;
}
@end
