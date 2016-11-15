//
//  DFToAppStore.h
//  Bracelet
//
//  Created by 丁付德 on 16/5/23.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DFToAppStore : NSObject<UIAlertViewDelegate>
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    
    UIAlertView *alertViewTest;
    UIAlertView *alertViewTestUpdate;
    
#else
    
    UIAlertController *alertController;
    
#endif
    
    
}

@property (nonatomic,copy) NSString * myAppID;//appID

-(instancetype)initWithAppID:(int)appID;
-(void)updateGotoAppStore:(UIViewController *)VC;
-(void)commentGotoAppStore:(UIViewController *)VC;

@end
