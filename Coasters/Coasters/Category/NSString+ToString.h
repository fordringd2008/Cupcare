//
//  NSString+ToString.h
//  
//
//  Created by 丁付德 on 15/5/30.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ToString)

/**
 *  格式化文本
 *
 *  @param text       所有文字
 *  @param rangFirst  第一个需要格式化的区间
 *  @param rangSecond 第二个需要格式化的区间
 *  @param bigSize    格式化的字体大小
 *  @param littleSize 一半的字体大小
 *
 *  @return 格式化文本
 */
- (NSMutableAttributedString *)toString:(NSString *)text
                              rangFirst:(NSRange)rangFirst
                             rangSecond:(NSRange)rangSecond
                                bigSize:(CGFloat)bigSize
                             littleSize:(CGFloat)littleSize;

@end
