//
//  DataRecord.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "DataRecord.h"

@implementation DataRecord

// Insert code here to add functionality to your managed object subclass

- (void)perfect
{
    [self perfect:NULL];
}

- (void)perfect:(void (^)(id model))perfectBlock
{
    self.date              = [DFD HmF2KNSIntToDate:[self.dateValue intValue]];
    self.year              = @([self.date getFromDate:1]);
    self.month             = @([self.date getFromDate:2]);
    self.day               = @([self.date getFromDate:3]);
    self.waterCount        = @([DFD getWaterCountFromWater_array:self.water_array
                                             time_array:self.time_array]);
    self.water_array_Hours = [DFD getWater_array_Hour_FromArray:self.water_array
                                                     time_array:self.time_array];
    if (perfectBlock)
        perfectBlock(self);
}

//return @{@“模型属性名” : @“json数组的key”};
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"dateValue":@"k_date",
              @"cout":@"counts" };
}


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    NSString *primary2 = @"dateValue";
    id value1          = myUserInfoAccess;
    id value2          = [dictionary objectForKey:primary2];
    DataRecord *model = [DataRecord MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", value1, value2] inContext:context];
    if (model)
    {
        model = [model mj_setKeyValues:dictionary context:context];
        //NSLog(@"去更新");
    }
    else
    {
        model = [self mj_objectWithKeyValues:dictionary context:context];
        if (model) {
            //NSLog(@"插入成功");
        }else{
            //NSLog(@"插入失败");
        }
    }
    [model perfect:perfectBlock];
    [context MR_saveToPersistentStoreAndWait];
    DBSave
    return model;
}


@end
