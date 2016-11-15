//
//  Engine.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetManager : NSObject
@property (nonatomic, assign) AFNetworkReachabilityStatus netStatus;

@property (nonatomic, copy) void (^responseSuccessDic)(NSDictionary *dic);
@property (nonatomic, copy) void (^requestFailError)(NSError *error);

+(void)observeNet;                                                                              // 监视网络

+(void)DF_requestWithAction:(void(^)(NetManager *net))action            // 发起请求
                    success:(void(^)(NSDictionary *dic))success         // 成功的回调
                  failError:(void(^)(NSError *erro))failError           // 失败的回调中的用户行为
                     inView:(UIView *)inView                            // 要展示错误的容器(不能为nil)
                isShowError:(BOOL)isShowError;                          // 是否展示错误

// ----------------------------------------------------------------------// 上传喝水数据
-(void)updateDrinkData:(NSString *)access
            drink_data:(NSString *)drink_data
             drink_num:(NSString *)drink_num;

// ----------------------------------------------------------------------// 获取喝水数据
-(void)getDrinkData:(NSString *)access
            user_id:(NSString *)user_id
        k_date_from:(int)k_date_from
          k_date_to:(int)k_date_to;


// ----------------------------------------------------------------------// 获取用户日均喝水量排名
-(void)getDrinkRank:(NSString *)access
      day_water_num:(NSInteger)day_water_num;

// ----------------------------------------------------------------------// 更新用户个人信息
-(void)updateUserInfo:(NSDictionary *)dic;

// ----------------------------------------------------------------------// 获取用户个人信息
-(void)getUserInfo:(NSString *)access;


// ----------------------------------------------------------------------// 获取好友列表信息
-(void)getFriendsInfo:(NSString *)access
         today_k_date:(NSNumber *)today_k_date;


// ----------------------------------------------------------------------// 更新系统设置
-(void)updateSysSetting:(NSString *)access
               sys_unit:(BOOL)sys_unit
      sys_notify_status:(BOOL)sys_notify_status;

// ----------------------------------------------------------------------// 获取系统设置
-(void)getUserSys:(NSString *)access;


// ----------------------------------------------------------------------//获取好友申请列表
-(void)getFriendApplyList:(NSString *)access;

// ----------------------------------------------------------------------//获取推送消息列表
-(void)getPushInfoList:(NSString *)access
                  time:(long long)time;

// ----------------------------------------------------------------------// 意见反馈
-(void)updateFeedback:(NSString *)access
              content:(NSString *)content;

// ----------------------------------------------------------------------// 获取小贴士列表
-(void)getTipsList:(NSString *)access
     language_code:(NSString *)language_code
          page_num:(NSInteger)page_num;


// ----------------------------------------------------------------------// token-distribute-server
-(void)getToken_distribute_server:(NSString *)access;

// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------// 邮箱注册
-(void)registerByEmail:(NSString *)email
              password:(NSString *)password;

// ----------------------------------------------------------------------// 邮箱找回密码
-(void)findPasswordByEmail:(NSString *)email;

// ----------------------------------------------------------------------// 登陆
-(void)login:(NSString *)account
          type:(int)type
      password:(NSString *)password;

// ----------------------------------------------------------------------// 邮箱修改密码
-(void)updatePasswordByEmail:(NSString *)email
                         old:(NSString *)old
                         new:(NSString *)neW;

// ----------------------------------------------------------------------// 手机号注册
-(void)registerByPhone:(NSString *)phone
              areaCode:(NSString *)areaCode
              authCode:(NSString *)authCode
              password:(NSString *)password;

// ----------------------------------------------------------------------// 手机号密码重置
-(void)updatePasswordByPhone:(NSString *)phone
                    areaCode:(NSString *)areaCode
                    authCode:(NSString *)authCode
                    password:(NSString *)password;

// ----------------------------------------------------------------------// 第三方平台登录
-(void)loginByThird:(NSString *)typeID
                type:(int)type;

// ----------------------------------------------------------------------// 获取用户token值
-(void)getUserToken:(NSString *)access;


