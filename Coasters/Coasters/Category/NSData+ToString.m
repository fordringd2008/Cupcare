//
//  NSData+ToString.m
//  指令测试
//
//  Created by 丁付德 on 15/5/17.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import "NSData+ToString.h"

@implementation NSData (ToString)

/**
 *  ------------------------------------------ 把十进制数转化为十六进制字符串
 *
 *  @param tmpid 参数 int
 *
 *  @return 转化后的NSString
 */
-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];   // %i
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

/**
 *  ------------------------------------------ 把自己（NSData）转换为字符串， 以逗号分割
 *
 *  @return 字符串
 */
-(NSString *)ToString
{
    return [self ToString:@", "];
}

/**
 *  ------------------------------------------ 把自己（NSData）转换为字符串， 以分隔符分割
 *
 *  @param sep 分隔符
 *
 *  @return 字符串
 */
-(NSString *)ToString:(NSString *)sep
{
    Byte *testByte = (Byte *)[self bytes];
    NSUInteger length = self.length;
    NSMutableString *str = [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < length; i++)
    {
        int a = testByte[i];
        NSString *aStr = [self ToHex:a];
        if (i != 0)
            [str appendString:sep];
        [str appendString:aStr];
    }
    return str;
}

/**
 *  ------------------------------------------ 打印NSData
 */
-(void)LogData
{
    NSLog(@"%@", [self ToString]);
}


/**
 *  ------------------------------------------ 打印NSData 前面有一句提示
 *
 *  @param prompt 在前面的提示语句
 */
-(void)LogDataAndPrompt:(NSString *)prompt
{
    NSLog(@"%@  %@", prompt, [self ToString]);
}

/**
 *  ------------------------------------------ 打印NSData 前面有两句提示
 *
 *  @param prompt 在前面的提示语句
 */
-(void)LogDataAndPrompt:(NSString *)prompt promptOther:(NSString *)promptOther
{
    NSLog(@"%@  %@  %@", prompt, promptOther, [self ToString]);
}

/**
 *  ------------------------------------------  打印字节数组
 *
 *  @param bytes  字节数组
 *  @param length 长度
 *  @param prompt 在前面的提示语句
 */
-(void)LogBytes:(Byte *)bytes length:(int)length prompt:(NSString *)prompt
{
    NSData *data = [NSData dataWithBytes:bytes length:length];
    [data LogDataAndPrompt:prompt];
}










@end
