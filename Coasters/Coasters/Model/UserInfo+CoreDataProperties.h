//
//  UserInfo+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 15/11/12.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;           // 权限
@property (nullable, nonatomic, retain) NSString *token;            // token 验证登录，如改变，用户需重新登录
@property (nullable, nonatomic, retain) NSString *account;          // 邮箱 也可能是 手机号 或者 第三方登陆ID
@property (nullable, nonatomic, retain) NSNumber *loginType;        // 0 邮箱 1 手机 2 QQ 3 新浪 4face 5 twitt
@property (nullable, nonatomic, retain) NSString *logo;             // 头像
@property (nullable, nonatomic, retain) NSNumber *noDisturbEnd;     // 勿扰结束时间
@property (nullable, nonatomic, retain) NSNumber *noDisturbStart;   // 勿扰起始时间
@property (nullable, nonatomic, retain) NSData   *orData;           // 二维码图片
@property (nullable, nonatomic, retain) NSString *password;         // 密码
@property (nullable, nonatomic, retain) NSString *area_code;        // 国家电话前缀 非手机号登陆为空字符串
@property (nullable, nonatomic, retain) NSString *phoneNumber;      // 电话号码
@property (nullable, nonatomic, retain) NSString *pName;            // 外设名称
@property (nullable, nonatomic, retain) NSString *pUUIDString;      // 外设UUIDString
@property (nullable, nonatomic, retain) NSNumber *rank;             // 世界喝水量总排名
@property (nullable, nonatomic, retain) NSNumber *swithAcceptPush;  // 是否接受推送   BOOL 类型            舍弃
@property (nullable, nonatomic, retain) NSNumber *swithLight;       // 外设灯光开光   BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *swithNoDisturb;   // 勿扰开关      BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *swithSound;       // 外设声音开关   BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *unit;             // 单位          BOOL 类型
@property (nullable, nonatomic, retain) NSNumber *update_time;      // 更新时间
@property (nullable, nonatomic, retain) NSDate   *user_birthday;    // 生日
@property (nullable, nonatomic, retain) NSNumber *user_drink_target;// 饮水目标
@property (nullable, nonatomic, retain) NSNumber *user_gender;      // 性别 (bool)类型 0：男；1：女 （和接口一致）
@property (nullable, nonatomic, retain) NSNumber *user_height;      // 身高   单位 cm       doubleValue
@property (nullable, nonatomic, retain) NSNumber *user_id;          // 用户的ID  用于向别人发送请求 和接受请求用
@property (nullable, nonatomic, retain) NSString *user_nick_name;   // 昵称
@property (nullable, nonatomic, retain) NSNumber *user_weight;      // 体重   单位 kg       doubleValue
@property (nullable, nonatomic, retain) NSNumber *isNeedUpdate;     // 是否需要上传个人信息      BOOL 类型
@property (nullable, nonatomic, retain) NSString *user_language_code;// 01：中文；02：英文；03：法文
@property (nullable, nonatomic, retain) NSString *countryID;         //
@property (nullable, nonatomic, retain) NSString *stateID;           //
@property (nullable, nonatomic, retain) NSString *cityID;            //
@property (nullable, nonatomic, retain) NSNumber *like_number;       // 今日的点赞个数




@end

NS_ASSUME_NONNULL_END
