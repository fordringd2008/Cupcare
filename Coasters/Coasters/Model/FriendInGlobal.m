//
//  FriendInGlobal.m
//  
//
//  Created by 丁付德 on 16/6/3.
//
//

#import "FriendInGlobal.h"

@implementation FriendInGlobal


-(void)perfect:(void (^)(id model))perfectBlock
{
    if (perfectBlock)
        perfectBlock(self);
}


//return @{@“非关键字的属性名” : @“数组的key”};
// return @{@“模型属性名” : @“json数组的key”};
// 注意：这里如果 主键或者双主键中的 参与了映射， objectByDictionary 中方法需要 value 需要改动
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"url":@"user_pic_url",
              @"waterCount":@"drink_num",
              @"user_id":@"userid",
              @"nick_name":@"user_nick_name"
              };
}


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    // 这里需要是映射前的字段，就是Json中的
    NSString *primary = @"userid";
    id value1          = myUserInfoAccess;
    id value2          = [dictionary objectForKey:primary];
    // 这里需要是属性名 |||
    FriendInGlobal *model = [FriendInGlobal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", value1, value2] inContext:context];
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
