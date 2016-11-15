//
//  BLEManager+Helper.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager+Helper.h"
#import "BLEHeader.h"

@implementation BLEManager (Helper)



// 验证数据是否正确
-(BOOL)checkData:(NSData *)data
{
    if (!data) {
        return  NO;
    }
    NSUInteger count = data.length;
    Byte *bytes = (Byte *)data.bytes;
    int sum = 0;
    
    for (int i = 1; i < count - 1; i++) {
        sum += (bytes[i]) ^ i;
    }
    BOOL isTrue = (sum & 0xFF) == bytes[count - 1];
    return isTrue;
}


//
//-(NSString *)intArrayToString:(int[])arr length:(int)length;
//{
//    NSMutableString *strResult = [NSMutableString new];
//    for (int i = 0; i < length; i++) {
//        NSString *str = [NSString stringWithFormat:@"%d", arr[i]];
//        [strResult appendString:str];
//        if (i != length - 1) {
//            [strResult appendString:@","];
//        }
//    }
//    return strResult;
//}

-(int)intArrayToAVG:(int[])arr length:(int)length
{
    int sum = 0;
    int count = 0;
    for (int i = 0; i < length; i++) {
        if (arr[i] != 0) {
            count++;
            sum += arr[i];
        }
    }
    int avg = sum / count;
    return avg;
}


-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;
{
    BOOL isHas = NO;
    for (int i = 0; i < length; i++) {
        if (arr[i] == value) {
            isHas = YES;
            break;
        }
    }
    return isHas;
}

-(BOOL)intArrayIsHas12:(int[8][12])arr
{
    BOOL isHas = NO;
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 12; j++)
        {
            if (arr[i][j] == 12) {
                isHas = YES;
                break;
            }
        }
        if (isHas)
            break;
    }
    return isHas;
}

-(NSMutableArray *)isAllShield:(NSData *)data;
{
    NSInteger length = data.length;
    Byte *byte = (Byte *)data.bytes;
    NSMutableArray *arr = [NSMutableArray new];
    for(int i = 2; i < length - 1; i = i + 2)
    {
        if (byte[i] == DataOOOO && byte[i+1] == DataOOOO)
        {
            [arr addObject:@( i / 2 - 1)];
        }
    }
    return arr;
}

// 获取在数组中最大的那个值的索引  （数组中为NSNumber）
-(NSInteger)getBiggestIndexInArray:(NSMutableArray *)array
{
    NSInteger tem = 0;
    NSInteger bigger = 0;
    NSInteger ind = 0;              // 索引
    int nowValue = [DFD HmF2KNSDateToInt:DNow];
    for (int i = 0; i < array.count; i++)
    {
        bigger = [array[i] integerValue];
        if (tem < bigger && bigger <= nowValue)
        {
            tem = bigger;
            ind = i;
        }
    }
    return ind;
}


// 返回小时 分钟 秒
-(NSMutableArray *)getTimesFor:(Byte)low height:(Byte)hei
{
    int d3Time = [self getTimeValue:low height:hei];
    NSMutableArray *arr = [DFD getHourMinuteSecondFormDateValue:d3Time];
    return arr;
}

-(int)getTimeValue:(Byte)low height:(Byte)hei
{
    return ( hei<<8 ) | low;
}


