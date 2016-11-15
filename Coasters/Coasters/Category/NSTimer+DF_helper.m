//
//  NSTimer+DF_helper.m
//  EasyIOSDemo
//
//  Created by 丁付德 on 16/5/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "NSTimer+DF_helper.h"

@implementation NSTimer (DF_helper)

// 停止
-(void)DF_stop
{
    if (self) {
        [self setFireDate:[NSDate distantFuture]];
        [self invalidate];
    }
}

// 暂停
-(void)DF_pause
{
    if (self) {
        [self setFireDate:[NSDate distantFuture]];
    }
}

// 继续
-(void)DF_continue
{
    if (self) {
        [self setFireDate:DNow];
    }
}

// 初始化
+(instancetype)DF_sheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                          block:(void(^)())block
                                        repeats:(BOOL)repeats{
    if (![NSThread currentThread].isMainThread) {
        NSLog(@"当前线程   不是主线程");return nil;
    }else{
        NSTimer *timer = [self scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(DF_blockInvoke:)
                                                     userInfo:[block copy]
                                                      repeats:repeats];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        return timer;
    }
}

+(void)DF_blockInvoke:(NSTimer *)timer{
    void (^block)() = timer.userInfo;
    if (block) {
        block();
        block = nil;
    }
}



@end
