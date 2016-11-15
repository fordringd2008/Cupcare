//
//  NSString+Verify.m
//  EShoping
//
//  Created by Seven on 14-11-29.
//  Copyright (c) 2014年 FUEGO. All rights reserved.
//

#import "NSString+Verify.h"
//#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import "NBPhoneNumberUtil.h"

@implementation NSString (Verify)

-(BOOL)isEmailType{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL)isPhone{
    NSError *error;
    NBPhoneNumber *phone = [[NBPhoneNumberUtil sharedInstance] parse:self defaultRegion:@"CN" error:&error];
    if ([[NBPhoneNumberUtil sharedInstance] isValidNumber:phone]) {
        return YES;
    }else{
        return NO;
    }
}

// 传入  国家缩写 如： 中国 CN
-(BOOL)isPhoneAllWold:(NSString *)countrycode
{
    NSError *error;
    NBPhoneNumber *phone = [[NBPhoneNumberUtil sharedInstance] parse:self
                                                       defaultRegion:countrycode
                                                               error:&error];
    if ([[NBPhoneNumberUtil sharedInstance] isValidNumber:phone]) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isChines:(NSString *)str
{
    int a = [str characterAtIndex:0];
    if( a > 0x4e00 && a < 0x9fff)
        return YES;
    return NO;
}

+(NSInteger)getLength:(NSString *)str
{
    NSInteger length = 0;
    for (int i = 0; i < str.length; i++)
    {
        NSString *simple = [str substringWithRange:NSMakeRange(i, 1)];
        BOOL isChinese = [[NSString new] isChines:simple];
        length += (isChinese ? 2 : 1);
    }
    return length;
}

+ (BOOL)isHaveEmoji:(NSString *)string
{
    if (!string) return NO;
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

@end