//- (void)performBlockInCurrentTheard:(void (^)())block afterDelay:(NSTimeInterval)delay
// 把记录写入本地
-(void)writeRecord:(NSMutableArray *)array block:(void (^)())block 
{
    if(!myUserInfoAccess)  return; // 防止用户注销
    // 获取这个外设的存放数组  0： 日期值(5661)  1: 日期值（NSDate）  2: 数据统计情况(count) 3 : 今天的喝水量（water） 4: 目标值
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
     {
         for (int i = 0 ; i < 8; i++)
         {
             if (![array[0][i] intValue])continue;
             NSDate *date = array[1][i];
             DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@ ", myUserInfoAccess, date] inContext:localContext];
             if (!dr)
             {
                 dr = [DataRecord MR_createEntityInContext:localContext];
                 dr.isUpload = @NO;
             }
             else
             {
                 //NSLog(@"当日记录表中的喝水量：%@， 最新的喝水量：%@", dr.waterCount, array[3][i]);
                 if ([dr.waterCount intValue] < [array[3][i] intValue])
                 {
                     dr.isUpload = @NO;
                     dr.waterCount = @([array[3][i] intValue]);
                 }
             }
             
             dr.access = myUserInfoAccess;
             dr.pUUIDString = myUserInfo.pUUIDString;
             dr.dateValue = array[0][i];
             if ([dr.dateValue intValue] == 0) {   // 如果等于0 说明设备中数据 不到8天， 是补充的0数据
                 NSLog(@"- 尼玛  等于0");
             }
             dr.date = array[1][i];
             dr.cout = array[2][i];   //  统计值
             
             if ([dr.date isToday])
             {
                 SynData *syn = [SynData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and pUUIDString == %@ and year == %d and month == %d and day == %d", myUserInfoAccess, myUserInfo.pUUIDString, DDYear, DDMonth, DDDay] sortedBy:@"timeValue" ascending:NO inContext:localContext];
                 
                 NSLog(@"dr.waterCount : %@, syn.waterCount:%@", dr.waterCount, syn.waterCount);
                 
                 if ([dr.waterCount integerValue] != [syn.waterCount integerValue]) {   // 不等于就要上传
                     dr.isUpload = @NO;
                     dr.waterCount = syn.waterCount;
                 }
             }
             else
             {
                 dr.waterCount = array[3][i];                             // 如果是当天的数据， 取最大的
             }
             
             dr.target = array[4][i];
             NSArray *arr = [self getTimeAndWaterStr:dr.date inContext:localContext];
             dr.time_array = arr[0];
             dr.water_array = arr[1];
             dr.water_array_Hours = arr[2];
             [dr perfect];
             DLSave;
             DBSave;
         }
         block();
     }];
}



// 获取当天的 喝水时间点集合  和喝水量集合   和24小时中每个小时的喝水量集合
-(NSArray *)getTimeAndWaterStr:(NSDate *)date inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *arrTime  = [NSMutableArray new];
    NSMutableArray *arrWater = [NSMutableArray new];
    NSInteger year           = [date getFromDate:1];
    NSInteger month          = [date getFromDate:2];
    NSInteger day            = [date getFromDate:3];
   
    NSArray *arrSyn = [SynData findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@", myUserInfoAccess, @(year), @(month), @(day)] inContext:context];
    int waterHour[24] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    for (int i = 0 ; i < arrSyn.count; i++)
    {
        SynData *syn = arrSyn[i];
        [arrTime addObject:syn.timeValue];
        [arrWater addObject:syn.water];
        int synHour = [syn.hour intValue];
        waterHour[synHour] += [syn.water intValue];   // 累加
    }
    
    NSString *strTime = [self intArrayToString:arrTime];
    NSString *strWater = [self intArrayToString:arrWater];
    NSString *strHour = [DFD intIntsToString:waterHour length:24];
    return  @[ strTime, strWater, strHour ];
}



-(NSString *)intArrayToString:(NSMutableArray *)arr
{
    NSMutableString *strResult = [NSMutableString new];
    for (int i = 0; i < arr.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%@", arr[i]];
        [strResult appendString:str];
        if (i != arr.count - 1)
        {
            [strResult appendString:@","];
        }
    }
    return strResult;
}



// 拼装204数据          // 今天的数据 始终都不屏蔽  为了首页不停的读
-(NSData *)set204Data:(NSMutableArray *)array uuid:(NSString *)uuid
{
    NSData *data;
    char bytes[19];
    bytes[0] = DataFirst;
    bytes[1] = DataOOOO;
    
    NSMutableArray *arr = array[0];                 // dateValue  5702
    NSMutableArray *arrCount = array[2];            // count
    
    int todayValue = [DFD HmF2KNSDateToInt:DNow];
    
    for (int i = 0; i < arr.count; i++)
    {
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dateValue == %@ and access == %@ ", array[0][i], myUserInfoAccess] inContext:DBefaultContext];
        
        // 默认是读取
        NSInteger countOfSyn = [[SynData numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"dateValue == %@ and access == %@ and pUUIDString == %@", array[0][i], myUserInfoAccess, myUserInfo.pUUIDString] inContext:DBefaultContext] integerValue];
        //NSLog(@"----------- countOfSyn = %d", countOfSyn);
        
        NSUInteger dateValue = [array[0][i] integerValue];
        char byte_low = dateValue & 0xFF;
        char byte_hight = ( dateValue >> 8 ) & 0xFF;
        
        if (dr && dateValue != todayValue)
        {
            NSUInteger dataCountFromBL = [((NSNumber *)arrCount[i]) integerValue];
            NSUInteger dataCountFromLocal =  [dr.cout integerValue];
            if (dataCountFromBL == dataCountFromLocal && countOfSyn > 0)
            {
                byte_low = byte_hight = DataOOOO;
//                byte_low    = Data80;
//                byte_hight  = Data00;
            
            }
        }
        
        bytes[i * 2 + 2] = byte_low;
        bytes[i * 2 + 3] = byte_hight;
    }
    
    
    int sum = 0;
    for (int i = 1; i < 18; i++) {
        sum += (bytes[i]) ^ i;
    }
    bytes[18] = sum & 0xFF;
    
    data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    [data LogData];
    
    
    return data;
}

