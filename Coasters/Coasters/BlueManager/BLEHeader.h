//
//  BLEHeader.h
//  MasterDemo
//
//  Created by 丁付德 on 15/6/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_BLEHeader_h
#define aerocom_BLEHeader_h

//*************************************************************************************

//--------------------------------------   UUID(统一大写写)   --------------------------

//*************************************************************************************


#define ServerUUID                                      @"FF02"             // 主服务UUID

#define R_Name_UUID                                     @"F200"             // 读取设备名称

#define R_HardwareVersionNumber_UUID                    @"F201"             // 读取硬件版本号,软件版本号,序列号

#define RW_DateTime_UUID                                @"F202"             // 读写日期时间

#define RW_UserInfo_UUID                                @"F203"             // 读写个人信息

#define RW_DrinkingWaterRecords_UUID                    @"F204"             // 读取喝水记录状态列表 (UUID同“设置喝水记录读取屏蔽标识”)

#define R_LastDay_UUID                                  @"F205"             // 读取当天(最新一天)详细的喝水记录  (  不用 )

#define RW_DetailedDrinking_UUID                        @"F206"             // 读写详细的喝水记录  (暂时只用读)

#define W_AddWaterRecords_UUID                          @"F207"             // 补充喝水记录

#define RW_DrinkWaterToRemindTimeSection_UUID           @"F208"             // 读写喝水提醒时间段

#define RW_MonthPropertyOfWaterTarget_UUID              @"F209"             // 读写喝水目标的月份属性  (暂时不用)

#define RW_Clock_UUID                                   @"F20A"             // 读写闹钟设置

#define W_SpecialAlarm_UUID                             @"F20B"             // 特殊警报

#define R_Balance_UUID                                  @"F20C"             // 进入或退出电子称模式

#define R_Balance_RealData_UUID                         @"F20D"             // 读取实时信息

// 下面是全部的集合
#define Arr_R_UUID                                      @[ R_Name_UUID, R_HardwareVersionNumber_UUID, RW_DateTime_UUID, RW_UserInfo_UUID, RW_DrinkingWaterRecords_UUID, R_LastDay_UUID, RW_DetailedDrinking_UUID, W_AddWaterRecords_UUID, RW_DrinkWaterToRemindTimeSection_UUID, RW_MonthPropertyOfWaterTarget_UUID, RW_Clock_UUID, W_SpecialAlarm_UUID, R_Balance_UUID, R_Balance_RealData_UUID ]


//*************************************************************************************

//--------------------------------------  设备名称   ----------------------------------

//*************************************************************************************


#define Cupcare_Name                                    @"WATER-"
#define Cupcare_Other_Name                              @"Cupcare-"

#define dataInterval                                    1.2                // 时间间隔


//*************************************************************************************

//--------------------------------------    数据     ----------------------------------

//*************************************************************************************



#define DataFirst                                       0xF5
#define DataOOOO                                        0x00

/*
 #define Data00                                          0x00
 #define Data80                                          0x80
 */

#endif
