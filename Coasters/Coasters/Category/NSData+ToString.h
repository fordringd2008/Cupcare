//
//  NSData+ToString.h
//  NSData 的常见帮助方法
//
//  Created by 丁付德 on 15/5/17.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ToString)

/**
 *  ------------------------------------------ 把十进制数转化为十六进制字符串
 *
 *  @param tmpid 参数 int
 *
 *  @return 转化后的NSString
 */
-(NSString *)ToHex:(long long int)tmpid;


/**
 *  ------------------------------------------ 把自己（NSData）转换为字符串， 以逗号分割
 *
 *  @return 字符串
 */
-(NSString *)ToString;

/**
 *  ------------------------------------------ 把自己（NSData）转换为字符串， 以分隔符分割
 *
 *  @param sep 分隔符
 *
 *  @return 字符串
 */
-(NSString *)ToString:(NSString *)sep;

/**
 *  ------------------------------------------ 打印NSData
 */
-(void)LogData;

/**
 *  ------------------------------------------ 打印NSData 前面有一句提示
 *
 *  @param prompt 在前面的提示语句
 */
-(void)LogDataAndPrompt:(NSString *)prompt;


/**
 *  ------------------------------------------ 打印NSData 前面有两句提示
 *
 *  @param prompt 在前面的提示语句
 */
-(void)LogDataAndPrompt:(NSString *)prompt promptOther:(NSString *)promptOther;


/**
 *  ------------------------------------------  打印字节数组
 *
 *  @param bytes  字节数组
 *  @param length 长度
 *  @param prompt 在前面的提示语句
 */
-(void)LogBytes:(Byte *)bytes length:(int)length prompt:(NSString *)prompt;


@end
