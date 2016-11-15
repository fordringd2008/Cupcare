//
//  SynData+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SynData.h"

NS_ASSUME_NONNULL_BEGIN

@interface SynData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;                        // 权限
@property (nullable, nonatomic, retain) NSDate *date;                            // 日期  年月日 时分秒
@property (nullable, nonatomic, retain) NSNumber *dateValue;                     // 日期值
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *hour;
@property (nullable, nonatomic, retain) NSNumber *minute;
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSString *pName;                         // 设备名称
@property (nullable, nonatomic, retain) NSString *pUUIDString;                   // 设备uuidString
@property (nullable, nonatomic, retain) NSNumber *score;                         // 得分  // 这个舍弃 得分放在 记录表中
@property (nullable, nonatomic, retain) NSNumber *second;
@property (nullable, nonatomic, retain) NSNumber *sub;                           // 索引  0 - 11
@property (nullable, nonatomic, retain) NSNumber *timeValue;                     // 时间值
@property (nullable, nonatomic, retain) NSNumber *water;                         // 喝水量 这个时间点的喝水量
@property (nullable, nonatomic, retain) NSNumber *waterCount;                    // 截止当前时间 当天的总喝水量（包括当前时间）
@property (nullable, nonatomic, retain) NSNumber *year;

@end

NS_ASSUME_NONNULL_END
