//
//  Clock+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Clock.h"

NS_ASSUME_NONNULL_BEGIN

@interface Clock (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hour;
@property (nullable, nonatomic, retain) NSNumber *iD;        //  ID   0-7  存在本地 不和用户相关
@property (nullable, nonatomic, retain) NSNumber *isOn;      //  是否开启  (bool)
@property (nullable, nonatomic, retain) NSNumber *minute;
@property (nullable, nonatomic, retain) NSString *name;      //  名称    //  这个留做扩展
@property (nullable, nonatomic, retain) NSString *repeat;    //  是否重复   1-1-1-1-1-1-1-1
@property (nullable, nonatomic, retain) NSString *strRepeat; //  08:00
@property (nullable, nonatomic, retain) NSString *strTime;
@property (nullable, nonatomic, retain) NSString *strType;
@property (nullable, nonatomic, retain) NSNumber *type;      //  类型  1:普通闹钟 2:吃药提醒 4:要事提醒    0: 未设置

@end

NS_ASSUME_NONNULL_END
