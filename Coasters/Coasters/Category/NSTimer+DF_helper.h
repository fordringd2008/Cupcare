//
//  NSTimer+DF_helper.h
//  EasyIOSDemo
//
//  Created by 丁付德 on 16/5/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (DF_helper)

// 停止
-(void)DF_stop;

// 暂停
-(void)DF_pause;

// 继续
-(void)DF_continue;

// 初始化
+(instancetype)DF_sheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats;

@end
