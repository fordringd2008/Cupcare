//
//  NSDate+toString.h
//  
//
//  Created by apple on 15/4/11.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (toString)


- (NSString *)toString:(NSString *)stringType;

- (int)getFromDate:(int)type;

- (NSDate *)getNowDateFromatAnDate;

- (NSDate *)clearTimeZone;

- (BOOL)isToday;


@end
