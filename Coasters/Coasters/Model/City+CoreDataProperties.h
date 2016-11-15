//
//  City+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/6/7.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "City.h"

NS_ASSUME_NONNULL_BEGIN

@interface City (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cityID;
@property (nullable, nonatomic, retain) NSString *cityName;
@property (nullable, nonatomic, retain) NSNumber *language;
@property (nullable, nonatomic, retain) State *state;

@end

NS_ASSUME_NONNULL_END
