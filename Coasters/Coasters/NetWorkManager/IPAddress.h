//
//  IPAddress.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#ifndef WuLiuNoProblem_IPAddress_h
#define WuLiuNoProblem_IPAddress_h

// IP (纯IP)

// IP 地址 (外网)
#define IP @"http://www.sz-hema.net/"
//#define IP @"http://120.25.212.156/"

#define isHttps                    0   // 是否支持 https

#define _URL_Head                  @"cupcare/"

#define _URL(_k)                   [NSString stringWithFormat:@"%@%@%@",IP, _URL_Head, _k]

#define _URL_Head_1                @"hm/"

#define _URL_1(_k)                 [NSString stringWithFormat:@"%@%@%@",IP, _URL_Head_1, _k]

#define _ALI_URL                   [NSString stringWithFormat:@"http://plant-data.%@/", ALI_HostId]


#define login_URL                   _URL(@"login")                         // 登录

#define register_URL                _URL(@"register")                      // 注册

#define findPassword_URL            _URL(@"findPassword")                  // 找回密码

#define updatePassword_URL          _URL(@"updatePassword")                // 修改密码

#define updateDrinkData_URL         _URL(@"updateDrinkData")               // 上传喝水数据

#define getDrinkData_URL            _URL(@"getDrinkData")                  // 获取喝水数据

#define getDrinkRank_URL            _URL(@"getDrinkRank")                  // 获取用户日均喝水量排名

#define updateUserInfo_URL          _URL(@"updateUserInfo")                // 更新用户个人信息

#define getUserInfo_URL             _URL(@"getUserInfo")                   // 获取用户个人信息

#define applyFriend_URL             _URL(@"applyFriend")                   // 申请加好友

#define updateFriendship_URL        _URL(@"updateFriendship")              // 接受或者拒绝好友申请

#define getFriendsInfo_URL          _URL(@"getFriendsInfo")                // 获取好友列表信息

#define pushDrinkHint_URL           _URL(@"pushDrinkHint")                 // 提醒喝水，回复提醒接口

#define updateUserSys_URL           _URL(@"updateUserSys")                 // 更新系统设置

#define getUserSys_URL              _URL(@"getUserSys")                    // 获取系统设置

#define updateFeedback_URL          _URL(@"updateFeedback")                // 意见反馈

#define getTipsList_URL             _URL(@"getTipsList")                   // 获取小贴士列表

#define getTipInfoById_URL          _URL(@"getTipInfoById")                // 获取指定的小贴士内容

#define getFriendApplyList_URL      _URL(@"getFriendApplyList")            // 获取好友申请列表

#define getPushInfoList_URL         _URL(@"getPushInfoList")               // 获取推送消息列表

#define token_distribute_server_URL _URL(@"distribute-token.json")// token-distribute-server  (get)

#define pushLikeInfo_URL            _URL(@"pushLikeInfo")                  // 点赞接口

#define getTodayGlobalRank_URL      _URL(@"getTodayGlobalRank")            // 获取今日全球排行榜

#define getMyGroupInfo_URL          _URL(@"getMyGroupInfo")                //获取我的圈子信息

#define updateGroupInfo_URL         _URL(@"updateGroupInfo")               //创建/更新圈子基本信息

#define updateGroupNotice_URL       _URL(@"updateGroupNotice")             //更新圈子公告

#define getGroupMember_URL          _URL(@"getGroupMember")                //获取圈子成员信息

#define getTargetGroupInfo_URL      _URL(@"getTargetGroupInfo")            //获取目标圈子的信息

#define applyJoinGroup_URL          _URL(@"applyJoinGroup")                //申请加入圈子.推送

#define allowJoinGroup_URL          _URL(@"allowJoinGroup")  //圈主同意或拒绝加入圈子的申请--推送

#define pullUserInGroup_URL         _URL(@"pullUserInGroup")               //圈主拉好友进圈子--推送

#define getGroupApplyList_URL       _URL(@"getGroupApplyList")              //获取加入圈子的申请列表

#define deleteGroupMember_URL       _URL(@"deleteGroupMember")              //圈主删除圈子成员

#define exitGroup_URL               _URL(@"exitGroup")                      //成员退出圈子

#define deleteGroup_URL             _URL(@"deleteGroup")                    //圈主删除圈子




// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

#define register_URL_1              _URL_1(@"register")                    // 注册

#define findPassword_URL_1          _URL_1(@"findPassword")                // 找回密码

#define login_URL_1                 _URL_1(@"login")                       // 登陆

#define updatePassword_URL_1        _URL_1(@"updatePassword")              // 修改密码(邮箱修改)

#define registerByPhone_URL_1       _URL_1(@"registerByPhone")             // 手机号注册

#define updatePasswordByPhone_URL_1 _URL_1(@"updatePasswordByPhone")       // 手机号密码重置

#define loginByThird_URL_1          _URL_1(@"loginByThird")                // 第三方平台登录

#define getUserToken_URL_1          _URL_1(@"getUserToken")                // 获取用户token值

#define updatePushInfo_URL_1        _URL(@"updatePushInfo")                // 推送channelId上传

#define authPhoneExist_URL_1        _URL_1(@"authPhoneExist")              // 验证手机号是否已经注册






#endif
