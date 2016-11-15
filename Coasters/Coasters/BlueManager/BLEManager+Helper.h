//
//  BLEManager+Helper.h
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager.h"

@interface BLEManager (Helper)


// 验证数据是否正确
-(BOOL)checkData:(NSData *)data;

// 拼装204数据
-(NSData *)set204Data:(NSMutableArray *)array uuid:(NSString *)uuid;

// 获取除了今天全部屏蔽的204数据
-(NSData *)data204ExceptToday:(NSMutableArray *)array indexSub:(NSInteger)indexSub;

//int数组 拼写字符串
//-(NSString *)intArrayToString:(int[])arr length:(int)length;

// int数组， 返回非0的平均值
-(int)intArrayToAVG:(int[])arr length:(int)length;

-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;

-(BOOL)intArrayIsHas12:(int[8][12])arr;

// 验证 屏蔽标示符，返回屏蔽的天数的索引的集合
-(NSMutableArray *)isAllShield:(NSData *)data;

// 同步结束后， 根据昨天的数据 写入提醒表
//-(void)writeDataInRemind:(NSString *)uuid;

// 获取这个植物那天的得分
//-(NSNumber *)getScore:(SyncDate *)syn;

// 获取在数组中最大的那个值的索引  （数组中为NSNumber）  过滤掉比当前时间晚的时间
-(NSInteger)getBiggestIndexInArray:(NSMutableArray *)array;

-(int)getTimeValue:(Byte)low height:(Byte)hei;

// 返回小时 分钟 秒
-(NSMutableArray *)getTimesFor:(Byte)low height:(Byte)hei;

// 通过
//-(Byte *)getByesFromClock:(Clock *)clock;

// 把记录写入本地
-(void)writeRecord:(NSMutableArray *)array block:(void (^)())block;

// 获取最大的日期
-(NSDate *)getBiggestDate:(NSMutableDictionary *)dicdate;

// 获取发送命令的数量
-(int)getSendCount:(NSArray *)arr;

// 检测  喝水提醒数据 是否是空  YES: 为空  NO: 不为空
-(BOOL)checkRemindTime:(NSMutableArray *)arr_1 arr_2:(NSMutableArray *)arr_2;

// 检测 闹钟表 是否有异常
//-(void)checkClockData;






@end
