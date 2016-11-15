//
//  vcBase.h
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BLEManager.h"
#import "NetManager.h"
#import "aLiNet.h"

@interface vcBase : UIViewController

@property (nonatomic, strong) AppDelegate *         appDelegate;
@property (nonatomic, strong) UIWindow *            windowView;
@property (nonatomic, strong) NSArray *             arrPush;          // 跨页面传值
@property (nonatomic, strong) UserInfo  *           userInfo;         // 当前用户
@property (nonatomic, assign) BOOL                  isPop;            // YES: 倒退  NO:显示左侧栏
@property (nonatomic, strong) BLEManager *          Bluetooth;        // 蓝牙单例对象
@property (nonatomic, strong) NSMutableDictionary * dicBLEFound;      // 蓝牙扫描到得外设
@property (nonatomic, strong) UIView              * ViewCover;        // 输入时的视图覆盖
@property (nonatomic, strong) UIVisualEffectView *  ViewEffectBody;   // 输入时的视图覆盖  里面的毛玻璃
@property (nonatomic, strong) UIVisualEffectView *  ViewEffectHead;   // 毛玻璃头部
@property (nonatomic, assign) BOOL                  isJumpLock;       // 跳转锁定      Yes  不能跳转  No 可以
@property (nonatomic, assign) BOOL                  isClickLock;      // 按钮的重复点击 Yes  不能点击  No 可以
@property (nonatomic ,assign) BOOL                  isLink;           // 当前是否连接上
@property (nonatomic, assign) BOOL                  isFirstLink;      // 是否是第一次连接  （绑定时）
@property (nonatomic, strong) aLiNet *              alinet;           //

@property (nonatomic, strong) UIImage *             image;            // 待上传的图片
@property (nonatomic, assign) BOOL                  isUpdataPhoto;    // 上传图片是否有结果回调（可能成功，可能失败）

@property (nonatomic, assign) BOOL                  isReadBLEBack;    // 同步完成
@property (nonatomic, assign) BOOL                  isReadBLEChange;  // SynData  数据有更新
@property (nonatomic, copy)   void                  (^upLoad_Next)(NSString *url); // 上传图片后的操作


-(void)clearLocalData;                                                  // 退出登录的清理

-(void)initLeftButton:(NSString *)imgName text:(NSString *)text;
-(void)initRightButton:(NSString *)imgName text:(NSString *)text;

-(void)back;

-(void)rightButtonClick;

-(void)gotoMainStoryBoard;

-(void)gotoLoginStoryBoard:(NSString *)storyName;

-(void)setSideslip:(BOOL)isSlip;                                       // 设置是否开启侧滑

-(void)resetBLEDelegate;                                               // 重置蓝牙代理

-(void)getTokenAndUpload;                                               // 先获取权限， 然后上传


// ------------------------------------------------------  蓝牙相关操作

-(void)Found_Next:(NSMutableDictionary *)recivedTxt;                   // 发现回调后的 接下来操作，   --  用来重写
-(void)Conneted_Next:(NSString *)uuidString;                           // 连接上后 接下来操作，      --  用来重写
-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj;//           --   用来重写
-(void)CallBack_Data_Next:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj;
-(void)setNavTitle:(UIViewController *)vc title:(NSString *)title;
-(void)setWaterRemind:(int)type isWork:(BOOL)isWork obj:(id)obj;       // 设置 喝水提醒
-(void)bindJPush:(BOOL)isBind;
-(void)setSMSInterval;
-(int)getSMSInterval;
-(void)changeNavigationBar:(UIColor *)color;        // 改变导航条的颜色

-(void)initViewCover:(CGFloat)toolViewHeight;
-(void)showViewCover;                               // 显示覆盖图层，完成后执行block



@end
