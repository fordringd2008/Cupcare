//
//  UIViewController+GetAccess.m
//  Coasters
//
//  Created by 丁付德 on 15/12/18.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "UIViewController+GetAccess.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#if isHaveMicrophoneAccess
#import <AVFoundation/AVFoundation.h>
#endif

@implementation UIViewController (GetAccess)

#pragma mark  判断是否含有权限  当有权限的时候 进行操作  1: 相册  2: 摄像头  3:麦克风 4:   5:
- (void)getAccessNext:(AccessType)typeSub block:(void(^)())block
{
    switch (typeSub)
    {
        case PhotosAccess:
        {
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            NSLog(@"照片访问权限 --> %ld", (long)author);
            switch (author)
            {
                // case ALAuthorizationStatusNotDetermined:            // 用户尚未对此APP 做出选择
                case ALAuthorizationStatusRestricted:
                case ALAuthorizationStatusDenied:
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [[[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"请在“设置-隐私-照片“选项中,允许Cupcare访问你的照片") delegate:self cancelButtonTitle:nil otherButtonTitles:kString(@"好"), nil] show];
                    });
                }
                    break;
                default:
                {
                    block();
                }
                    break;
            }
        }
            break;
        case CameraAccess:
        {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            NSLog(@"相机访问权限 --> %ld", (long)authStatus);
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [[[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"请在“设置-隐私-相机“选项中,允许'Cupcare'访问你的相机") delegate:self cancelButtonTitle:nil otherButtonTitles:kString(@"好"), nil] show];
                });
            }else{
                block();
            }
        }
            break;
            
#if isHaveMicrophoneAccess
        case MicrophoneAccess:
        {
            AVAudioSession *avSession = [AVAudioSession sharedInstance];
            if ([avSession respondsToSelector:@selector(requestRecordPermission:)])
            {
                [avSession requestRecordPermission:^(BOOL available)
                 {
                     if (available) {
                         NSLog(@"获得权限");
                         block();
                     }
                     else
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSString *message = [NSString stringWithFormat:@"请在“设置-隐私-麦克风“选项中,允许%@访问你的麦克风", [self getIOSName]];
                             [[[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(message) delegate:self cancelButtonTitle:nil otherButtonTitles:kString(@"好"), nil] show];
                         });
                     }
                 }];
            }
        }
            break;
#endif
            
        default:
            break;
    }
}


@end