-(NSData *)data204ExceptToday:(NSMutableArray *)array indexSub:(NSInteger)indexSub;
{
    NSData *data;
    char bytes[19];
    bytes[0] = DataFirst;
    bytes[1] = DataOOOO;
    
    NSMutableArray *arr = array[0];                 // dateValue  5702
    int todayValue = [DFD HmF2KNSDateToInt:DNow];
    
    for (int i = 0; i < arr.count; i++)
    {
        // 默认是读取
        NSUInteger dateValue = [array[0][i] integerValue];
        char byte_low = dateValue & 0xFF;
        char byte_hight = ( dateValue >> 8 ) & 0xFF;
        
        if (dateValue != todayValue)
        {
            byte_low = byte_hight = DataOOOO;
        }
        
        bytes[i * 2 + 2] = byte_low;
        bytes[i * 2 + 3] = byte_hight;
    }
    
    
    int sum = 0;
    for (int i = 1; i < 18; i++) {
        sum += (bytes[i]) ^ i;
    }
    bytes[18] = sum & 0xFF;
    
    data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    return data;
}

-(NSDate *)getBiggestDate:(NSMutableDictionary *)dicdate
{
    NSDate *dateM = dicdate.allKeys[0];
    for (NSDate *date in dicdate.allKeys)
    {
        if ([date compare:dateM] == NSOrderedDescending)
        {
            dateM = date;
        }
    }
    return dateM;
}


// 获取发送命令的数量
-(int)getSendCount:(NSArray *)arr
{
    int count = 1;
    NSDictionary *dicTag = arr[4];
    if ([dicTag.allKeys[0] intValue] != [dicTag.allValues[0] intValue])
        count = 2;
    dicTag = arr[8];
    if ([dicTag.allKeys[0] intValue] != [dicTag.allValues[0] intValue])
        count = 3;
    dicTag = arr[12];
    if ([dicTag.allKeys[0] intValue] != [dicTag.allValues[0] intValue])
        count = 4;
    return count;
}




// 检测  喝水提醒数据 是否是空
-(BOOL)checkRemindTime:(NSMutableArray *)arr_1 arr_2:(NSMutableArray *)arr_2
{
//    if (![[arr_1[0] debugDescription] isEqualToString:@"0-0-0-0-0-0-0-0"] ||
//        ![[arr_2[0] debugDescription] isEqualToString:@"0-0-0-0-0-0-0-0"] )
//    {
//        return NO;
//    }
    
    for (int i = 1; i < arr_1.count; i++)
    {
        if ([((NSDictionary *)(arr_1[i])).allKeys[0] intValue] != [((NSDictionary *)(arr_1[i])).allValues[0] intValue] ||
            [((NSDictionary *)(arr_2[i])).allKeys[0] intValue] != [((NSDictionary *)(arr_2[i])).allValues[0] intValue])
        {
            return NO;
        }
    }
    
    return YES;
}

//// 检测 闹钟表 是否有异常
//-(void)checkClockData
//{
//    Clock *clBiggest = [[Clock findAllSortedBy:@"iD" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"(strTime != %@) or (isOn == %@)", @" 00:00", @YES, @YES] inContext:DBefaultContext] firstObject];
//    if (clBiggest)
//    {
//        NSArray *arrLocal = [Clock findAllSortedBy:@"iD" ascending:YES inContext:DBefaultContext];
//        for (int i = 0; i <= [clBiggest.iD intValue]; i++)
//        {
//            Clock *cl = arrLocal[i];
//            cl.isHave = @YES;
//        }
//        DBSave;
//    }
//}













@end
