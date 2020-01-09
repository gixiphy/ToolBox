//
//  WxyStringTool.h
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/27.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WxyStringTool : NSObject

@property(nonatomic, strong) NSString *inputString;

#pragma mark -
+ (instancetype)xyInitWithStr:(NSString *)str;

#pragma mark - 連續解碼工具（搭配xyinitWithStr使用）
/**
剪下文字

@param offset 解析位數
@return 剪下文字
*/
- (NSString *)cutStr:(NSInteger)offset;

/**
十進制編碼

@param offset 解析位數
@return 十進制編碼
*/
- (NSInteger)parseInt:(NSInteger)offset;

/**
十六進制編碼

@param offset 解析位數
@return 十六進制編碼
*/
- (NSString *)parseDecimal:(NSInteger)offset;

/**
HEX編碼

@param offset 解析位數
@return HEX編碼
*/
- (NSString *)parseHexString:(NSInteger)offset;

#pragma mark - 解碼工具
/**
 HEX編碼
 
 @param data 編碼資訊
 @return HEX轉碼
 */
+ (NSString *)xyHexByData:(NSData *)data;

/**
 HEX編碼（限制編碼長度）

 @param string 編碼字串
 @param length 限制編碼長度
 @param sentNonPrinting  yes:0x00 no:@" ",0x20
 @return HEX編碼
 */
+ (NSString *)xyHexByString:(NSString *)string
                StinrgLength:(NSInteger)length
             SentNonPrinting:(BOOL)sentNonPrinting;

/**
文字轉碼

@param hexStr 編碼字串
@return 文字編碼
*/
+ (NSString *)xyStringByHex:(NSString *)hexStr;

#pragma mark - 十六進制<~>十進制

/**
 十六進制轉換十進制
 
 @param hexString 十六進制數
 @return 十進制數
 */
+ (NSInteger)xyDecimalByHexadecimal:(NSString *)hexString;

/**
 十進制轉換十六進制
  
 @param decimal 十進制數
 @return 十六進制數
 */
+ (NSString *)xyHexadecimalByDecimal:(NSInteger)decimal;

#pragma mark - 十六進制<~>二進制
/**
 二進制轉換成十六進制
   
 @param binary 二進制數
 @return 十六進制數
 */
+ (NSString *)xyHexadecimalByBinary:(NSString *)binary;

/**
 十六進制轉換為二進制
   
 @param hex 十六進制數
 @return 二進制數
 */
+ (NSString *)xyBinaryByHexadecimal:(NSString *)hex;

#pragma mark - 二進制<~>十進制
/**
 二進制轉換為十進制
  
 @param binary 二進制數
 @return 十進制數
 */
+ (NSInteger)xyDecimalByBinary:(NSString *)binary;

/**
 十進制轉二進制
 
@param decimal 十進制数
@return 二進制數
*/
+ (NSString *)xyBinaryByDecimal:(NSInteger)decimal;
@end

NS_ASSUME_NONNULL_END
