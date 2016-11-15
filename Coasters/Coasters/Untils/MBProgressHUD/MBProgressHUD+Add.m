//
//  MBProgressHUD+Add.m
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+Add.h"
#import <unistd.h>

@implementation MBProgressHUD (Add)

#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    
    UIView *viewContent = [[UIView alloc] init];
    UIImageView *imv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    imv.frame = CGRectMake(0, 0, 37, 37);
    [viewContent addSubview:imv];
    
//    Border(imv, DRed);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.textColor = [UIColor whiteColor];
    lbl.numberOfLines = 0;
    [viewContent addSubview:lbl];
    
    CGSize title;
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : style };
    title = [lbl.text boundingRectWithSize:size
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    
    lbl.frame = CGRectMake(0, 37, title.width, title.height);
    viewContent.frame = CGRectMake(0, 0, title.width > 40 ? title.width : 40,  title.height);
    imv.center = CGPointMake(viewContent.frame.size.width / 2, 13);
    
    HUD.customView = viewContent;
    HUD.mode = MBProgressHUDModeCustomView;
//    HUD.yOffset = 150.f;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

+ (void)show:(NSString *)text toView:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    UIView *viewContent = [[UIView alloc] init];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.textColor = [UIColor whiteColor];
    lbl.numberOfLines = 0;
    [viewContent addSubview:lbl];
    
    CGSize title;
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : style };
    title = [lbl.text boundingRectWithSize:size
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    
    lbl.frame = CGRectMake(0, 0, title.width, title.height);
    viewContent.frame = CGRectMake(0, 0, title.width > 40 ? title.width : 40,  title.height);
    HUD.customView = viewContent;
    HUD.mode = MBProgressHUDModeCustomView;
//    HUD.yOffset = 150;
    HUD.margin = 10;
    HUD.userInteractionEnabled = NO;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

#pragma mark 显示信息 重载方法(加入自定义延迟时间)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view  delay:(NSInteger)delay
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.textColor = [UIColor whiteColor];
    lbl.numberOfLines = 0;
    
    CGSize title;
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : style };
    title = [lbl.text boundingRectWithSize:size
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    
    lbl.frame = CGRectMake(0, 0, title.width, title.height);
    hud.customView = lbl;
    hud.mode = MBProgressHUDModeCustomView;
    
    //hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

+ (void)showWarn:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"warning.png" view:view];
}

#pragma mark 显示错误信息 重载方法(加入自定义延迟时间)
+ (void)showError:(NSString *)error toView:(UIView *)view delay:(NSInteger)delay
{
    [self show:error icon:@"error.png" view:view delay:delay];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view delay:(NSInteger)delay
{
    [self show:success icon:@"success.png" view:view delay:delay];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessag:(NSString *)message toView:(UIView *)view
{
//    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    
//    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
//    lbl.textAlignment = NSTextAlignmentCenter;
//    lbl.text = message;
//    lbl.font = [UIFont systemFontOfSize:14];
//    lbl.textColor = [UIColor whiteColor];
//    lbl.numberOfLines = 0;
//    
//    CGSize title;
//    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setLineBreakMode:NSLineBreakByCharWrapping];
//    
//    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : style };
//    title = [lbl.text boundingRectWithSize:size
//                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                attributes:attributes context:nil].size;
//    
//    lbl.frame = CGRectMake(0, 0, title.width, title.height);
//    hud.customView = lbl;
//    hud.mode = MBProgressHUDModeCustomView;
//    //hud.removeFromSuperViewOnHide = YES;
//    hud.dimBackground = YES;
//    return hud;
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
//    hud.yOffset = 150.f;
    // YES代表需要蒙版效果
    hud.dimBackground = NO;
    [hud hide:YES afterDelay:1];
    
    return hud;
}

+ (MBProgressHUD *)showHUDAddedToWithText:(NSString *)text view:(UIView *)view animated:(BOOL)animated;
{
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = kString(text);
    [view addSubview:hud];
//    hud.yOffset = 150.f;
    hud.margin = 10.f;
    [hud show:animated];
    return hud;
}


+ (void)showHUDAfterOffsetAddedTo:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = kString(@"正在加载");
    [view addSubview:hud];
//    hud.yOffset = 150 - NavBarHeight/2;
    hud.margin = 10.f;
    [hud show:animated];
}

+ (void)showAfterOffset:(NSString *)text toView:(UIView *)view
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    UIView *viewContent = [[UIView alloc] init];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.textColor = [UIColor whiteColor];
    lbl.numberOfLines = 0;
    [viewContent addSubview:lbl];
    
    CGSize title;
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 0.7,MAXFLOAT);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14], NSParagraphStyleAttributeName : style };
    title = [lbl.text boundingRectWithSize:size
                                   options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                attributes:attributes context:nil].size;
    lbl.frame = CGRectMake(0, 0, title.width, title.height);
    viewContent.frame = CGRectMake(0, 0, title.width > 40 ? title.width : 40,  title.height);
    
    HUD.customView = viewContent;
    HUD.mode = MBProgressHUDModeCustomView;
//    HUD.yOffset = 150-NavBarHeight/2;
    HUD.margin = 10;
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}



@end
