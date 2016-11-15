//
//  UserInfo.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "UserInfo.h"

@implementation UserInfo

-(void)perfect:(void (^)(id model))perfectBlock
{
    if (perfectBlock)
        perfectBlock(self);
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property
{
    if ([property.name isEqualToString:@"user_birthday"])
    {
        if (!oldValue) return @"";
        else
        {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyyMMdd";
            return [fmt dateFromString:oldValue];
        }
    }
    
    return oldValue;
}

//return @{@“非关键字的属性名” : @“数组的key”};
// return @{@“模型属性名” : @“json数组的key”};
// 注意：这里如果 主键或者双主键中的 参与了映射， objectByDictionary 中方法需要 value 需要改动
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{ @"logo"       :@"user_pic_url",
              @"countryID"  :@"user_country_code",
              @"stateID"    :@"user_state_code",
              @"cityID"     :@"user_city_code"};
}


+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    UserInfo *model = [UserInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", myUserInfoAccess] inContext:context];
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



- (NSDictionary *)objectToDictionary
{
    // 这里是指过滤后留下的json属性，其他的舍弃
    NSArray *arrUsefulKeys = @[
                               @"access",
                               @"user_pic_url",
                               @"user_nick_name",
                               @"user_gender",
                               @"user_height",
                               @"user_weight",
                               @"user_birthday",
                               @"user_country_code",
                               @"user_state_code",
                               @"user_city_code",
                               @"user_drink_target",
                               @"user_language_code"
                               ];
    
    NSMutableDictionary *dicOld = self.mj_keyValues;
    NSMutableDictionary *dicNew = [dicOld mutableCopy];
    
    [dicOld enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop){
         if (![arrUsefulKeys containsObject:key])
             [dicNew removeObjectForKey:key];
         if ([key isEqualToString:@"user_birthday"])
             dicNew[key] =  [DFD dateToString:obj stringType:@"yyyyMMdd"];
     }];
    return [dicNew mutableCopy];
}



@end
