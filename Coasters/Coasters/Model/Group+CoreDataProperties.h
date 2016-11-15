//
//  Group+CoreDataProperties.h
//  
//
//  Created by 丁付德 on 16/6/6.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *access;               //当前用户access // 如果是cache
@property (nullable, nonatomic, retain) NSString *group_id;             //圈号
@property (nullable, nonatomic, retain) NSString *admin_userid;         //圈主id
@property (nullable, nonatomic, retain) NSString *admin_user_pic_url;   //圈主头像地址
@property (nullable, nonatomic, retain) NSString *admin_user_nick_name; //圈主昵称
@property (nullable, nonatomic, retain) NSNumber *is_admin;             //bool YES:是圈主；NO:不是 和接口相反
@property (nullable, nonatomic, retain) NSString *group_pic_url;        //圈子头像地址
@property (nullable, nonatomic, retain) NSNumber *admin_user_gender;// 性别 (bool) 0：男；1：女 （和接口一致）
@property (nullable, nonatomic, retain) NSString *group_name;           //圈子名称
@property (nullable, nonatomic, retain) NSString *group_country_code;   //圈子地区一级编号  国家
@property (nullable, nonatomic, retain) NSString *group_state_code;     //圈子地区二级编号  地区
@property (nullable, nonatomic, retain) NSString *group_city_code;      //圈子地区三级编号  城市
@property (nullable, nonatomic, retain) NSString *group_notice;         //圈子公告
@property (nullable, nonatomic, retain) NSString *group_notice_time;    //圈子公告修改时间戳
@property (nullable, nonatomic, retain) NSString *group_member_num;     //圈子成员数量
@property (nullable, nonatomic, retain) NSNumber *is_around;            //bool YES:是周围的(或者缓存)；NO:不是 
@property (nullable, nonatomic, retain) NSNumber *update_time;          //long long 更新的时间   




@end

















NS_ASSUME_NONNULL_END
