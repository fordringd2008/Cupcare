//
//  StartViewController.h
//  
//
//  Created by yyh on 14/12/23.
//  Copyright (c) 2014年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface vcStart : UIViewController

@property (nonatomic, copy) void (^gotoMainStory)();

@property (nonatomic, copy) void (^getPermissions)();


@end
