//
//  AppDelegate.h
//  Coasters
//
//  Created by 丁付德 on 15/8/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "YRSideViewController.h"
#import "CustomTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic          ) UIWindow               *window;
@property (strong, nonatomic          ) CustomTabBarController *customTb;
@property (strong, nonatomic          ) YRSideViewController   *sideViewController;
@property (strong, nonatomic          ) LSNavigationController *loginNavigationController;
@property (assign, nonatomic          ) id                     left;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel   *managedObjectModel;
@property (nonatomic, strong          ) NSTimer                *timerR;// 循环注册极光推送
@property (nonatomic, strong          ) id                     tips;   // 跳转用
@property (nonatomic, assign          ) BOOL                   isBind; // 是否已经绑定

-(void)repeatBind:(BOOL)isBinding;

@end

