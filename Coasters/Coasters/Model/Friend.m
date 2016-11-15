//
//  Friend.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "Friend.h"

@implementation Friend

// Insert code here to add functionality to your managed object subclass

-(void)perfect
{
    [self perfect:NULL];
}

- (void)perfect:(void (^)(id model))perfectBlock
{
    self.dateTime = [DFD HmF2KNSIntToDate:[self.k_date intValue]];
    NSArray *arrWater = [self.water_array componentsSeparatedByString:@","];
    NSInteger water = 0;
    for (int i = 0; i < arrWater.count; i++)
        water += [arrWater[i] integerValue];
    self.waterCount = @(water);
    if (perfectBlock)
        perfectBlock(self);
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"last_like_kDate"])
    {
        if (!oldValue || ![oldValue boolValue]) return @0;
        else
        {
            return @([DFD HmF2KNSDateToInt:DNow]);
        }
    }
    return oldValue;
}

// return @{@“模型属性名” : @“json数组的key”};
// 注意：这里如果 主键或者双主键中的 参与了映射， objectByDictionary 中方法需要 value 需要改动
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"user_id":@"userid",
              @"like_num":@"user_like_num",
              @"last_like_kDate":@"user_like_status"};
    
    // 这里  user_like_status: @"0" --> @0;                               今天没有点赞， 最后点赞日期为0
    // 这里  user_like_status: @"1" --> @([DFD HmF2KNSDateToInt:DNow]);   今天  有点赞， 最后点赞日期为今天
}


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    // 映射前json中的字段
    NSString *primary2 = @"userid";
    id value1          = myUserInfoAccess;
    id value2          = [dictionary objectForKey:primary2];
    // 这里需要是属性名
    Friend *model = [Friend MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", value1, value2] inContext:context];
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
