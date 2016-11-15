//
//  YJLocalCountryData.h
//  SMS_SDKDemo
//
//  Created by 李愿生 on 15/12/21.
//  Copyright © 2015年 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJLocalCountryData : NSObject

@property (nonatomic, strong) NSMutableArray *keys;

+ (YJLocalCountryData *)shareInstance;

+ (NSMutableArray *)localCountryDataArray;

+ (NSDateComponents*)compareTwoDays:(NSString *)dateString;


@end


