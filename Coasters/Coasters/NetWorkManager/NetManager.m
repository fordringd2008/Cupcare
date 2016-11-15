//
//  Engine.m
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "NetManager.h"
#import "IPAddress.h"
#import "SecurityUtil.h"

static NSDictionary *NetMangerErrorCode;

@implementation NetManager


-(instancetype)init
{
    self = [super init];
    if (self) {
        if (!NetMangerErrorCode) NetMangerErrorCode = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NetMangerErrorCode" ofType:@"plist"]];
    }
    return  self;
}

-(void)request:(NSString *)urlStr aDic:(NSDictionary *)dic isPost:(BOOL)isPost
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer    = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"charset=UTF-8", @"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    __block NetManager *blockSelf= self;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:(isPost?@"POST":@"GET") URLString:urlStr parameters:dic error:nil];
    request.timeoutInterval = 20;
    NSURLSessionDataTask *op = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * response, NSDictionary *responseObject, NSError * error) {
        if(error == nil)
        {
            NSLog(@"post_back->%@", responseObject);
            NSString *status = [((NSDictionary *)responseObject)[@"status"] description];
            if ([NetMangerErrorCode.allKeys containsObject:status]) {
                NSLog(@"--- 收到异常:%@", NetMangerErrorCode[status]);
            }else{
                blockSelf.responseSuccessDic(responseObject);
            }
        }else{
            blockSelf.requestFailError(error);
        }
    }];
    [op resume];
}

- (void)getRequestWithUrlStr:(NSString *)urlStr
{
    NSLog(@"get -> :%@", urlStr);
    [self request:urlStr aDic:nil isPost:NO];
}

- (void)postRequestWithUrlStr:(NSString *)urlStr aDic:(NSDictionary *)dic
{
    NSLog(@"post -> :%@, 参数:%@", urlStr, dic);
    [self request:urlStr aDic:dic isPost:YES];
}

+(void)DF_requestWithAction:(void(^)(NetManager *net))action
                    success:(void(^)(NSDictionary *dic))success
                  failError:(void(^)(NSError *erro))failError
                     inView:(UIView *)inView
                isShowError:(BOOL)isShowError
{
    NetManager *netManager = [[NetManager alloc] init];
    netManager.responseSuccessDic = success;
    __block UIView *blockView = inView;
    netManager.requestFailError = ^(NSError *erro){
        [MBProgressHUD hideAllHUDsForView:blockView animated:YES];
        if(isShowError) [MBProgressHUD show:kString(NONetTip) toView:blockView];
        NSLog(@"%@\n error:%@", NONetTip, erro);
        failError(erro);
    };
    action(netManager);
}


+(void)observeNet
{
    SetUserDefault(DNet, @1);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
             case AFNetworkReachabilityStatusUnknown:
             {
                 SetUserDefault(DNet, @0);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 未知");
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
                 SetUserDefault(DNet, @2);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 2G/3G/4G");
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
             {
                 SetUserDefault(DNet, @1);
                 NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 当前网络为 WIFI");
             }
         }
     }];
}


// 对传进的参数进行加码处理
-(NSString *)encode:(NSString *)string
{
    NSString *str=  (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) string,NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return str;
}

-(void)get_finally:(NSString *)string
{
    NSString *url = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self getRequestWithUrlStr:url];
}

