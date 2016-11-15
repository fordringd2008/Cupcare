//
//  vcBase+Share.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/21.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase+Share.h"


#import <ShareSDK/ShareSDK.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import "IPAddress.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import <FacebookConnection/ISSFacebookApp.h>
#import <TwitterConnection/ISSTwitterApp.h>


@implementation vcBase (Share)

-(void)share:(NSInteger)shareType url:(NSString *)url title:(NSString *)title
{
    //     1： 微信好友  2： 微信朋友圈 3：新浪微博 4：QQ空间 5：qq好友  6：facebook 7: twitter
    ShareType type = 0;
    switch (shareType) {
        case 1:
            type = ShareTypeWeixiSession;
            break;
        case 2:
            type = ShareTypeWeixiTimeline;
            break;
        case 3:
            type = ShareTypeSinaWeibo;
            break;
        case 4:
            type = ShareTypeQQSpace;
            break;
        case 5:
            type = ShareTypeQQ;
            break;
        case 6:
            type = ShareTypeFacebook;
            break;
        case 7:
            type = ShareTypeTwitter;
            break;
    }
    
    UIImage *shareimage = [self imageFromView:self.view];
    NSString *sharUrl = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d", APPID];
    
    NSString *shareContent = [NSString stringWithFormat:@"%@%@",ShareContent, sharUrl];
    if(type == ShareTypeFacebook) shareContent = @"";// 用于Facebook 审核
    id<ISSContent> publishContent;
    //    kString(@"分享")
    if (url)
        publishContent = [ShareSDK content:url defaultContent:nil image:[ShareSDK pngImageWithImage:shareimage] title:title ? title:[DFD getIOSName]  url: url description:  url  mediaType:SSPublishContentMediaTypeNews];
    else
        publishContent = [ShareSDK content:shareContent defaultContent:nil image:[ShareSDK pngImageWithImage:shareimage] title:title ? title: [DFD getIOSName] url: ShareUrl description: shareContent mediaType:SSPublishContentMediaTypeImage];
    
    if (ShareTypeSinaWeibo == type)
    {
        [ShareSDK clientShareContent:publishContent type:type statusBarTips:YES result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
            if (state == SSPublishContentStateSuccess)
            {
                NSLog(@"分享成功!");
            }
            else if (state == SSPublishContentStateFail)
            {
                NSLog(@"分享失败! - %ld-- %@",(long)[error errorCode], [error errorDescription]);
            }
        }];
        return;
    }
    //    else
    //    {
    //        [ShareSDK showShareViewWithType:type
    //                              container:nil
    //                                content:publishContent
    //                          statusBarTips:YES
    //                            authOptions:nil
    //                           shareOptions:nil
    //                                 result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end)
    //        {
    //            //如果分享成功
    //            if (state == SSResponseStateSuccess)
    //            {
    //                NSLog(@"分享成功");
    //                MBHide;
    //                LMBShowSuccess(@"分享成功");
    //
    //            }
    //            //如果分享失败
    //            if (state == SSResponseStateFail)
    //            {
    //                NSLog(@"%@", [NSString stringWithFormat:@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]]);
    //            }
    //            if (state == SSResponseStateCancel)
    //            {
    //                NSLog(@"分享取消");
    //                MBHide;
    //            }
    //        }];
    //    }
    
    
    //1、构造分享内容
    //1.1、要分享的图片（以下分别是网络图片和本地图片的生成方式的示例）
    //    id<ISSCAttachment> remoteAttachment = [ShareSDKCoreService attachmentWithUrl:@"http://f.hiphotos.bdimg.com/album/w%3D2048/sign=df8f1fe50dd79123e0e09374990c5882/cf1b9d16fdfaaf51e6d1ce528d5494eef01f7a28.jpg"];
    //    //    id<ISSCAttachment> localAttachment = [ShareSDKCoreService attachmentWithPath:[[NSBundle mainBundle] pathForResource:@"shareImg" ofType:@"png"]];
    //
    
    //    //1.2、以下参数分别对应：内容、默认内容、图片、标题、链接、描述、分享类型
    //    id<ISSContent> publishContent = [ShareSDK content:@"test content of ShareSDK"
    //                                       defaultContent:nil
    //                                                image:remoteAttachment
    //                                                title:@"test title"
    //                                                  url:@"http://www.mob.com"
    //                                          description:nil
    //                                            mediaType:SSPublishContentMediaTypeNews];
    
    //1+创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:self.view arrowDirect:UIPopoverArrowDirectionUp];
    
    //2、展现分享编辑页面
    __block vcBase *blockSelf = (vcBase *)self;
    [ShareSDK showShareViewWithType:type
                          container:container
                            content:publishContent
                      statusBarTips:NO
                        authOptions:nil
                       shareOptions:nil
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 NSLog(@"=== response state :%zi ",state);
                                 MBHideInBlock;
                                 if (state == SSResponseStateSuccess)
                                 {
                                     NSLog(@"分享成功");
                                     LMBShowInBlock(@"分享成功");
                                 }
                                 else if (state == SSResponseStateFail)
                                 {
                                     NSLog(@"%@", [NSString stringWithFormat:@"分享失败,错误码:%ld,错误描述%@",(long)[error errorCode],[error errorDescription]]);
                                 }
                             }];
}

- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (void)CancelAuthWithAll
{
    [ShareSDK cancelAuthWithType:ShareTypeYiXinSession];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
    [ShareSDK cancelAuthWithType:ShareTypeQQ];
    [ShareSDK cancelAuthWithType:ShareTypeFacebook];
}

// 1: 微信  2 新浪微博 3 QQ 4 facebook  5 twitter
- (BOOL)isHave:(NSInteger)index
{
    switch (index) {
        case 1:
            if ([WXApi isWXAppInstalled])
                return YES;
            else
                return NO;
            break;
        case 2:
            if ([WeiboSDK isWeiboAppInstalled])
                return YES;
            else
                return NO;
            break;
        case 3:
            if ([QQApiInterface isQQInstalled])
                return YES;
            else
                return NO;
            
            break;
        case 4:
        {
            id<ISSFacebookApp> facebookApp =(id<ISSFacebookApp>)[ShareSDK getClientWithType:ShareTypeFacebook];
            [facebookApp setIsAllowWebAuthorize:YES];
            BOOL result =  [facebookApp isClientInstalled];
            return result;
        }
            
            break;
        case 5:                     //  这个 不准
        {
            id<ISSTwitterApp> twitterApp = (id<ISSTwitterApp>)[ShareSDK getClientWithType:ShareTypeTwitter];
            [twitterApp setSsoEnabled:YES];
            BOOL result = [twitterApp isClientInstalled];
            return result;
        }
            break;
            
        default:
            break;
    }
    return NO;
}

// 授权
-(void)getAccess:(int)shareType block:(void(^)())block cancel:(void(^)())cancelBlock
{
    ShareType type = [self turnByIndex:shareType];
    [ShareSDK authWithType:type options:nil result:^(SSAuthState state, id<ICMErrorInfo> error) {
        NSLog(@"state:%d, error:%@",state, error);
        if (state == SSAuthStateSuccess) {
            block();
        }
        else
        {
            cancelBlock();
        }
    }];
}

-(BOOL)checkAccess:(int)shareType
{
    ShareType type = [self turnByIndex:shareType];
    BOOL isHave = [ShareSDK hasAuthorizedWithType:type];
    return isHave;
}


// 第三方登录
- (void)loginByThird:(int)shareType block:(void(^)(NSArray *))block
{
    //     1：QQ空间 2：新浪微博 3：facebook 4: twitter
    ShareType type = [self turnByIndex:shareType];
    if (![self checkAccess:shareType])
    {
        [self getAccess:shareType block:^{
            [self postLogin:type block:block];
        } cancel:^{
            block(nil);
        }];
    }else
    {
        [self postLogin:type block:block];
    }
}

-(void)postLogin:(ShareType)type block:(void(^)(NSArray *))block
{
    [ShareSDK getUserInfoWithType:type
                      authOptions:nil
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error)
     {
         NSLog(@"result:%@, userInfo:%@, error:%@", @(result), userInfo, error);
         if(result)
         {
             NSLog(@"第三方ID:%@",userInfo.uid);
             //             NSLog(@"授权凭证%@",userInfo.credential);
             //             NSLog(@"token=%@",userInfo.credential.token);
             NSLog(@"昵称=%@",userInfo.nickname);
             NSLog(@"头像地址=%@",userInfo.profileImage);
             NSLog(@"性别(0男1女)=%@",@(userInfo.gender));
             NSArray *arr = @[userInfo.uid,userInfo.nickname,userInfo.profileImage,@(userInfo.gender)];
             block(arr);
         }
         else
         {
             block(nil);
         }
     }];
}

-(ShareType)turnByIndex :(int)shareType
{
    ShareType type = 0;
    switch (shareType) {
        case 1:
            type = ShareTypeQQSpace;  // 授权 使用 QQ空间
            break;
        case 2:
            type = ShareTypeSinaWeibo;
            break;
        case 3:
            type = ShareTypeFacebook;
            break;
        case 4:
            type = ShareTypeTwitter;
            break;
            
        default:
            break;
    }
    return type;
}

// 清除已经存在的第三方登陆信息
-(void)clearDataFrom3Class
{
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
    [ShareSDK cancelAuthWithType:ShareTypeTwitter];
    [ShareSDK cancelAuthWithType:ShareTypeFacebook];
}


@end
