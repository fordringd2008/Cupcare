//
//  Tips+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tips.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tips (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSNumber *datetimeValue;              // 毫秒
@property (nullable, nonatomic, retain) NSString *pic_url;
@property (nullable, nonatomic, retain) NSString *tip_content;
@property (nullable, nonatomic, retain) NSNumber *tip_id;
@property (nullable, nonatomic, retain) NSString *tip_title;
@property (nullable, nonatomic, retain) NSString *tip_url;
@property (nullable, nonatomic, retain) NSString *tip_languageCode;           // 中英文 01:中文  02:英文

@end

NS_ASSUME_NONNULL_END
