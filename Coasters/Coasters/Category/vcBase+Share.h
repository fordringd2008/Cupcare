//
//  vcBase+Share.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/21.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcBase (Share) <UIActionSheetDelegate>

/**
 *  调用分享功能
 *
 *  @param shareType 1： 微信好友  2： 微信朋友圈 3：新浪微博 4：QQ空间 5：qq好友  6：facebook 7: 推特
 *  分享的链接  如果为nil  则分享截屏
 */
-(void)share:(NSInteger)shareType url:(NSString *)url title:(NSString *)title;

/**
 *  截频
 *
 *  @param theView 所在的视图
 *
 *  @return 截好的图片
 */
- (UIImage *)imageFromView:(UIView *)theView;



// 清除权限
+ (void)CancelAuthWithAll;

// 判断是否安装了 // 1: 微信  2 新浪微博 3 QQ 4 facebook  5 twitter
- (BOOL)isHave:(NSInteger)index;

- (void)loginByThird:(int)shareType block:(void(^)(NSArray *))block;

// 清除已经存在的第三方登陆信息
-(void)clearDataFrom3Class;

@end
