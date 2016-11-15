//
//  UIViewController+GetAccess.h
//  Coasters
//
//  Created by 丁付德 on 15/12/18.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define isHaveMicrophoneAccess              0                       // 是否含有麦克风

typedef enum {
    PhotosAccess = 1,
    CameraAccess,
    MicrophoneAccess
} AccessType;

@interface UIViewController (GetAccess)

#pragma mark  判断是否含有权限  当有权限的时候 进行操作
- (void)getAccessNext:(AccessType)typeSub block:(void(^)())block;

@end
