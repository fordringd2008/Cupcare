//
//  YJLocalCountryData.m
//  SMS_SDKDemo
//
//  Created by 李愿生 on 15/12/21.
//  Copyright © 2015年. All rights reserved.
//

#import "YJLocalCountryData.h"


@implementation YJLocalCountryData


static YJLocalCountryData *localCountryData = nil;

+ (YJLocalCountryData *)shareInstance
{
    @synchronized (self)
    {
        if (localCountryData == nil)
        {
            localCountryData = [[YJLocalCountryData alloc] init];
        }
        return localCountryData;
    }
}


+ (NSMutableArray *)localCountryDataArray
{
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    NSString *dataString = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
    NSDictionary *dataDic = [[NSDictionary alloc] initWithContentsOfFile:dataString];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObject:UITableViewIndexSearch];
    [keyArray addObjectsFromArray:[[dataDic allKeys]
                                   sortedArrayUsingSelector:@selector(compare:)]];
    [YJLocalCountryData shareInstance].keys = keyArray;
    
    dataArray = [[YJLocalCountryData shareInstance] readCountryCode:dataDic];
    
    return dataArray;
}

- (NSMutableArray *)readCountryCode:(NSDictionary *)countryData
{
    NSMutableArray *zoneArray = [NSMutableArray array];
    
    for (NSString *key in self.keys) {
        
        for (NSString *countryNameAndCode in [countryData objectForKey:key]) {
            
            NSRange range = [countryNameAndCode rangeOfString:@"+"];
            NSString* str2 = [countryNameAndCode substringFromIndex:range.location];
            NSString* areaCode = [str2 stringByReplacingOccurrencesOfString:@"+" withString:@""];
            
            NSDictionary *codeDic = [NSDictionary dictionaryWithObjectsAndKeys:areaCode,@"zone",@"^\\d+",@"rule", nil];
            [zoneArray addObject:codeDic];
            
        }
        
    }
    
    return zoneArray;
    
}

/**
 *  计算两个日期的天数差
 *
 *  @param dateString 待计算日期
 *
 *  @return 返回NSDateComponents,通过属性day,可以判断待计算日期和当前日期的天数差
 */
+ (NSDateComponents*)compareTwoDays:(NSString *)dateString
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDate;
    NSDate *toDate;
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:[dateFormatter dateFromString:dateString]];
    [gregorian rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:[NSDate date]];
    NSDateComponents *dayComponents = [gregorian components:NSCalendarUnitDay | NSWeekdayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return dayComponents;
}

@end
