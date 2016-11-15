//
//  Friend+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Friend.h"

NS_ASSUME_NONNULL_BEGIN

@interface Friend (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSDate *dateTime;
@property (nullable, nonatomic, retain) NSNumber *isRequest;  // 是否是别人申请自己的  推送过来的数据 为YES
@property (nullable, nonatomic, retain) NSNumber *k_date;
@property (nullable, nonatomic, retain) NSDate *lastRemindDatetime;
@property (nullable, nonatomic, retain) NSDate *lastRemindTime;
@property (nullable, nonatomic, retain) NSNumber *tag;
@property (nullable, nonatomic, retain) NSString *time_array;
@property (nullable, nonatomic, retain) NSNumber *user_drink_target;
@property (nullable, nonatomic, retain) NSNumber *user_gender;
@property (nullable, nonatomic, retain) NSString *user_id;
@property (nullable, nonatomic, retain) NSString *user_nick_name;
@property (nullable, nonatomic, retain) NSString *user_pic_url;
@property (nullable, nonatomic, retain) NSString *water_array;
@property (nullable, nonatomic, retain) NSNumber *waterCount;            // 今天的喝水量
@property (nullable, nonatomic, retain) NSNumber *like_num;          
@property (nullable, nonatomic, retain) NSNumber *last_like_kDate;



@end

NS_ASSUME_NONNULL_END
