//
//  BaseModel.m
//  CoreDataJson映射
//
//  Created by 丁付德 on 16/6/22.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

#pragma mark                                        字典 -> 模型
// 字典 -> 模型
// 成功后的对每个当前模型的操作
+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock
{
    NSLog(@"这个需要重写");
    return nil;
}

// NSArray<字典> -> NSArray<模型>
// 成功后的对每个当前模型的操作
+(NSArray *)objectsByArray:(NSArray *)array
                   context:(NSManagedObjectContext *)context
              perfectBlock:(void (^)(id model))perfectBlock
{
    NSMutableArray *arrayTag = [@[] mutableCopy];
    for (NSDictionary *dictionary in array)
    {
        id model = [self objectByDictionary:dictionary
                                       context:context
                                  perfectBlock:perfectBlock];
        [arrayTag addObject:model];
    }
    return  arrayTag;
}

#pragma mark                                       模型 -> 字典(用到上传更新此模型的时候重写)
// 模型 -> 字典
// 用到的key （指转成json之后的值）
- (NSDictionary *)objectToDictionary;
{
    NSLog(@"这个需要重写");
    return nil;
}


// NSArray<模型 > -> NSArray<字典>
// 用到的key （指转成json之后的值）
+ (NSArray *)dictionarysByObjects:(NSArray *)objects
{
    NSLog(@"这个需要重写");
    return nil;
}


// 默认的操作帮助操作
- (void)perfect:(void (^)(id model))perfectBlock
{
    //NSLog(@"这个重写需要看当前的模型是否需要");
}


#pragma mark                                        额外的帮助打印

// 重写系统方法，打印模型的详细信息
-(NSString *)description
{
    NSArray *arrPropertys = [self filterPropertys];
    NSArray *arrValue = [self propertyValues:arrPropertys];
    NSMutableString *reuslt = [NSMutableString new];
    [reuslt appendString:[super description]];
    [reuslt appendString:@"\n"];
    for (int i = 0 ; i < arrPropertys.count; i++) {
        NSString *strProperty = arrPropertys[i];
        id property = arrValue[i];
        [reuslt appendFormat:@"%@ : %@\n", strProperty, property];
    }
    return reuslt;
}

// 获取所有属性名称
- (NSArray *)filterPropertys
{
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        [props addObject:propertyName];
    }
    free(properties);
    return props;
}

// 获取当前模型的所有属性值
-(NSArray *)propertyValues:(NSArray *)arrPropertys {
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *columnName in arrPropertys) {
        id value = [self valueForKey:columnName];
        if (value != nil) {
            [values addObject:value];
        } else {
            [values addObject:[NSNull null]];
        }
    }
    return values;
}


-(void)dealloc
{
    //NSLog(@"%@ 已销毁", [self class]);
}




















@end
