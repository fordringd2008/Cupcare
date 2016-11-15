//
//  aLiNet.h
//  aerocom
//
//  Created by 丁付德 on 15/7/9.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSService.h>

#define UploadBiggestKB     50               // 最大上传KB
#define ALIendPoint         @"http://oss-cn-shenzhen.aliyuncs.com"
#define BucketName          @"cupcare-user-pic"


@protocol aLiNetDelegate <NSObject>

-(void)upload:(BOOL)isOver url:(NSString *)url;

@end

@interface aLiNet : NSObject

@property (nonatomic, assign)    id<aLiNetDelegate>    delegate;

- (void)initAndupload:(UIImage *)image dic:(NSDictionary *)dic;

@end
