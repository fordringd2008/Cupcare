//
//  vcUseHelp.m
//  Coasters
//
//  Created by 丁付德 on 15/9/5.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUseHelp.h"

@interface vcUseHelp()
//
//@property (weak, nonatomic) IBOutlet UIImageView *imv;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imv;



@end

@implementation vcUseHelp

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"使用帮助"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    self.viewMainHeight.constant = ScreenWidth * (3184.0 / 1242.0);
    
    if ([DFD getLanguage] == 1) {
        self.imv.image = [UIImage imageNamed:@"help_zh"];
    }else
    {
        self.imv.image = [UIImage imageNamed:@"help_en"];
    }
    
    
    
//    self.imvHeight.constant = ScreenWidth / 1242.0 * 3198;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

@end
