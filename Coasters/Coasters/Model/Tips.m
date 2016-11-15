//
//  Tips.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "Tips.h"

@implementation Tips

// 完善信息
- (void)perfect:(void (^)(id model))perfectBlock
{
    self.datetime = [DFD getDateFromLong:[self.datetimeValue longLongValue]];
    self.tip_languageCode =  [NSString stringWithFormat:@"%02d", [DFD getLanguage]];
    if (perfectBlock) {
        perfectBlock(self);
    }
    // == 1 ? @"01" : @"02";
}

//return @{@“模型属性名” : @“json数组的key”};
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"datetimeValue":@"time"};
}

//time


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    NSString *primary = @"tip_id";
    id value          = [dictionary objectForKey:primary];
    id language       = [NSString stringWithFormat:@"%02d",[DFD getLanguage]];
    Tips *model = [Tips MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"tip_id == %@ and tip_languageCode == %@", value, language] inContext:context];
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
