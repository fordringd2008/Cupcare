//
//  Country+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/6/7.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Country.h"

NS_ASSUME_NONNULL_BEGIN

@interface Country (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *countryID;
@property (nullable, nonatomic, retain) NSString *countryName;
@property (nullable, nonatomic, retain) NSNumber *language;
@property (nullable, nonatomic, retain) NSSet<State *> *states;

@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addStatesObject:(State *)value;
- (void)removeStatesObject:(State *)value;
- (void)addStates:(NSSet<State *> *)values;
- (void)removeStates:(NSSet<State *> *)values;

@end

NS_ASSUME_NONNULL_END
