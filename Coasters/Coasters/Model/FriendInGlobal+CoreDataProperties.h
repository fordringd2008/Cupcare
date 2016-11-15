//
//  FriendInGlobal+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/6/3.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FriendInGlobal.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendInGlobal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;
@property (nullable, nonatomic, retain) NSString *nick_name;
@property (nullable, nonatomic, retain) NSNumber *rank;
@property (nullable, nonatomic, retain) NSNumber *waterCount;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSNumber *user_gender;
@property (nullable, nonatomic, retain) NSString *user_id;

@end

NS_ASSUME_NONNULL_END
