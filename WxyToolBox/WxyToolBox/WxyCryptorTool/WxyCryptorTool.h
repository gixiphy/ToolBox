//
//  WxyCryptorTool.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/23.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface WxyCryptorTool : NSObject

/**
 *  MD5加密
 *
 *  @param str 字串
 *
 *  @return MD5加密字串
 */
+ (NSString *)xyMD5:(NSString *)str;

/**
 *  SHA256加密
 *
 *  @param str 字串
 *
 *  @return SHA256加密字串
 */
+ (NSString *)xySHA256:(NSString *)str;

/**
 *  SHA512加密
 *
 *  @param str 字串
 *
 *  @return SHA512加密字串
 */
+ (NSString *)xySHA512:(NSString *)str;


/**
 Base64加密（NSString）
 
 @param string 字串
 @return Base64加密字串
 */
+ (NSString *)xyBase64EncodedString:(NSString *)string;

/**
 Base64加密（NSData）
 
 @param sourceData 數據
 @return Base64加密字串
 */
+ (NSString *)xyBase64EncodingWithData:(NSData *)sourceData;

/**
 Base64解密（NSString）
 
 @param string 加密字串
 @return Base64解密字串
 */
+ (NSString *)xyBase64DecodedString:(NSString *)string;

/**
 Base64解密（NSData）
 
 @param sourceString 加密字串
 @return Base64解密數據
 */
+ (id)xyBase64EncodingWithString:(NSString *)sourceString;

/**
 *  DES加密（NSData）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param data      加密數據
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return DES加密數據
 */
+ (NSData *)xyDESEncryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString;

/**
 *  DES加密（NSString）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param string    加密字串
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return DES加密字串
 */
+ (NSString *)xyDESEncryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString;

/**
 *  DES解密（NSData）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param data      解密數據
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return DES解密數據
 */
+ (NSData *)xyDESDecryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString;

/**
 *  DES解密（NSString）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param string    解密字串
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return DES解密字串
 */
+ (NSString *)xyDESDecryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString;

/**
 *  AES加密（NSData）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param data      加密數據
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return AES加密數據
 */
+ (NSData *)xyAESEncryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString;

/**
 *  AES加密（NSString）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param string    加密字串
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return AES加密字串
 */
+ (NSString *)xyAESEncryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString;

/**
 *  AES解密（NSData）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param data      解密數據
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return AES解密數據
 */
+ (NSData *)xyAESDecryptData:(NSData *)data
                     keyString:(NSString *)keyString
                            iv:(NSString *)ivString;

/**
 *  AES解密（NSString）
 *  方法出處：XHTeng/XHCryptorTools https://github.com/XHTeng/XHCryptorTools
 *  @param string    解密字串
 *  @param keyString 密鑰字符串
 *  @param ivString  向量
 *
 *  @return AES解密字串
 */
+ (NSString *)xyAESDecryptString:(NSString *)string
                         keyString:(NSString *)keyString
                                iv:(NSString *)ivString;
@end

NS_ASSUME_NONNULL_END
