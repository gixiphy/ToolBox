//
//  WxyStringTool.m
//  WxyToolBox
//
//  Created by willy.wu on 2019/9/27.
//  Copyright © 2019 willy.wu. All rights reserved.
//

#import "WxyStringTool.h"
#import "WxyToolBox.h"

@implementation WxyStringTool

#pragma mark - 通用
+ (instancetype)xyInitWithStr:(NSString *)str {
    WxyStringTool *hex = [WxyStringTool new];
    if (self) {
        hex.inputString = str;
    }
    return hex;
}

- (NSString *)hexStringToIndex:(NSInteger)offset {
    NSUInteger to = (self.inputString.length > offset) ? offset : self.inputString.length;
    NSString *ret = [self.inputString substringToIndex:to];
    self.inputString = [self.inputString substringFromIndex:to];
    return ret;
}

#pragma mark - 連續解碼工具（搭配xyinitWithStr使用）
- (NSString *)cutStr:(NSInteger)offset {
    return [self hexStringToIndex:offset];
}

- (NSInteger)parseInt:(NSInteger)offset {
    NSString *hexString = [self hexStringToIndex:offset];
    return [WxyStringTool xyDecimalByHexadecimal:hexString];
}

- (NSString *)parseDecimal:(NSInteger)offset {
    NSInteger ret = [self parseInt:offset];
    return [WxyStringTool xyBinaryByDecimal:ret];
}

- (NSString *)parseHexString:(NSInteger)offset {
    NSString *hexString = [self hexStringToIndex:offset];
    return [WxyStringTool xyStringByHex:hexString];
}

#pragma mark - 解碼工具
+ (NSString *)xyHexByData:(NSData *)data {
    NSUInteger length = data.length;
    if (length == 0) {
        return nil;
    }
    const uint8_t*buf = [data bytes];
    NSString *receiveStr = @"";
    for (int i = 0; i < length; i++) {
        receiveStr = [receiveStr stringByAppendingFormat:@"%02X", buf[i]];
    }
    return receiveStr;
}

+ (NSString *)xyHexByString:(NSString *)string
                StinrgLength:(NSInteger)length
             SentNonPrinting:(BOOL)sentNonPrinting {
    NSString *receiveStr = @"";
    length = (length > 0) ? length : string.length;
    if (string.length >= length) {
        string = [string substringToIndex:length];
        receiveStr = [self xyHexByData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        if (sentNonPrinting) {
            receiveStr = [self xyHexByData:[string dataUsingEncoding:NSUTF8StringEncoding]];
            for (NSInteger i = string.length; i < length; i++) {
                receiveStr = [receiveStr stringByAppendingFormat:@"00"];
            }
        }
        else {
            for (NSInteger i = string.length; i < length; i++) {
                string = [string stringByAppendingFormat:@" "];
                receiveStr = [self xyHexByData:[string dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    return receiveStr;
}

+ (NSString *)xyStringByHex:(NSString *)hexStr {
    NSMutableString *newString = [[NSMutableString alloc] init];
    WxyStringTool *hsMessage = [WxyStringTool xyInitWithStr:hexStr];
    while (hsMessage.inputString.length > 0) {
        NSString *hexChar = [hsMessage cutStr:2];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSUTF8StringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
    }
    return newString;
}

#pragma mark - 十六進制<~>十進制
+ (NSInteger)xyDecimalByHexadecimal:(NSString *)hexString {
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&result];
    NSNumber *resultV = [NSNumber numberWithInt:result];
    return [resultV integerValue];
}

+ (NSString *)xyHexadecimalByDecimal:(NSInteger)decimal {
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i < 9; i++) {
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10: letter =@"A"; break;
            case 11: letter =@"B"; break;
            case 12: letter =@"C"; break;
            case 13: letter =@"D"; break;
            case 14: letter =@"E"; break;
            case 15: letter =@"F"; break;
            default: letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            break;
        }
    }
    return hex;
}

#pragma mark - 十六進制<~>二進制
+ (NSString *)xyHexadecimalByBinary:(NSString *)binary {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    NSString *hex = @"";
    for (int i = 0; i < binary.length; i+=4) {
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}

+ (NSString *)xyBinaryByHexadecimal:(NSString *)hex {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [hexDic setObject:@"0000" forKey:@"0"];
    [hexDic setObject:@"0001" forKey:@"1"];
    [hexDic setObject:@"0010" forKey:@"2"];
    [hexDic setObject:@"0011" forKey:@"3"];
    [hexDic setObject:@"0100" forKey:@"4"];
    [hexDic setObject:@"0101" forKey:@"5"];
    [hexDic setObject:@"0110" forKey:@"6"];
    [hexDic setObject:@"0111" forKey:@"7"];
    [hexDic setObject:@"1000" forKey:@"8"];
    [hexDic setObject:@"1001" forKey:@"9"];
    [hexDic setObject:@"1010" forKey:@"A"];
    [hexDic setObject:@"1011" forKey:@"B"];
    [hexDic setObject:@"1100" forKey:@"C"];
    [hexDic setObject:@"1101" forKey:@"D"];
    [hexDic setObject:@"1110" forKey:@"E"];
    [hexDic setObject:@"1111" forKey:@"F"];
    NSString *binary = @"";
    for (int i = 0; i < [hex length]; i++) {
        NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
        NSString *value = [hexDic objectForKey:key.uppercaseString];
        if (value) {
            binary = [binary stringByAppendingString:value];
        }
    }
    return binary;
}

#pragma mark - 二進制<~>十進制
+ (NSInteger)xyDecimalByBinary:(NSString *)binary {
    NSInteger decimal = 0;
    for (int i = 0; i < binary.length; i++) {
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            decimal += pow(2, i);
        }
    }
    return decimal;
}

+ (NSString *)xyBinaryByDecimal:(NSInteger)decimal {
    NSString *binary = @"";
        while (decimal) {
            binary = [[NSString stringWithFormat:@"%ld", (long)decimal % 2] stringByAppendingString:binary];
            if (decimal / 2 < 1) {
                break;
            }
            decimal = decimal / 2 ;
        }
        if (binary.length % 4 != 0) {
            NSMutableString *mStr = [[NSMutableString alloc]init];;
            for (int i = 0; i < 4 - binary.length % 4; i++) {
                [mStr appendString:@"0"];
            }
            binary = [mStr stringByAppendingString:binary];
        }
        return binary;
}
@end