-(NSString *)ToUTF8:(NSString *)string
{
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// ----------------------------------------------------------------------// 上传喝水数据
-(void)updateDrinkData:(NSString *)access
            drink_data:(NSString *)drink_data
             drink_num:(NSString *)drink_num
{
    if (!access || !drink_data || !drink_num) return;
    NSDictionary *dic = @{@"access":access,
                          @"drink_data":drink_data,
                          @"drink_num":drink_num};
    [self postRequestWithUrlStr:updateDrinkData_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取喝水数据
-(void)getDrinkData:(NSString *)access
            user_id:(NSString *)user_id
        k_date_from:(int)k_date_from
          k_date_to:(int)k_date_to
{
    if (!access) return;
    NSDictionary *dic;
    if (user_id)
    {
        dic = @{@"access":access,
              @"user_id":user_id,
              @"k_date_from":[NSString stringWithFormat:@"%d", k_date_from],
              @"k_date_to":[NSString stringWithFormat:@"%d", k_date_to]};
    }
    else
    {
        dic = @{@"access":access,
              @"k_date_from":[NSString stringWithFormat:@"%d", k_date_from],
              @"k_date_to":[NSString stringWithFormat:@"%d", k_date_to]};
    }
    [self postRequestWithUrlStr:getDrinkData_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取用户日均喝水量排名
-(void)getDrinkRank:(NSString *)access
      day_water_num:(NSInteger)day_water_num
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,
                          @"water_day_num":@(day_water_num)};
    [self postRequestWithUrlStr:getDrinkRank_URL aDic:dic];
}

// ----------------------------------------------------------------------// 更新用户个人信息
-(void)updateUserInfo:(NSDictionary *)dic
{
    [self postRequestWithUrlStr:updateUserInfo_URL aDic:({
        NSMutableDictionary *dicMut = [dic mutableCopy];
        [dicMut setObject:[NSString stringWithFormat:@"%02d", [DFD getLanguage]] forKey:@"user_language_code"];
        dicMut;
    })];
}

// ----------------------------------------------------------------------// 获取用户个人信息
-(void)getUserInfo:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------// 获取好友列表信息
-(void)getFriendsInfo:(NSString *)access
         today_k_date:(NSNumber *)today_k_date
{
    if (!access || !today_k_date) return;
    NSDictionary *dic = @{@"access":access,
                          @"today_k_date": today_k_date};
    [self postRequestWithUrlStr:getFriendsInfo_URL aDic:dic];
}


// ----------------------------------------------------------------------// 更新系统设置
-(void)updateSysSetting:(NSString *)access
               sys_unit:(BOOL)sys_unit
      sys_notify_status:(BOOL)sys_notify_status
{
    if (!access) return;
    NSDictionary *dic = @{ @"access": access,
                           @"sys_unit": (sys_unit ? @"01" : @"02"),
                           @"sys_notify_status": (sys_notify_status ? @"0" : @"1"), };
    [self postRequestWithUrlStr:updateUserSys_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取系统设置
-(void)getUserSys:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserSys_URL aDic:dic];
}

// ----------------------------------------------------------------------// 意见反馈
-(void)updateFeedback:(NSString *)access
              content:(NSString *)content
{
    if (!access || !content) return;
    NSDictionary *dic = @{@"access":access,
                          @"content":content};
    [self postRequestWithUrlStr:updateFeedback_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取小贴士列表
-(void)getTipsList:(NSString *)access
     language_code:(NSString *)language_code
          page_num:(NSInteger)page_num
{
    if (!access || !language_code) return;
    NSDictionary *dic = @{@"access":access,
                          @"language_code":language_code,
                          @"page_num":@(page_num),
                          @"page_count":@(TipsListPangeCount)};
    [self postRequestWithUrlStr:getTipsList_URL aDic:dic];
}

// ----------------------------------------------------------------------//获取好友申请列表
-(void)getFriendApplyList:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @ {@"access":access };
    [self postRequestWithUrlStr:getFriendApplyList_URL aDic:dic];
}

// ----------------------------------------------------------------------//获取推送消息列表
-(void)getPushInfoList:(NSString *)access
                  time:(long long)time
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,
                          @"time":@(time)};
    [self postRequestWithUrlStr:getPushInfoList_URL aDic:dic];
}

// ----------------------------------------------------------------------// token-distribute-server
-(void)getToken_distribute_server:(NSString *)access
{
    if (!access) return;
    NSString *url = [NSString stringWithFormat:@"%@?user-name=%@", token_distribute_server_URL, access];
    [self get_finally:url];
}

// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------// 邮箱注册
-(void)registerByEmail:(NSString *)email
              password:(NSString *)password
{
    if (!email || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"email":email,
                          @"password":password};
    [self postRequestWithUrlStr:register_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 邮箱找回密码
-(void)findPasswordByEmail:(NSString *)email
{
    if (!email) return;
    NSDictionary *dic = @{@"email":email};
    [self postRequestWithUrlStr:findPassword_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 登陆
-(void)login:(NSString *)account
        type:(int)type
    password:(NSString *)password
{
    if (!account || !type || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"account":account,
                          @"type":(type == 1 ? @"01" : @"02"),
                          @"password":password};
    [self postRequestWithUrlStr:login_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 邮箱修改密码
-(void)updatePasswordByEmail:(NSString *)email
                         old:(NSString *)old
                         new:(NSString *)neW
{
    if (!email || !old || !neW) return;
    NSDictionary *dic = @{@"email":email,
                          @"old_password":old,
                          @"new_password":neW};
    old = [SecurityUtil encryptAES:old];
    neW = [SecurityUtil encryptAES:neW];
    [self postRequestWithUrlStr:updatePassword_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 手机号注册
-(void)registerByPhone:(NSString *)phone
                areaCode:(NSString *)areaCode
                authCode:(NSString *)authCode
                password:(NSString *)password
{
    if (!phone || !areaCode || !authCode || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"app_key":SMSAppKey,
                          @"phone":phone,
                          @"area_code":areaCode,
                          @"auth_code":authCode,
                          @"phone_password":password};
    [self postRequestWithUrlStr:registerByPhone_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 手机号密码重置
-(void)updatePasswordByPhone:(NSString *)phone
                    areaCode:(NSString *)areaCode
                    authCode:(NSString *)authCode
                    password:(NSString *)password
{
    if (!phone || !areaCode || !authCode || !password) return;
    password = [SecurityUtil encryptAES:password];
    NSDictionary *dic = @{@"app_key":SMSAppKey,
                          @"phone":phone,
                          @"area_code":areaCode,
                          @"auth_code":authCode,
                          @"phone_password":password};
    [self postRequestWithUrlStr:updatePasswordByPhone_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 第三方平台登录
-(void)loginByThird:(NSString *)typeID
               type:(int)type
{
    if (!typeID || !type) return;
    NSDictionary *dic = @{@"third_party_id":typeID,
                          @"third_type":[NSString stringWithFormat:@"0%d", type]};
    [self postRequestWithUrlStr:loginByThird_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 获取用户token值
-(void)getUserToken:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getUserToken_URL_1 aDic:dic];
}
//
//// ----------------------------------------------------------------------// 推送channelId上传
//-(void)updatePushInfo:(NSString *)access
//            channelID:(NSString *)channelID
//{
//    if (!access || !channelID) return;
//    NSDictionary *dic = @{@"access":access,
//                          @"channel_id":channelID,
//                          @"device_type":@"4",
//                          @"ios_deploy_status":(isDevelemont ? @"1":@"2")};
//    [self postRequestWithUrlStr:updatePushInfo_URL_1 aDic:dic];
//}

// ----------------------------------------------------------------------// 验证手机号是否已经注册
-(void)authPhoneExist:(NSString *)phone
             areaCode:(NSString *)areaCode
{
    if (!phone || !areaCode) return;
    NSDictionary *dic = @{@"phone":phone,
                          @"area_code":areaCode,
                          @"app_key":SMSAppKey};
    [self postRequestWithUrlStr:authPhoneExist_URL_1 aDic:dic];
}

// ----------------------------------------------------------------------// 申请加好友
-(void)applyFriend:(NSString *)access
      friend_account:(NSString *)friend_account
 friend_account_type:(NSString *)friend_account_type
        push_content:(NSString *)push_content
{
    if (!access || !friend_account || !friend_account_type || !push_content) return;
    NSDictionary *dic = @{@"access":access,
                          @"friend_account":friend_account,
                          @"friend_account_type":friend_account_type,
                          @"push_content":push_content,
                          @"app_name":AppNameForServer,
                          @"version": @"20" };
    [self postRequestWithUrlStr:applyFriend_URL aDic:dic];
}

// ----------------------------------------------------------------------// 接受或者拒绝好友申请
-(void)updateFriendship:(NSString *)access
              friend_id:(NSString *)friend_id
            ship_status:(NSString *)ship_status
              nick_name:(NSString *)nick_name
{
    if (!access || !friend_id || !ship_status || !nick_name) return;
    
    NSString * push_content = [NSString stringWithFormat:@"%@ %@",nick_name, [ship_status isEqualToString:@"1"] ? kString(@"接受了你的好友申请") : kString(@"拒绝了你的好友申请")];
    NSDictionary *dic = @{@"access":access,
                          @"friend_id":friend_id,
                          @"ship_status":ship_status,
                          @"push_content":push_content,
                          @"app_name":AppNameForServer,
                          @"version": @"20"};
    /*
     ,
     @"device_type":@"4",
     @"ios_deploy_status":(isDevelemont ? @"1":@"2")
     */
    
    [self postRequestWithUrlStr:updateFriendship_URL aDic:dic];
}

// ----------------------------------------------------------------------// 提醒喝水，回复提醒接口
-(void)pushDrinkHint:(NSString *)access
                type:(NSString *)type
            friend_id:(NSString *)friend_id
              content:(NSString *)content
{
    if (!access || !type || !friend_id || !content) return;
    NSDictionary *dic = @{@"access":access,
                          @"type":type,
                          @"friend_id":friend_id,
                          @"hint_content":content,
                          @"app_name":AppNameForServer,
                          @"version":@"20"};
    [self postRequestWithUrlStr:pushDrinkHint_URL aDic:dic];
}

// ----------------------------------------------------------------------// 点赞接口
-(void)pushLikeInfo:(NSString *)access
               type:(int)type
          friend_id:(NSString *)friend_id
       today_k_date:(int)today_k_date
{
    if (!access || !friend_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"type": @(type),
                          @"friend_id": friend_id,
                          @"today_k_date": @(today_k_date),
                          @"app_name": AppNameForServer
                          };
    [self postRequestWithUrlStr:pushLikeInfo_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取今日全球排行榜
-(void)getTodayGlobalRank:(NSString *)access
             today_k_date:(int)today_k_date
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access,
                          @"today_k_date": @(today_k_date)};
    [self postRequestWithUrlStr:getTodayGlobalRank_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取我的圈子信息
-(void)getMyGroupInfo:(NSString *)access
    user_country_code:(NSString *)user_country_code
      user_state_code:(NSString *)user_state_code
       user_city_code:(NSString *)user_city_code
{
    if (!access || !user_country_code || !user_state_code || !user_city_code) return;
    NSDictionary *dic = @{@"access":access,
                          @"user_country_code":user_country_code,
                          @"user_state_code":user_state_code,
                          @"user_city_code": user_city_code};
    [self postRequestWithUrlStr:getMyGroupInfo_URL aDic:dic];
}

// ----------------------------------------------------------------------// 新增/修改圈子信息
-(void)updateGroupInfo:(NSString *)access
              group_id:(NSString *)group_id
         group_pic_url:(NSString *)group_pic_url
            group_name:(NSString *)group_name
    group_country_code:(NSString *)group_country_code
      group_state_code:(NSString *)group_state_code
       group_city_code:(NSString *)group_city_code
{
    if (!access || !group_id || !group_pic_url || !group_name || !group_country_code || !group_state_code || !group_city_code) return;
    NSDictionary *dic = @{@"access":access,
                        @"group_id":group_id,
                          @"group_pic_url":group_pic_url,
                          @"group_name": group_name,
                          @"group_country_code": group_country_code,
                          @"group_state_code": group_state_code,
                          @"group_city_code": group_city_code};
    
    [self postRequestWithUrlStr:updateGroupInfo_URL aDic:dic];
}

// ----------------------------------------------------------------------// 更新圈子公告
-(void)updateGroupNotice:(NSString *)access
                group_id:(NSString *)group_id
            group_notice:(NSString *)group_notice
{
    if (!access || !group_id || !group_notice) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id,
                          @"group_notice":group_notice};
    [self postRequestWithUrlStr:updateGroupNotice_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取圈子成员信息
-(void)getGroupMember:(NSString *)access
             group_id:(NSString *)group_id
         today_k_date:(NSString *)today_k_date
         month_k_date:(NSString *)month_k_date
{
    if (!access || !group_id || !today_k_date || !month_k_date) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id,
                          @"today_k_date":today_k_date,
                          @"month_k_date":month_k_date};
    [self postRequestWithUrlStr:getGroupMember_URL aDic:dic];
}

// ----------------------------------------------------------------------// 获取目标圈子的信息
-(void)getTargetGroupInfo:(NSString *)access
                 group_id:(NSString *)group_id
{
    if (!access || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id};
    [self postRequestWithUrlStr:getTargetGroupInfo_URL aDic:dic];
}

//----------------------------------------------------------------------// 申请加入圈子.推送
-(void)applyJoinGroup:(NSString *)access
             group_id:(NSString *)group_id
{
    if (!access || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id,
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:applyJoinGroup_URL aDic:dic];
}

// ---------------------------------------------------------// 圈主同意或拒绝加入圈子的申请--推送
-(void)allowJoinGroup:(NSString *)access
         apply_userid:(NSString *)apply_userid
             group_id:(NSString *)group_id
         allow_status:(BOOL)allow_status
{
    if (!access || !apply_userid || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"apply_userid":apply_userid,
                          @"group_id":group_id,
                          @"allow_status":allow_status?@"1":@"2",
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:allowJoinGroup_URL aDic:dic];
}

// ----------------------------------------------------------------------// 圈主拉好友进圈子--推送
-(void)pullUserInGroup:(NSString *)access
            pull_users:(NSString *)pull_users
              group_id:(NSString *)group_id
{
    if (!access || !pull_users || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"pull_users":pull_users,
                          @"group_id":group_id,
                          @"app_name":AppNameForServer};
    [self postRequestWithUrlStr:pullUserInGroup_URL aDic:dic];
}


// ----------------------------------------------------------------------// 获取加入圈子的申请列表
-(void)getGroupApplyList:(NSString *)access
{
    if (!access) return;
    NSDictionary *dic = @{@"access":access};
    [self postRequestWithUrlStr:getGroupApplyList_URL aDic:dic];
}


//----------------------------------------------------------------------// 圈主删除圈子成员
-(void)deleteGroupMember:(NSString *)access
                group_id:(NSString *)group_id
                  userid:(NSString *)userid
{
    if (!access || !group_id || !userid) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id,
                          @"userid":userid};
    [self postRequestWithUrlStr:deleteGroupMember_URL aDic:dic];
}

// ---------------------------------------------------------------------// 成员退出圈子
-(void)exitGroup:(NSString *)access
        group_id:(NSString *)group_id
{
    if (!access || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id};
    [self postRequestWithUrlStr:exitGroup_URL aDic:dic];
}

// ----------------------------------------------------------------------// 圈主删除圈子
-(void)deleteGroup:(NSString *)access
          group_id:(NSString *)group_id
{
    if (!access || !group_id) return;
    NSDictionary *dic = @{@"access":access,
                          @"group_id":group_id};
    [self postRequestWithUrlStr:deleteGroup_URL aDic:dic];
}

//
//
//-(void)testHttps:(id)ob
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer    = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/plain", @"charset=UTF-8", @"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//    
//    
//    
//    if (1)
//    {
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        
//        
//        [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//        [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
//        
//        manager.securityPolicy = ({
//            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//            securityPolicy.validatesDomainName = NO;
//            securityPolicy.allowInvalidCertificates = YES;
//            securityPolicy;
//        });
//        
//    }else{
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        
//        
//        
//    }
//    manager.requestSerializer.timeoutInterval = 10;
//    
//    __weak NetManager *blockSelf= self;
//    [manager POST:@"https://218.17.125.59:8787/api/AppCustContactinfo/UpdateData" parameters:ob progress:^(NSProgress * _Nonnull uploadProgress)
//     {
//         NSLog(@"uploadProgress : %@", uploadProgress);
//     }
//          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
//     {
//         NSLog(@"back->%@", responseObject);
//         //blockSelf.responseSuccessDic(responseObject);
//     }
//          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
//     {
//         NSLog(@"%@", error);
//         //blockSelf.requestFailError(error);
//     }];
//    
//}
//


@end
