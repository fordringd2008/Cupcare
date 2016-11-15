//
//  DataRecord+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DataRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataRecord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSNumber *cout;                          // 数据统计情况(count)
@property (nullable, nonatomic, retain) NSDate *date;                            // 日期值（NSDate）
@property (nullable, nonatomic, retain) NSNumber *dateValue;                     // 日期值(5661)
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSNumber *isUpload;                      // 是否上传
@property (nullable, nonatomic, retain) NSNumber *month;
@property (nullable, nonatomic, retain) NSNumber *percent;                       // 当天的得分    这个舍弃
@property (nullable, nonatomic, retain) NSString *pUUIDString;                   // 设备uuidString //  这个 估计要舍弃
@property (nullable, nonatomic, retain) NSNumber *target;                        // 目标值
@property (nullable, nonatomic, retain) NSString *time_array;                    // 今天的所有喝水的时间集合 （和接口对应）
@property (nullable, nonatomic, retain) NSString *water_array;                   // 今天的所有喝水量的集合 （和接口对应）
@property (nullable, nonatomic, retain) NSString *water_array_Hours;             // 今天24小时的喝水集合
@property (nullable, nonatomic, retain) NSNumber *waterCount;                    // 今天的喝水量（water
@property (nullable, nonatomic, retain) NSNumber *year;

@end

NS_ASSUME_NONNULL_END
