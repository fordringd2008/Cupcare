//
//  NSMutableArray+Sort.m
//  Coasters
//
//  Created by 丁付德 on 15/8/28.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "NSMutableArray+Sort.h"

@implementation NSMutableArray (Sort)

-(NSMutableArray *)startArraySort:(NSString *)keystring isAscending:(BOOL)isAscending
{
    NSMutableArray* destinationArry = [[NSMutableArray alloc] init];
    NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:keystring ascending:isAscending];
    destinationArry = [[NSMutableArray alloc]initWithArray:[self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByA]]];
    return destinationArry;
}

@end