//// ----------------------------------------------------------------------// 推送channelId上传
//-(void)updatePushInfo:(NSString *)access
//            channelID:(NSString *)channelID;


// ----------------------------------------------------------------------// 验证手机号是否已经注册
-(void)authPhoneExist:(NSString *)phone
             areaCode:(NSString *)areaCode;

// ----------------------------------------------------------------------// 申请加好友
-(void)applyFriend:(NSString *)access
    friend_account:(NSString *)friend_account
friend_account_type:(NSString *)friend_account_type
    push_content:(NSString *)push_content;

// ----------------------------------------------------------------------// 接受或者拒绝好友申请
-(void)updateFriendship:(NSString *)access
              friend_id:(NSString *)friend_id
            ship_status:(NSString *)ship_status
              nick_name:(NSString *)nick_name;

// ----------------------------------------------------------------------// 提醒喝水，回复提醒接口
-(void)pushDrinkHint:(NSString *)access
                type:(NSString *)type
           friend_id:(NSString *)friend_id
             content:(NSString *)content;

// ----------------------------------------------------------------------// 点赞接口
-(void)pushLikeInfo:(NSString *)access
               type:(int)type
          friend_id:(NSString *)friend_id
       today_k_date:(int)today_k_date;

// ----------------------------------------------------------------------// 获取今日全球排行榜
-(void)getTodayGlobalRank:(NSString *)access
             today_k_date:(int)today_k_date;

// ----------------------------------------------------------------------// 获取我的圈子信息
-(void)getMyGroupInfo:(NSString *)access
    user_country_code:(NSString *)user_country_code
      user_state_code:(NSString *)user_state_code
       user_city_code:(NSString *)user_city_code;

// ----------------------------------------------------------------------// 新增/修改圈子信息
-(void)updateGroupInfo:(NSString *)access
              group_id:(NSString *)group_id
         group_pic_url:(NSString *)group_pic_url
            group_name:(NSString *)group_name
    group_country_code:(NSString *)group_country_code
      group_state_code:(NSString *)group_state_code
       group_city_code:(NSString *)group_city_code;

// ----------------------------------------------------------------------// 更新圈子公告
-(void)updateGroupNotice:(NSString *)access
                group_id:(NSString *)group_id
            group_notice:(NSString *)group_notice;

// ----------------------------------------------------------------------// 获取圈子成员信息
-(void)getGroupMember:(NSString *)access
                group_id:(NSString *)group_id
            today_k_date:(NSString *)today_k_date
            month_k_date:(NSString *)month_k_date;

// ----------------------------------------------------------------------// 获取目标圈子的信息
-(void)getTargetGroupInfo:(NSString *)access
                 group_id:(NSString *)group_id;


//----------------------------------------------------------------------// 申请加入圈子.推送
-(void)applyJoinGroup:(NSString *)access
             group_id:(NSString *)group_id;

// ---------------------------------------------------------// 圈主同意或拒绝加入圈子的申请--推送
-(void)allowJoinGroup:(NSString *)access
         apply_userid:(NSString *)apply_userid
             group_id:(NSString *)group_id
         allow_status:(BOOL)allow_status;

// ----------------------------------------------------------------------// 圈主拉好友进圈子--推送
-(void)pullUserInGroup:(NSString *)access
            pull_users:(NSString *)pull_users
              group_id:(NSString *)group_id;


// ----------------------------------------------------------------------// 获取加入圈子的申请列表
-(void)getGroupApplyList:(NSString *)access;


//----------------------------------------------------------------------// 圈主删除圈子成员
-(void)deleteGroupMember:(NSString *)access
                group_id:(NSString *)group_id
                  userid:(NSString *)userid;

// ---------------------------------------------------------------------// 成员退出圈子
-(void)exitGroup:(NSString *)access
        group_id:(NSString *)group_id;

// ----------------------------------------------------------------------// 圈主删除圈子
-(void)deleteGroup:(NSString *)access
          group_id:(NSString *)group_id;





//-(void)testHttps:(id)ob;



@end

