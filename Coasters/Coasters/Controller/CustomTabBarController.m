//
//  CustomTabBarViewController.m
//  SoftTrans
//
//  Created by yyh on 6/9/14.
//  Copyright (c) 2014 yyh. All rights reserved.
//

#import "CustomTabBarController.h"

#import "vcIndex.h"
//#import "vcUser.h"
//#import "vcSet.h"
//#import "vcHelp.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSubviewController];
}

-(void)loadSubviewController
{
    UIStoryboard *indexSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LSNavigationController *nav = [indexSB instantiateViewControllerWithIdentifier:@"navMain"];
    nav.showLeft = ^(){
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        YRSideViewController *sideViewController = [delegate sideViewController];
        [sideViewController showLeftViewController:true];
    };
    
    if (nav.viewControllers.count) {
        vcIndex *vc = nav.viewControllers[0];  // 这里是为了让其初始化
        vc = [vc init];
    }
    
    self.viewControllers = @[ nav ];
    self.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
