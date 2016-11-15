//
//  State+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/6/7.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "State.h"

NS_ASSUME_NONNULL_BEGIN

@interface State (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *language;
@property (nullable, nonatomic, retain) NSString *stateID;
@property (nullable, nonatomic, retain) NSString *stateName;
@property (nullable, nonatomic, retain) Country *country;
@property (nullable, nonatomic, retain) NSSet<City *> *cities;

@end

@interface State (CoreDataGeneratedAccessors)

- (void)addCitiesObject:(City *)value;
- (void)removeCitiesObject:(City *)value;
- (void)addCities:(NSSet<City *> *)values;
- (void)removeCities:(NSSet<City *> *)values;

@end

NS_ASSUME_NONNULL_END
