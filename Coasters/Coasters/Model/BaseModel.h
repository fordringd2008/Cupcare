//
//  BaseModel.h
//  CoreDataJson映射
//
//  Created by 丁付德 on 16/6/22.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MJExtension.h"

@interface BaseModel : NSManagedObject

// 字典 -> 模型
// 成功后的对每个当前模型的操作
+(instancetype)objectByDictionary:(NSDictionary *)dictionary
                          context:(NSManagedObjectContext *)context
                     perfectBlock:(void (^)(id model))perfectBlock;

// NSArray<字典> -> NSArray<模型>
// 成功后的对每个当前模型的操作
+(NSArray *)objectsByArray:(NSArray *)array
                   context:(NSManagedObjectContext *)context
              perfectBlock:(void (^)(id model))perfectBlock;

// 模型 -> 字典
- (NSDictionary *)objectToDictionary;

// NSArray<模型 > -> NSArray<字典>
// 用到的key （指转成json之后的值）
+ (NSArray *)dictionarysByObjects:(NSArray *)objects;


// 默认的操作帮助操作
- (void)perfect:(void (^)(id model))perfectBlock;



@end
