//
//  Group.m
//  
//
//  Created by 丁付德 on 16/6/6.
//
//

#import "Group.h"

@implementation Group

+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    NSString *primary = @"group_id";
    id value1          = myUserInfoAccess;
    id value2          = [dictionary objectForKey:primary];
    Group *model = [Group MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and group_id == %@", value1, value2] inContext:context];
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

// 完善信息
- (void)perfect:(void (^)(id model))perfectBlock
{
    if (perfectBlock) {
        perfectBlock(self);
    }
}

@end
