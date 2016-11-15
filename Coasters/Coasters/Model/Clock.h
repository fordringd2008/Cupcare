//
//  Clock.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Clock : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

-(void)perfect;

+(void)initClockData;

+(void)resetClockData;

@end

NS_ASSUME_NONNULL_END

#import "Clock+CoreDataProperties.h"
