//
//  BLEManager.m
//  BLE
//
//  Created by 丁付德 on 15/5/24.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import "BLEManager.h"
#import "BLEManager+Helper.h"

static BLEManager *manager;
@interface BLEManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    dispatch_queue_t _syncQueueMangerDidUpdate;
}

@end


@implementation BLEManager
+(BLEManager *)sharedManager
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[BLEManager alloc] init];
        manager -> _syncQueueMangerDidUpdate = dispatch_get_global_queue(0, 0);
        manager.isOn = YES;
        [self resetBLE];
        manager -> dic = [[NSMutableDictionary alloc] init];
        manager -> dicSysData = [[NSMutableDictionary alloc] init];
        manager -> beginDate = DNow;
        manager -> num = 0;
        manager.connetNumber = 100000000;
        manager.connetInterval = 1;
        manager.dicConnected = [[NSMutableDictionary alloc] init];
        manager.isFailToConnectAgain = YES;
        manager.isSendRepeat = NO;
        manager -> dicDateAll = [NSMutableDictionary new];
        manager.isReRead = YES;
        manager.isBeginOK = NO;
        manager -> isRest = YES;
    });
    return manager;
}

-(void)dealloc
{
    NSLog(@"------------------------------------");
    NSLog(@"------------------------------------");
    NSLog(@"--------------dealloc---------------");
    NSLog(@"------------------------------------");
    NSLog(@"------------------------------------");
}

+(void)resetBLE
{
    manager -> dicSysData = [[NSMutableDictionary alloc] init];
    manager -> beginDate = DNow;
    manager -> num = 0;
    manager.connetNumber = 100000000;
    manager.connetInterval = 1;
    manager.dicConnected = [[NSMutableDictionary alloc] init];
    manager.isFailToConnectAgain = YES;
    manager.isSendRepeat = NO;
    manager -> dicDateAll = [NSMutableDictionary new];
    manager.isReRead = YES;
    manager.isBeginOK = NO;
    manager -> isRest = YES;
}

-(void)startScan
{
    if (self.Bluetooth.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙中心设备没开启");
        return;
    }
    if (!self.Bluetooth)
    {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.xinyi.Coasters", DISPATCH_QUEUE_SERIAL);
        self.Bluetooth = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    }
    
    self.Bluetooth.delegate = self;
    dic = [[NSMutableDictionary alloc] init];
    [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

-(void)startScanNotInit
{
    if (self.Bluetooth.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"蓝牙中心设备没开启");
        return;
    }
    self.Bluetooth.delegate = self;
    dic = [[NSMutableDictionary alloc] init];
    [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)stopScan
{
    if (self.Bluetooth)
    {
        [self.Bluetooth stopScan];
    }
}

- (void)connectDevice:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [_Bluetooth connectPeripheral:peripheral options:nil];
    }
}

-(void)stopLink:(CBPeripheral *)peripheral
{
    self.isFailToConnectAgain = NO;
    self.per = nil;
    if (peripheral)
    {
        [_Bluetooth cancelPeripheralConnection:peripheral];
    }
    else
    {
        for (int i = 0; i < self.dicConnected.count ; i++)
            [_Bluetooth cancelPeripheralConnection:self.dicConnected.allValues[i]];
    }
}

/**
 *  自动连接
 *
 *  @param uuidString uuidString
 */
-(void)retrievePeripheral:(NSString *)uuidString
{
    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:uuidString];
    if(nsUUID)
    {
        NSArray *peripheralArray = [self.Bluetooth retrievePeripheralsWithIdentifiers:@[nsUUID]];
        if([peripheralArray count] > 0)
        {
            for(CBPeripheral *peripheral in peripheralArray)
            {
                peripheral.delegate = self;
                [self stopScan];
                [self startScan];
                 __block BLEManager *blockSelf = self;
                NextWaitInCurrentTheard([blockSelf.Bluetooth connectPeripheral:peripheral options:nil];, 0.5);
            }
        }
        else
        {
            CBUUID *cbUUID = [CBUUID UUIDWithNSUUID:nsUUID];
            NSArray *connectedPeripheralArray = [self.Bluetooth retrieveConnectedPeripheralsWithServices:@[cbUUID]];
            if([connectedPeripheralArray count] > 0)
            {
                for(CBPeripheral *peripheral in connectedPeripheralArray)
                {
                    peripheral.delegate = self;
                    [_Bluetooth connectPeripheral:peripheral options:nil];
                }
            }
            else
            {
                [self startScan];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([dic.allKeys containsObject:uuidString]) {
                        [self connectDevice:dic[uuidString]];
                    }
                });
            }
        }
    }
}
#pragma mark - CBCentralManagerDelegate 中心设备代理

/**
 *  当Central Manager被初始化，我们要检查它的状态，以检查运行这个App的设备是不是支持BLE
 *
 *  @param central 中心设备
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    dispatch_barrier_async(_syncQueueMangerDidUpdate, ^
    {
        if (![self isMemberOfClass:[BLEManager class]])return;
        switch (_Bluetooth.state) {
            case CBCentralManagerStatePoweredOff:
            case CBCentralManagerStateUnknown:
            case CBCentralManagerStateResetting:
            case CBCentralManagerStateUnsupported:
            case CBCentralManagerStateUnauthorized:
            {
                self.isBeginOK = NO;
                self.isLink    = NO;
                self.isOn      = NO;
                SetUserDefault(BLEisON, @(0));
                [self.dicConnected removeAllObjects];
                self.per = nil;
            }
                break;
            case CBCentralManagerStatePoweredOn:
            {
                self.isOn = YES;
                SetUserDefault(BLEisON, @(1));
                [_Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
            }
                break;
        }
    });
}


/**
 *  扫描到设备的回调
 *
 *  @param central           中心设备
 *  @param peripheral        扫描到的外设
 *  @param advertisementData 外设的数据集
 *  @param RSSI              信号
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    float juli = powf(10, (abs([RSSI integerValue]) - 59) / (10 * 2.0));
//    NSLog(@"设备名称 : %@  距离 %.1f米", peripheral.name, juli);
    
    if (peripheral.name && ([peripheral.name rangeOfString:Cupcare_Name].length
                            || [peripheral.name rangeOfString:Cupcare_Other_Name].length))
    {
        if ([peripheral respondsToSelector:@selector(identifier)]) {
            [dic setObject:peripheral forKey:[peripheral.identifier UUIDString]];
        }
    }
    
    if (dic.count > 0 && [self.delegate respondsToSelector:@selector(Found_CBPeripherals:)])
        [self.delegate Found_CBPeripherals:dic];
}


/**
 *  连接设备成功的方法回调
 *
 *  @param central    中央设备
 *  @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.Bluetooth stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];      // 扫描服务
    
    NSString *uuidString = [peripheral.identifier UUIDString];
    [self.dicConnected setObject:peripheral forKey:uuidString];
    self.per = peripheral;
    
    if ([self.delegate respondsToSelector:@selector(CallBack_ConnetedPeripheral:)])
    {
        [self.delegate CallBack_ConnetedPeripheral:uuidString];
    }
    self.isLink = YES;
    NSLog(@"连接成功了, 当前个数：%@  地址: %@", @(self.dicConnected.count), self);
}


/**
 *  连接失败的回调
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"无法连接");
    if (self.isFailToConnectAgain)
        [self beginLinkAgain:peripheral];
}


/**
 *  被动断开
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"------------- > 连接被断开了");
    NSString *uuidString = [[peripheral identifier] UUIDString];
    //[self.dicConnected setObject:peripheral forKey:uuidString];
    
    self.isLink = NO;
    self.isLock = NO;
    self.isBeginOK = NO;
    [self.dicConnected removeObjectForKey:uuidString];
    self.per = nil;
    
    if ([self.delegate respondsToSelector:@selector(CallBack_DisconnetedPerpheral:)])
        [self.delegate CallBack_DisconnetedPerpheral:uuidString];
    
    //NSLog(@"self.isFailToConnectAgain = %@", @(self.isFailToConnectAgain));
    if (self.isFailToConnectAgain) [self beginLinkAgain:peripheral];
}

/**
 *  发现服务 扫描特性
 *
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        peripheral.delegate = self;
        for (CBService *service in peripheral.services)
        {
            [peripheral discoverCharacteristics:nil forService:service];  // 扫描特性
        }
    }
    else
    {
        //NSLog(@"error:%@",error);
    }
}

/**
 *  发现特性 订阅特性    ----------------  IOS9  这里可能不会触发回调
 *
 *  @param peripheral 外设
 *  @param service    服务
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error//4
{
    //
//    if (!error)
//    {
//        for (CBCharacteristic *chara in [service characteristics])
//        {
//            
//            NSString *uuidString = [chara.UUID UUIDString];
//            if ([Arr_R_UUID containsObject:uuidString]) {
//                [peripheral setNotifyValue:YES forCharacteristic:chara];   // 订阅特性
//            }
//        }
//    }
}


/**
 *  订阅结果回调，我们订阅和取消订阅是否成功
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        //NSLog(@"error  %@",error.localizedDescription);
    }
    else
    {
        [peripheral readValueForCharacteristic:characteristic];
        //读取服务 注意：不是所有的特性值都是可读的（readable）。通过访问 CBCharacteristicPropertyRead 可以知道特性值是否可读。如果一个特性的值不可读，使用 peripheral:didUpdateValueForCharacteristic:error:就会返回一个错误。
    }
    
//    NSString *uuidString = [characteristic.UUID UUIDString];
//      如果不是我们要特性就退出
//    if (![uuidString isEqualToString:FeiTu_TIANYIDIAN_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNZU_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNDONG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNCHENG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNHUAN_ReadUUID])
//    {
//        return;
//    }
    
    if (characteristic.isNotifying)
    {
        //NSLog(@"外围特性通知开始");
    }
    else
    {
        //NSLog(@"外围设备特性通知结束，也就是用户要下线或者离开%@",characteristic);
    }
}


/**
 *  当我们订阅的特性值发生变化时 （ 就是， 外设向我们发送数据 ）
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error//6
{
    NSData *data = characteristic.value;   // 数据集合   长度和协议匹配
    NSString *uu = [characteristic.UUID UUIDString];
    //[data LogDataAndPrompt:uu];
    if ([Arr_R_UUID containsObject:uu])
    {
        [self setData:data peripheral:peripheral charaUUID:uu];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *uu = [characteristic.UUID UUIDString];
    uu = uu;
    NSLog(@"%@ 写入成功",uu);
}

-(void)readChara:(NSString *)uuidString charUUID:(NSString *)charUUID;
{
     CBPeripheral * cbp = self.dicConnected[uuidString];
     NSArray *arry = [cbp services];
     if (!arry.count) NSLog(@"这里为空   charUUID:%@", charUUID);
     for (CBService *ser in arry)
     {
         NSString *serverUUID = [ser.UUID UUIDString];
         if ([serverUUID isEqualToString:ServerUUID])
         {
             for (CBCharacteristic *chara in [ser characteristics])
             {
                 NSString *cUUID = [chara.UUID UUIDString];
                 if ([cUUID isEqualToString:charUUID])
                 {
                     NSLog(@"开始读  %@", charUUID);
                     [cbp readValueForCharacteristic:chara];
                     break;
                 }
             }
         }
     }
}


/**
 *  写入数据
 *
 *  @param data      数据集
 *  @param charaUUID  写入的特性值
 */
-(void)Command:(NSData *)data uuidString:(NSString *)uuidString charaUUID:(NSString *)charaUUID
{
    self.per = self.dicConnected[uuidString];
    if(!self.per || !data) return;
    NSArray *arry = [self.per services];
    for (CBService *ser in arry)
    {
        NSString *serverUUID = [ser.UUID UUIDString];
        if ([serverUUID isEqualToString:ServerUUID])
        {
            for (CBCharacteristic*chara in [ser characteristics])
            {
                if ([[chara.UUID UUIDString] isEqualToString:charaUUID])
                {
                    NSString *uuid = [[self.per identifier] UUIDString];
                    [data LogDataAndPrompt:uuid promptOther:[NSString stringWithFormat:@" - %@ -- >", charaUUID]];
                    [self.per writeValue:data
                       forCharacteristic:chara
                                    type:CBCharacteristicWriteWithResponse];
                    break;
                }
            }
            break;
        }
    }
}

         
-(void)setData:(NSData *)data peripheral:(CBPeripheral *)peripheral charaUUID:(NSString *)charaUUID
{
    //  流程   连接 -》 检查时间（如果时间不对，写入时间  202）- 》 读取个人信息，如果个人信息不对，写入个人信息  202）—》 读取记录(204) -> 写入记录（204） -》 读取详细（206）   ////  闹钟 -》  去掉闹钟
    
    NSString *uuid = [[peripheral identifier] UUIDString];
    NSString *name =  peripheral.name;
    Byte *bytes = (Byte *)data.bytes;
    if ([self checkData:data])
    {
        if ([charaUUID isEqualToString:RW_DateTime_UUID])
        {
            self.isBeginOK = YES;
            NSNumber *year = [NSNumber numberWithInt:2000 + bytes[1]];
            NSNumber *month = [NSNumber numberWithInt:1 + bytes[2]];
            NSNumber *day = [NSNumber numberWithInt:1 + bytes[3]];
            NSNumber *hour = [NSNumber numberWithInt:bytes[4]];
            NSNumber *minute = [NSNumber numberWithInt:bytes[5]];
            NSDate *date = [DFD getDateFromArr:@[year, month, day, hour, minute, @0]];
            
            //NSLog(@"---- 解析后的时间为 :%@", date);
            NSDate *now = [DNow getNowDateFromatAnDate];
            double inter = [now timeIntervalSinceDate:date];
            
//            [self setDate:uuid];  // 清空当天数据，只需把时间调前一天
            NSLog(@"间隔：%f", inter);
            if (fabs(inter) > 120)
            {
                [self setDate:uuid];   // 先重新设置时间后， 间隔一段时间，后再同步   // 写完， 读
                sleep(dataInterval);
                [self readChara:uuid charUUID:RW_DateTime_UUID];
            }
            else
            {
                [self readChara:uuid charUUID:RW_UserInfo_UUID];                        // 设置个人信息 加入的第一次的大循环中
            }
            
                //[self readChara:uuid charUUID:RW_DrinkingWaterRecords_UUID];
            
        }
        else if([charaUUID isEqualToString:RW_UserInfo_UUID])
        {
            int height = bytes[1];
            int weight = bytes[2];
            BOOL gender = (BOOL)bytes[3];
            int scene = bytes[4];
            int year = ( bytes[5] << 8 )| bytes[6];
            int month = bytes[7] & 0xFF;
            int day = bytes[8] & 0xFF;
            int target = ( bytes[9] << 8 )| bytes[10];
            
            [data LogData];
            
            // 从左到右  0 是最右边
            int option0 = bytes[11] & 0x01;             // =0 喝水提醒蜂鸣器鸣叫鸣叫  =1 喝水提醒蜂鸣器不鸣叫
            int option1 = (bytes[11] >> 1) & 0x01;      // =0 喝水提醒 LED 灯闪烁    =1 喝水提醒 LED 灯不闪烁
            int option2 = (bytes[11] >> 2) & 0x01;      // =0 闹钟提醒蜂鸣器鸣叫      =1 闹钟提醒蜂鸣器不鸣叫
            int option3 = (bytes[11] >> 3) & 0x01;      // =0 闹钟提醒 LED 灯闪烁     =1 闹钟提醒 LED 灯不闪烁
            int option4 = (bytes[11] >> 4) & 0x01;      // =1 蓝牙断开蜂鸣器鸣叫       =0 蓝牙断开蜂鸣器不鸣叫
            int option5 = (bytes[11] >> 5) & 0x01;      // =1 低电报警蜂鸣器鸣叫       =0 低电报警蜂鸣器不鸣叫
            int option6 = (bytes[11] >> 6) & 0x01;      // =1 USB 插入状态启用呼吸灯    =0 USB 插入状态无呼吸灯
            int option7 = (bytes[11] >> 7) & 0x01;      // =0 按键时有声音             =1 按键时无声音
            NSLog(@"%d %d %d %d %d %d %d %d", option0, option1, option2, option3, option4, option5, option6,  option7);
            
//            NSLog(@"声音开关 --- > %@ %@ %@ %@ %@", !option0 ? @"开":@"关" , !option2 ? @"开":@"关", option4 ? @"开":@"关", option5 ? @"开":@"关", !option7 ? @"开":@"关");
//            NSLog(@"灯光开关 --- > %@ %@ %@", !option1 ? @"开":@"关", !option3 ? @"开":@"关", option6 ? @"开":@"关");
            
            int timeSystemFromCBP = (bytes[12] >> 7) & 0x01;
            //  = 0 杯垫时间显示为 24 小时制 =1 杯垫时间显示为 12 小时制
            
//            int a = bytes[12];
//            NSLog(@"a = %d", a);
            //  声音 和 灯光， 有一个开，就是开
            int soundFromAll = 0;
            if (!option0 || !option2 || option4 || option5 || !option7) soundFromAll = 1;
            
            int lightFromAll = 0;
            if (!option1 || !option3 || option6) lightFromAll = 1;
            scene = scene;
            NSLog(@"身高：%dcm, 体重：%dkg 场景：%d  生日：%d—%d-%d, 性别: %@, 目标：%d  灯光：%d 声音：%d", height, weight, scene, year, month, day, @(gender), target, lightFromAll, soundFromAll);
            
            UserInfo *userinfo = myUserInfo;                                    //  节省性能
            NSInteger user_height = [userinfo.user_height integerValue];
            NSInteger user_weight = [userinfo.user_weight integerValue];
            BOOL user_gender = [userinfo.user_gender boolValue];
            NSInteger user_year = [userinfo.user_birthday getFromDate:1];
            NSInteger user_month = [userinfo.user_birthday getFromDate:2];
            NSInteger user_day = [userinfo.user_birthday getFromDate:3];
            NSInteger user_target = [userinfo.user_drink_target integerValue];
            NSInteger timeSystemFromPhone = [DFD isSysTime24] ? 0 : 1;
            
            if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                [self.delegate CallBack_Data:250 uuidString:uuid obj:@[@(lightFromAll), @(soundFromAll)]];
            }
            
            
            // 这里的性别  取反
            if(height != user_height || weight != user_weight || gender == user_gender || year != user_year || month != user_month || day != user_day || target != user_target || timeSystemFromCBP != timeSystemFromPhone
               )
            {
                [self setUserInfo:uuid arr:@[@(lightFromAll), @(soundFromAll)]];
                 __block BLEManager *blockSelf = self;
                NextWaitInCurrentTheard(
                    [blockSelf readChara:uuid charUUID:RW_UserInfo_UUID];, dataInterval);// 再次读取
            }
            else
            {
                if (!isOnlySetUserInfo)
                {
//                    [self readClock:uuid];
//                    [self readChara:uuid charUUID:RW_Clock_UUID];
                    [self readChara:uuid charUUID:RW_DrinkingWaterRecords_UUID];
                }
                
                else
                    isOnlySetUserInfo = NO;
            }
        }
        else if([charaUUID isEqualToString:RW_DrinkingWaterRecords_UUID])
        {
            [data LogData];
            static int numbSub[4] = { 4,4,4,4 };
            int sub = bytes[1];
            numbSub[sub] = sub;
            
            // 获取这个外设的存放数组  0： 日期值(5661)  1: 日期值（NSDate）  2: 数据统计情况(count) 3 : 今天的喝水量（water） 4: 目标值
            NSMutableArray *arrDateValue = [@[ @(-1),@(-1) ] mutableCopy];  // 日期值(5661)
            NSMutableArray *arrDate =  [@[ @(-1),@(-1) ] mutableCopy];      // 日期值（NSDate）
            NSMutableArray *arrCount = [@[ @(-1),@(-1) ] mutableCopy];      // 数据统计情况(count)
            NSMutableArray *arrWater = [@[ @(-1),@(-1) ] mutableCopy];      // 今天的喝水量（water
            NSMutableArray *arrTotal = [@[ @(-1),@(-1) ] mutableCopy];      // 目标值
            for (int i = 0; i < 2; i++)
            {
                int f2kDate = ( bytes[i * 8 + 3] << 8 ) | bytes[i * 8 + 2];
                int count = ( bytes[i * 8 + 5] << 8 ) | bytes[i * 8 + 4];
                int water = ( bytes[i * 8 + 7] << 8 ) | bytes[i * 8 + 6];
                int total = ( bytes[i * 8 + 9] << 8 ) | bytes[i * 8 + 8];
                arrDateValue[i] = @(f2kDate);
                arrCount[i] = @(count);
                arrWater[i] = @(water);
                arrTotal[i] = @(total);
                arrDate[i] = [DFD HmF2KNSIntToDate:f2kDate];
            }
            
            
            NSMutableArray *arr_1 = dicSysData[uuid];
            if (!arr_1)
            {
                NSMutableArray *arrCopy = [@[ @(-1),@(-1),@(-1),@(-1),@(-1),@(-1),@(-1),@(-1)] mutableCopy];
                arr_1 = [@[ arrCopy, [arrCopy mutableCopy], [arrCopy mutableCopy], [arrCopy mutableCopy], [arrCopy mutableCopy]]mutableCopy];
                [dicSysData setObject:arr_1 forKey:uuid];
            }
            
            arr_1[0][sub * 2]       = arrDateValue[0];
            arr_1[0][sub * 2 + 1]   = arrDateValue[1];
            arr_1[1][sub * 2]       = arrDate[0];
            arr_1[1][sub * 2 + 1]   = arrDate[1];
            arr_1[2][sub * 2]       = arrCount[0];
            arr_1[2][sub * 2 + 1]   = arrCount[1];
            arr_1[3][sub * 2]       = arrWater[0];
            arr_1[3][sub * 2 + 1]   = arrWater[1];
            arr_1[4][sub * 2]       = arrTotal[0];
            arr_1[4][sub * 2 + 1]   = arrTotal[1];
            
            if (numbSub[0] == 4 || numbSub[1] == 4 || numbSub[2] == 4 || numbSub[3] == 4)
            {
                [self readChara:uuid charUUID:RW_DrinkingWaterRecords_UUID];
            }
            else
            {
                static BOOL isSoQuick = NO;
                if (isSoQuick) {
                    return;
                }
                isSoQuick = YES;
                NextWaitInCurrentTheard(isSoQuick = NO;, 2);
                
                NSLog(@"记录读取完毕");
                NSLog(@"arr_1 = %@", arr_1);
                
                todayIndexInSysData = [self getBiggestIndexInArray:arr_1[0]];
                NSLog(@"今天在数据中的索引是 %@", @(todayIndexInSysData));
                if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                    [self.delegate CallBack_Data:204 uuidString:uuid obj:@[ arr_1, @(todayIndexInSysData)]];
                }
                
                waterCount = [arr_1[3][todayIndexInSysData] integerValue];                                  // 赋值今天的喝水总量
                newWaterCount = 0;
                
                NSData *data204 = [self set204Data:arr_1 uuid:uuid];
                shieldCountOfDay = [self isAllShield:data204];
                data204ExceptToday = [self data204ExceptToday:arr_1 indexSub: todayIndexInSysData];
                
//                [data LogDataAndPrompt:@"全部"];
//                [data204 LogDataAndPrompt:@"204"];
//                [data204ExceptToday LogDataAndPrompt:@"data204ExceptToday"];
                
                NSLog(@"读取完所有记录后发送");
                [self Command:data204 uuidString:uuid charaUUID:RW_DrinkingWaterRecords_UUID];  // 发送 屏蔽标识
                
                if (shieldCountOfDay.count < 8) // 888888  // 如果没有全部屏蔽， 开始同步
                {
                    __block BLEManager *blockSelf = self;
                    NextWaitInCurrentTheard(
                        NSLog(@"开始读取大数据");
                        isRest = YES;
                        numbSub[0] = numbSub[1] = numbSub[2] = numbSub[3] = 4;
                        [blockSelf readChara:uuid charUUID:RW_DetailedDrinking_UUID];, dataInterval);// 读取环境信息
                }
            }
        }
        else if([charaUUID isEqualToString:RW_DetailedDrinking_UUID])
        {
            static BOOL isRevice = NO;   // 停止接收
            if (isRevice)
            {
                NSLog(@"// 停止接收");
                return;
            }
            // 没有数据， 就证明 这天没有喝水
            static int indeData[8][12];
            
            if (isRest) {
                isRest = NO;
                for (int i = 0 ; i < 8; i++)
                    for (int j = 0; j < 12; j++)
                        indeData[i][j] = 12;
            }
        
            int indexDataInt = bytes[1] ? bytes[1] : 0;             // 在8天数据中的索引
            int indexSubInt = bytes[2] ? bytes[2] : 0;              // 在一天数据中 12条数据的索引
            [data LogDataAndPrompt:[NSString stringWithFormat:@"第 %d 天第 %d 条数据， 日期：%@", indexDataInt, indexSubInt, [((NSDate *)(dicSysData[uuid][1][indexDataInt])) toString:@"YYYY-MM-dd"]]];
            
        
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
             {
                 if (indeData[indexDataInt][indexSubInt] != indexSubInt)
                 {
                     indeData[indexDataInt][indexSubInt] = indexSubInt;
                     
                     BOOL isBreak = NO;  // 是否出现中间打断
                     for (int i = 0; i < 4; i++)
                     {
                         Byte byte1 = bytes[i * 4 + 3];
                         Byte byte2 = bytes[i * 4 + 4];
                         Byte byte3 = bytes[i * 4 + 5];
                         Byte byte4 = bytes[i * 4 + 6];
                         
                         int water = ( byte4 << 8 ) | byte3;
                         
                         NSDate *dateThis = dicSysData[uuid][1][indexDataInt];
                         if (!dateThis || (int)dateThis == -1)
                         {
                             NSLog(@"-------------用户解除了绑定，  这里中间打断");
                             isBreak = YES;
                             [dicSysData removeObjectForKey:uuid];
                             break;
                         }
                         NSInteger year, month,day;
                         year = month = day = 0;
                         year  = [dateThis getFromDate:1];
                         month = [dateThis getFromDate:2];
                         day   = [dateThis getFromDate:3];
                         
                         NSMutableArray *arrDate6 = [@[@(year), @(month), @(day)] mutableCopy];
                         NSMutableArray *arrDate3 = [self getTimesFor:byte1 height:byte2];
                         int timevalue = 0;
                         timevalue = [self getTimeValue:byte1 height:byte2];
                         [arrDate6 addObjectsFromArray:arrDate3];
                         NSDate *date = [DFD getDateFromArr:arrDate6];
                         
                         NSDate *lastDate = LastSysDateTime;
                         
                         if (indexDataInt == todayIndexInSysData)
                         {
                             if (!newWaterCount && newWaterCount != 0) {
                                 newWaterCount = 0;
                             }
                             newWaterCount += water;
                         }
                         
                         NSComparisonResult result = [date compare:lastDate];
                         if ((result == NSOrderedDescending || result == NSOrderedSame) && ([date getFromDate:4] != 0 || [date getFromDate:5] != 0 || [date getFromDate:6] != 0) && water != 0)
                         {
                             SynData *syn = [SynData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@ and pUUIDString == %@", myUserInfoAccess, date, uuid] inContext:localContext];
                             
                             SynData *synPrevious = [[SynData findAllSortedBy:@"date" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d and day == %d and date < %@", myUserInfoAccess, year, month, day, date] inContext:localContext] firstObject];
                             
                             //  || !synPrevious
                             if ((((result == NSOrderedDescending)) && water < 2000 ) || !syn)
                             {
                                 syn = [SynData MR_createEntityInContext:localContext];
                                 NSLog(@"创建记录  water: %d", water);
                             }
                             else if(syn && [syn.water intValue] < water)
                             {
                                 NSLog(@"时间太近，覆盖记录");
                             }
                             
                             [dicDateAll setObject:date forKey:date];
                             lastDateInAll = [self getBiggestDate:dicDateAll];       // 获取最新的喝水日期
                             
                             syn.access = myUserInfoAccess;
                             syn.pUUIDString = uuid;
                             syn.pName = name;
                             NSNumber *nub = dicSysData[uuid][0][indexDataInt];
                             syn.dateValue = nub;
                             syn.timeValue = @(timevalue);
                             syn.sub = @(indexSubInt);
                             syn.score = @(0);
                             syn.year = @(year);
                             syn.month = @(month);
                             syn.day = @(day);
                             syn.hour = arrDate3[0];
                             syn.minute = arrDate3[1];
                             syn.second = arrDate3[2];
                             syn.water = @(water);
                             syn.date = date;
                             
                             syn.waterCount = @(synPrevious ? ([synPrevious.waterCount intValue] + water) : water);
                             //NSLog(@"当前这条数据的喝水总量是%@", syn.waterCount);
                             if ((!syn.water || [syn.water intValue] > 2000)) { // && !syn.year
                                 [syn MR_deleteEntityInContext:localContext];
                                 NSLog(@"单点的喝水量 > 2000 了 ");
                             }
                             
                             if ([syn.waterCount intValue] < [syn.water intValue]) {
                                 NSLog(@"单点的喝水量比 这个时间点+之前的所有点的喝水量还要大");
                             }
                             
                             DLSave;
                             DBSave;
                         }
                     }
                     if (!isBreak)  [self readChara:uuid charUUID:RW_DetailedDrinking_UUID];    // 接着读
                 }
                 else
                 {
                     SynData *synLast = [SynData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and pUUIDString == %@", myUserInfoAccess, uuid] sortedBy:@"date" ascending:NO inContext:localContext];
                     //NSLog(@"synLast.waterCount ： %@", synLast.waterCount);
                     if ([synLast.water intValue] > 2000) {
                         
                         NSLog(@"%@", GetUserDefault(@"测试1"));
                         SetUserDefault(@"测试1", @(newWaterCount));
                         return;
                     }
                     synLast.waterCount = @(newWaterCount);
                     DLSave
                     DBSave;
                     
                     //NSLog(@"大数据读取完成了, 今天的总喝水量是 %@", synLast.waterCount);
                     [DFD setLastSysDateTime:lastDateInAll access:myUserInfoAccess];                      // 设置最后的更新时间
                     if (newWaterCount > waterCount)  //    || 1    // TODO 这里在硬件修改后 会变动
                     {
                         waterCount = newWaterCount;
                         if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                             [self.delegate CallBack_Data:2044 uuidString:uuid obj:@[ dicSysData[uuid], @(todayIndexInSysData), @(newWaterCount)]];}
                     }
                     newWaterCount = 0 ;
                     //写入后Block  // 因为写入数据 是异步操作， 要在写入成功后，再进行回调
                     
                     __block BLEManager *blockSelf = self;
                     void (^writeNext)() = ^
                     {
                         _isLock = NO;
                         if ([blockSelf.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)])
                         {
                             SetUserDefault(isSynDataOver, @YES);
                             [blockSelf.delegate CallBack_Data:206 uuidString:uuid obj:lastDateInAll];
                         }
                         for (int i = 0 ; i < 8; i++)
                             for (int j = 0; j < 12; j++)
                                 indeData[i][j] = 12;
                     };
                     
                     [self writeRecord:dicSysData[uuid] block:writeNext];
                 }
             }];
        }
        else if([charaUUID isEqualToString:RW_Clock_UUID])
        {
            [data LogData];
            static int numData[2] = { 2, 2 };                       //   默认显示2个
            int sub = bytes[1];
            if (numData[0] == 2 || numData[1] == 2)
            {
                numData[sub] = sub;
                
                // 这里待定
                for (int i = 0; i < 4; i++)
                {
                    Byte byte1, byte2, byte3, byte4;
                    byte1 = byte2 = byte3 = byte4 = 0x00;
                    byte1 = bytes[i * 4+ 2];
                    byte2 = bytes[i * 4+ 3];
                    byte3 = bytes[i * 4+ 4];
                    byte4 = bytes[i * 4+ 5];
                    
                    NSNumber *ID = @(sub == 0 ? i : i + 4);
                    Clock *cl = [Clock findFirstByAttribute:@"iD" withValue:ID inContext:DBefaultContext];
                    cl.type = @((NSInteger)byte1);          // 这里用 type 来区分  00:00分 一次性闹钟的问题
                    cl.isOn = @((NSInteger)(byte2 >> 7));
                    
                    NSInteger hourF = byte3 & 0x7F;
                    NSInteger minuteF = byte4 & 0x3F;
                    cl.hour = @(hourF);
                    cl.minute = @(minuteF);
                    
                    NSInteger sunday = ( byte2 >> 6 ) & 0x01;
                    NSInteger monday = ( byte2 >> 5 ) & 0x01;
                    NSInteger tuesday = ( byte2 >> 4 ) & 0x01;
                    NSInteger wednesday = ( byte2 >> 3 ) & 0x01;
                    NSInteger thursday = ( byte2 >> 2 ) & 0x01;
                    NSInteger friday = ( byte2 >> 1)  & 0x01;
                    NSInteger saturday = byte2 & 0x01;
                    
                    cl.repeat = [NSString stringWithFormat:@"%ld-%ld-%ld-%ld-%ld-%ld-%ld", (long)sunday, (long)monday, (long)tuesday, (long)wednesday, (long)thursday, (long)friday, (long)saturday];
                    [cl perfect];
                    
                    DBSave;
                    //NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@", cl.isOn, cl.strRepeat, cl.strTime, cl.type);
                    
                    
                    NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@ hour:%@ minute:%@", cl.isOn, cl.strRepeat, cl.strTime, cl.type, cl.hour, cl.minute);
                }
                
                
                if (numData[0] == 2 || numData[1] == 2)
                    [self readChara:uuid charUUID:RW_Clock_UUID];
                else
                {
                    NSLog(@"------- 读取完毕");
                    numData[0] = numData[1] = 2;
                    
                    //[self checkClockData];
                    
                    if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                        [self.delegate CallBack_Data:210 uuidString:uuid obj:nil];}
                    if (!isOnlySetClock)
                        [self readChara:uuid charUUID:RW_DrinkingWaterRecords_UUID];
                    else
                        isOnlySetClock = NO;
                }
            }
//            else
//            {
//                NSLog(@"------- 读取完毕");
//                numData[0] = numData[1] = 2;
//                [self checkClockData];
//                if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
//                    [self.delegate CallBack_Data:210 uuidString:uuid obj:nil];}
//                if (!isOnlySetClock)
//                    [self readChara:uuid charUUID:RW_DrinkingWaterRecords_UUID];
//                else
//                    isOnlySetClock = NO;
//            }
        }
        else if([charaUUID isEqualToString:R_Balance_RealData_UUID])
        {
            /*
             00:未初始化。 01:正常工作模式。 02:校准模式。 03:电子秤模式。
             */
            int work_mode = bytes[7];
            int weight = bytes[8] | (bytes[9] << 8);
            //NSLog(@"模式： %d, 重量： %d", work_mode, weight);
            if (work_mode != 3)
                [self setBalance:uuid turnON:YES];
            else
            {
                if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                    [self.delegate CallBack_Data:213 uuidString:uuid obj:@(weight)];}
            }
                
        }
        else if([charaUUID isEqualToString:RW_DrinkWaterToRemindTimeSection_UUID])
        {
            [data LogData];
            static int numCount = 0;            // 累计读取的次数
            
            if(!arrWorkRemindTime) arrWorkRemindTime = [NSMutableArray new];
            if(!arrRestRemindTime) arrRestRemindTime = [NSMutableArray new];
            
            int indexSub = bytes[1];
            
            Byte byteWeek = bytes[2];
            
            if(indexSub == 0 || indexSub == 16)       // 第一套的星期 或者 第二套
            {
                NSString *weekStr = [NSString stringWithFormat:@"%d-%d-%d-%d-%d-%d-%d-%d"
                                     , (int)(( byteWeek >> 7 ) & 0x01)
                                     , (int)(( byteWeek >> 6 ) & 0x01)
                                     , (int)(( byteWeek >> 5 ) & 0x01)
                                     , (int)(( byteWeek >> 4 ) & 0x01)
                                     , (int)(( byteWeek >> 3 ) & 0x01)
                                     , (int)(( byteWeek >> 2 ) & 0x01)
                                     , (int)(( byteWeek >> 1 ) & 0x01)
                                     , (int)( byteWeek & 0x01)];
                [(indexSub ? arrRestRemindTime : arrWorkRemindTime) insertObject:weekStr atIndex:0];
            }
            
            if (indexSub < 20)
            {
                int numberInData = (indexSub == 3 || indexSub == 19) ? 3 : 4;    // 0x03 = 3  0x13 = 19
                for (int i = 0; i < numberInData; i++)
                {
                    int beginMinute = bytes[i * 4 + 3] | (bytes[i * 4 + 4] << 8);
                    int endMinute   = bytes[i * 4 + 5] | (bytes[i * 4 + 6] << 8);
                    if (beginMinute == endMinute)  beginMinute = endMinute = 24 * 60;
                    
                    if (indexSub < 10)
                        [arrWorkRemindTime addObject:@{ @(beginMinute):@(endMinute) }];
                    else if(indexSub < 20)
                        [arrRestRemindTime addObject:@{ @(beginMinute):@(endMinute) }];
                }
            }
            
            numCount++;
            if (numCount == 16)
            {
                numCount = 0;
                NSLog(@"读取完毕");
                                                                            // 这里 进行排序
                arrWorkRemindTime  = [DFD sort:arrWorkRemindTime];
                arrRestRemindTime  = [DFD sort:arrRestRemindTime];
                //NSLog(@"------------------------------ 长度: %d, %d", arrWorkRemindTime.count,arrRestRemindTime.count);
                NSLog(@"arrWorkRemindTime : %@, arrRestRemindTime : %@", arrWorkRemindTime, arrRestRemindTime);
                
                // 写入本地
                NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
                if (!dicremindWater)
                {
                    dicremindWater = @{ uuid: @[arrWorkRemindTime, arrRestRemindTime] };
                    SetUserDefault(dicRemindWater, [DFD dicToData:dicremindWater] );
                }
                else
                {
                    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dicremindWater];
                    [newDic setObject:@[arrWorkRemindTime, arrRestRemindTime] forKey:uuid];
                    SetUserDefault(dicRemindWater, [DFD dicToData:newDic]);
                }
                
                if(!GetUserDefault(isFirstReadTimeSection) && [self checkRemindTime:arrWorkRemindTime arr_2:arrRestRemindTime])
                {
                    arrWorkRemindTime[0] = @"0-0-1-1-1-1-1-0"; //
                    arrRestRemindTime[0] = @"0-1-0-0-0-0-0-1";
                    arrWorkRemindTime[1] = arrRestRemindTime[1] = @{ @(9*60):@(12*60) };
                    arrWorkRemindTime[2] = arrRestRemindTime[2] = @{ @(13*60):@(18*60) };
                    SetUserDefault(isFirstReadTimeSection, @YES);
                    
                    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dicremindWater];
                    [newDic setObject:@[arrWorkRemindTime, arrRestRemindTime] forKey:uuid];
                    SetUserDefault(dicRemindWater, [DFD dicToData:newDic]);
                    
                    [self setWaterRemind:1 isWork:YES uuid:uuid];
                    [self setWaterRemind:1 isWork:NO  uuid:uuid];
                    
//                    [self setWaterRemind:2 isWork:1 uuid:uuid];
                }
                

                arrWorkRemindTime = nil;                // 清空缓存，防止重复添加
                arrRestRemindTime = nil;
                if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                    [self.delegate CallBack_Data:208 uuidString:uuid obj:nil];}
            }
            else
            {
                [self readChara:uuid charUUID:RW_DrinkWaterToRemindTimeSection_UUID];
            }
        }
    }
}




// ------------------------------------------------------------------------------

// ----------------------------- 私有方法 ----------------------------------------

// ------------------------------------------------------------------------------

/**
 *  开始断开重连
 *
 *  @param peripheral 要重新连接的设备
 */
-(void)beginLinkAgain:(CBPeripheral *)peripheral
{
    [self retrievePeripheral:[peripheral.identifier UUIDString]];
//    NSTimer *timR;
//    timR = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(link:) userInfo:peripheral repeats:YES];
    //[self.Bluetooth connectPeripheral:peripheral options:nil];
}

-(void)link:(NSTimer *)timerR
{
    NSLog(@"被动断开后，重新");
    CBPeripheral *cp = timerR.userInfo;
    [self retrievePeripheral:[cp.identifier UUIDString]];
}


// ------------------------------------------------------------------------------

// ----------------------------- 帮助方法 ----------------------------------------

// ------------------------------------------------------------------------------



- (void)begin:(NSString *)uuid
{
    if (!uuid || !uuid.length) return;
    NSLog(@"----------  开始了， uuid:%@", uuid);
    _isLock = YES;
    if (!_isBeginOK && self.isLink) { //  && self.isReRead
        [self readChara:uuid charUUID:RW_DateTime_UUID];
    }
    
//    self.isBeginOK = NO;
    
    // 这里开始读的时候， 可能链接还不稳定，  如果在一定时间内，没有返回数据，  应该再次读取    2秒
     __block BLEManager *blockSelf = self;
    NextWaitInCurrentTheard(
        if(!blockSelf.isBeginOK){ [blockSelf begin:uuid]; };,2);
}

//
//- (void)setWarnByType:(NSString *)uuidString typeIndex:(int)typeIndex
//{
//    if(!uuidString)
//        return;
//    switch (typeIndex) {
//        case 1:
//            [self setWarnByCall:uuidString];
//            break;
//        case 2:
//            [self setWarnByMessage:uuidString];
//            break;
//            
//        default:
//            break;
//    }
//}

// 设置闹钟 并读取
-(void)setClockAndRead:(NSString *)uuidString isFirst:(BOOL)isFirst
{
    isOnlySetClock = YES;
    [self setClock:uuidString isFirst:isFirst];
     __block BLEManager *blockSelf = self;
    NextWaitInCurrentTheard([blockSelf readChara:uuidString charUUID:RW_Clock_UUID];, 1);
}

// 设置用户 并读取
-(void)setUserinfoAndRead:(NSString *)uuidString
{
    isOnlySetUserInfo = YES;
    [self setUserInfo:uuidString arr:nil];
     __block BLEManager *blockSelf = self;
    NextWaitInCurrentTheard([blockSelf readChara:uuidString charUUID:RW_UserInfo_UUID];, 1);
}

-(void)readClock:(NSString *)uuidString
{
    isOnlySetClock = YES;
    [self readChara:uuidString charUUID:RW_Clock_UUID];
}

// 读取大数据  这个方法要先屏蔽掉除今天之外的
-(void)readToday:(NSString *)uuidString
{
    if(!self.isReRead)
    {
        [self readChara:uuidString charUUID:RW_DetailedDrinking_UUID];
    }
    else
    {
        self.isReRead = NO;
        NSLog(@"循环读取当天 发送");
        [self Command:data204ExceptToday uuidString:uuidString charaUUID:RW_DrinkingWaterRecords_UUID];  // 发送 屏蔽标识
         __block BLEManager *blockSelf = self;
        NextWaitInCurrentTheard([blockSelf readChara:uuidString charUUID:RW_DetailedDrinking_UUID];, 1);
    }
}


// 写入时间
-(void)setDate:(NSString *)uuidString
{
    char data[8];
    data[0] = DataFirst;
    data[1] = (DDYear - 2000) & 0xFF;
    data[2] = (DDMonth - 1) & 0xFF;
    data[3] = (DDDay - 1) & 0xFF;
    data[4] = DDHour & 0xFF;
    data[5] = DDMinute & 0xFF;
    data[6] = DDSecond & 0xFF;
    
    int sum = 0;
    for (int i = 1; i < 7; i++) {
        sum += (data[i]) ^ i;
    }
    data[7] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:8];
    [self Command:dataPush uuidString:uuidString charaUUID:RW_DateTime_UUID];
}


// 写入个人信息
-(void)setUserInfo:(NSString *)uuidString arr:(NSArray *)arr
{
    UserInfo *userinfo = myUserInfo;
    char data[20];
    
    int height = [userinfo.user_height intValue];
    int weight = [userinfo.user_weight intValue];
    int sex    = [userinfo.user_gender boolValue] ? 0 : 1;// 硬件协议上  0：女  1 ： 男  本地是 是 YES 女  NO 男
    int scene  = 0;
    int year   = [userinfo.user_birthday getFromDate:1];
    int moth   = [userinfo.user_birthday getFromDate:2];
    int day    = [userinfo.user_birthday getFromDate:3];
    int target = [userinfo.user_drink_target intValue];
    
    
    data[0] = DataFirst;
    data[1] = height & 0xFF;
    data[2] = weight & 0xFF;
    data[3] = sex & 0xFF;
    data[4] = scene & 0xFF;
    data[5] = (year >> 8) & 0xFF;
    data[6] = year & 0xFF;
    data[7] = moth & 0xFF;
    data[8] = day & 0xFF;
    data[9] = (target >> 8) & 0xFF;
    data[10] = target & 0xFF;
    
    /*
        0 是  8位中的最右边的
     */
    
    if(!arr)
    {
        int option0 = [userinfo.swithSound boolValue] ? 0 : 1;
        int option1 = [userinfo.swithLight boolValue] ? 0 : 1;
        int option2 = [userinfo.swithSound boolValue] ? 0 : 1;
        int option3 = [userinfo.swithLight boolValue] ? 0 : 1;
        int option4 = [userinfo.swithSound boolValue] ? 1 : 0;
        int option5 = [userinfo.swithSound boolValue] ? 1 : 0;
        int option6 = [userinfo.swithLight boolValue] ? 1 : 0;
        int option7 = [userinfo.swithSound boolValue] ? 0 : 1;
        
        // 这里 写入 要修改
        data[11] = option0 | (option1 << 1) | (option2 << 2) | (option3 << 3) | (option4 << 4) | (option5 << 5) | (option6 << 6 | (option7 << 7));
    }else
    {
        // 这里传入的  1， 0  代表这开 和 关   1： 开   0 :关
        int li = [arr[0] intValue];
        int sou = [arr[1] intValue];
        int option0 = !sou;
        int option1 = !li;
        int option2 = !sou;
        int option3 = !li;
        int option4 = sou;
        int option5 = sou;
        int option6 = li;
        int option7 = !sou;
        
        // 这里 写入 要修改
        data[11] = option0 | (option1 << 1) | (option2 << 2) | (option3 << 3) | (option4 << 4) | (option5 << 5) | (option6 << 6 | (option7 << 7));
    }
    
    /*
     option1.bit0 : option1.bit1 : option1.bit2 :
     =0 杯垫不显示上次喝水记录
     =0 杯垫不显示本次期待喝水量 =0 杯垫不显示下次期待喝水情况
     =1 杯垫显示上次喝水记录
     =1 杯垫显示本次期待喝水量 =1 杯垫显示下次期待喝水情况
     option1.bit3 : =0 杯垫不显示喝水柱状图 =1 杯垫显示喝水柱状图
     option1.bit7 : =0 杯垫时间显示为 24 小时制 =1 杯垫时间显示为 12 小时制
     */
    
    data[12] = [DFD isSysTime24] ? 0x7F : 0xFF;
//    data[12] = 0xFF;  // 12 小时
//    data[12] = 0x7F;  // 12 小时
//    
    
    
    data[13] = data[14] = data[15] = data[16] = data[17] = data[18] = data[19] = 0;
    
    int sum = 0;
    for (int i = 1; i < 19; i++) {
        sum += (data[i]) ^ i;
    }
    data[19] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:20];
    [self Command:dataPush uuidString:uuidString charaUUID:RW_UserInfo_UUID];
}


// 设置来电提醒
//- (void)setWarnByCall:(NSString *)uuidString
//{
//    char data[18];
//    data[0] = DataFirst;
//    data[1] = 0x01;
//    data[2] = data[3] = data[4] = data[5] = data[6] = data[7] = data[8] = data[9] = data[10] = data[11] = data[12] = data[13] = data[14] = data[15] = data[16] = data[17] = 0;
//    
//    int sum = 0;
//    for (int i = 1; i < 17; i++) {
//        sum += (data[i]) ^ i;
//    }
//    data[17] = sum & 0xFF;
//    
//    NSData *dataPush = [NSData dataWithBytes:data length:18];
//    [self Command:dataPush uuidString:uuidString charaUUID:W_SpecialAlarm_UUID];
//}
//
//// 设置短信提醒
//- (void)setWarnByMessage:(NSString *)uuidString
//{
//    char data[18];
//    data[0] = DataFirst;
//    data[1] = 0x02;
//    data[2] = data[3] = data[4] = data[5] = data[6] = data[7] = data[8] = data[9] = data[10] = data[11] = data[12] = data[13] = data[14] = data[15] = data[16] = data[17] = 0;
//    
//    int sum = 0;
//    for (int i = 1; i < 17; i++) {
//        sum += (data[i]) ^ i;
//    }
//    data[17] = sum & 0xFF;
//    
//    NSData *dataPush = [NSData dataWithBytes:data length:18];
//    [self Command:dataPush uuidString:uuidString charaUUID:W_SpecialAlarm_UUID];
//}


// 设置闹钟   是否是前四个   //  这里 为了保证硬件数据安全， 要发送两条
-(void)setClock:(NSString *)uuidString isFirst:(BOOL)isFirst
{
    NSArray *arrClock = [Clock findAllSortedBy:@"iD" ascending:YES inContext:DBefaultContext];
    NSRange range = isFirst ? NSMakeRange(0, 4) : NSMakeRange(4, 4);
    arrClock = [arrClock subarrayWithRange:range];
    
    // 第一条
    char data[19];
    data[0] = DataFirst;
    data[1] = isFirst ? 0x00: 0x01;
    
    for (int i = 0; i < 4; i++)
    {
        Clock *cl = arrClock[i];
        data[i * 4 + 2] = [cl.type intValue] & 0xFF;
        //NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@ hour:%@ minute:%@", cl.isOn, cl.strRepeat, cl.strTime, cl.type, cl.hour, cl.minute);
        NSArray *arr = [cl.repeat componentsSeparatedByString:@"-"];
        data[i * 4 + 3] = (([cl.isOn intValue] << 7) | ([arr[0] intValue] << 6) | ([arr[1] intValue] << 5) | ([arr[2] intValue] << 4) | ([arr[3] intValue] << 3) | ([arr[4] intValue] << 2) | ([arr[5] intValue] << 1) | [arr[0] intValue] ) & 0xFF;
        data[i * 4 + 4] = [cl.hour intValue] & 0xFF;
        data[i * 4 + 5] = [cl.minute intValue] & 0xFF;
    }
    
    int sum = 0;
    for (int i = 1; i < 18; i++) {
        sum += (data[i]) ^ i;
    }
    data[18] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:19];
    [self Command:dataPush uuidString:uuidString charaUUID:RW_Clock_UUID];
}

// 进入或者退出称重模式
-(void)setBalance: (NSString *)uuidString turnON:(BOOL)turnON
{
    char data[18];
    data[0] = DataFirst;
    data[1] = 0x01;
    data[2] = turnON ? 0x01 : 0x00;
    data[3] = 0x00;
    data[4] = 0x00;
    data[5] = 0xFE;
    data[6] = turnON ? 0xFE : 0xFF;
    data[7] = 0xFF;
    data[8] = 0xFF;
    data[9] = data[10] = data[11] = data[12] = data[13] = data[14] = data[15] = data[16] = 0x00;
    
    int sum = 0;
    for (int i = 1; i < 17; i++) {
        sum += (data[i]) ^ i;
    }
    data[17] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:18];
    //[dataPush LogData];
    [self Command:dataPush uuidString:uuidString charaUUID:R_Balance_UUID];
}



// 操作时间段设置   1： 开启或者关闭  2：设置工作日  3：设置提醒时间
-(void)setWaterRemind:(int)type isWork:(BOOL)isWork uuid:(NSString *)uuid
{
    NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
    if (!dicremindWater) dicremindWater = [[NSDictionary alloc] init];
    NSArray *arrData;
    if (dicremindWater && [dicremindWater.allKeys containsObject:uuid])
        arrData = dicremindWater[uuid];
    if (!arrData)
    {
        NSLog(@"这里报错了，  为空");
    }
    else
    {
        NSArray *arrTag     = isWork ? arrData[0] : arrData[1];
        NSArray *arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
        
        if(type == 1)       // 发送  开启或者关闭 发送4条
        {
            Byte byte = isWork ? 0x00 : 0x10;   // --------------------------------- 1 / 4
            int ints[8];
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[1]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[1]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[2]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[2]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[3]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[3]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[4]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[4]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = isWork ? 0x01 : 0x11;        // --------------------------------- 2 / 4
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[5]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[5]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[6]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[6]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[7]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[7]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[8]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[8]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = isWork ? 0x02 : 0x12;        // --------------------------------- 3 / 4
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[9]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[9]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[10]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[10]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[11]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[11]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[12]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[12]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = isWork ? 0x03 : 0x13;        // --------------------------------- 4 / 4
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[13]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[13]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[14]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[14]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[15]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[15]).allValues[0] intValue];
            ints[6] = 0;
            ints[7] = 0;
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
        }
        else if(type == 2)  //    改动工作日  发送8条数据
        {
            Byte byte = 0x00;    // --------------------------------- 1 / 8
            int ints[8];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[1]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[1]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[2]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[2]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[3]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[3]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[4]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[4]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x01;        // --------------------------------- 2 / 8
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[5]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[5]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[6]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[6]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[7]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[7]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[8]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[8]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x02;        // --------------------------------- 3 / 8
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[9]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[9]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[10]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[10]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[11]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[11]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[12]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[12]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x03;        // --------------------------------- 4 / 8
            arrTag     = isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[13]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[13]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[14]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[14]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[15]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[15]).allValues[0] intValue];
            ints[6] = 0;
            ints[7] = 0;
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            
            byte = 0x10;        // --------------------------------- 5 / 8
            arrTag     = !isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[1]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[1]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[2]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[2]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[3]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[3]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[4]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[4]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x11;        // --------------------------------- 6 / 8
            arrTag     = !isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[5]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[5]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[6]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[6]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[7]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[7]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[8]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[8]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x12;        // --------------------------------- 7 / 8
            arrTag     = !isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[9]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[9]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[10]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[10]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[11]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[11]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[12]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[12]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            
            byte = 0x13;        // --------------------------------- 8 / 8
            arrTag     = !isWork ? arrData[0] : arrData[1];
            arrTagSub  = [(NSString *)[arrTag[0] mutableCopy] componentsSeparatedByString:@"-"];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[13]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[13]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[14]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[14]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[15]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[15]).allValues[0] intValue];
            ints[6] = 0;
            ints[7] = 0;
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
        }
        else if(type == 3)  // 发送4条
        {
            // 获取发送命令的数量
//            int countSend =  5;//[self getSendCount:arrTag];
//            int countTag = 0;
            
            Byte byte = isWork ?  0x00 : 0x10;
            int ints[8];
            
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[1]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[1]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[2]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[2]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[3]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[3]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[4]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[4]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            byte     = isWork ?  0x01 : 0x11;
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[5]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[5]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[6]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[6]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[7]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[7]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[8]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[8]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            byte     = isWork ?  0x02 : 0x12;
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[9]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[9]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[10]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[10]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[11]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[11]).allValues[0] intValue];
            ints[6] = [(NSNumber *)((NSDictionary *)arrTag[12]).allKeys[0] intValue];
            ints[7] = [(NSNumber *)((NSDictionary *)arrTag[12]).allValues[0] intValue];
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
            sleep(0.2);
            byte     = isWork ?  0x03 : 0x13;
            ints[0] = [(NSNumber *)((NSDictionary *)arrTag[13]).allKeys[0] intValue];
            ints[1] = [(NSNumber *)((NSDictionary *)arrTag[13]).allValues[0] intValue];
            ints[2] = [(NSNumber *)((NSDictionary *)arrTag[14]).allKeys[0] intValue];
            ints[3] = [(NSNumber *)((NSDictionary *)arrTag[14]).allValues[0] intValue];
            ints[4] = [(NSNumber *)((NSDictionary *)arrTag[15]).allKeys[0] intValue];
            ints[5] = [(NSNumber *)((NSDictionary *)arrTag[15]).allValues[0] intValue];
            ints[6] = 0;
            ints[7] = 0;
            [self writeData:byte arrWeekRepeat:arrTagSub ints:ints uuid:uuid];
            
        }
    }
}

-(void)writeData:(Byte)byte arrWeekRepeat:(NSArray *)arrWeekRepeat ints:(int[])ints uuid:(NSString *)uuid
{
    int const count = 20;
    char data[count];
    int index = 0;
    data[index++] = DataFirst;
    data[index++] = byte;  // 0  13
    
    data[index++] = ([arrWeekRepeat[0] intValue] << 7) | ([arrWeekRepeat[1] intValue] << 6) | ([arrWeekRepeat[2] intValue] << 5) | ([arrWeekRepeat[3] intValue] << 4) | ([arrWeekRepeat[4] intValue] << 3) | ([arrWeekRepeat[5] intValue] << 2) | ([arrWeekRepeat[6] intValue] << 1) | [arrWeekRepeat[7] intValue];
    
    int dateBegin = ints[0];
    int dateEnd   = ints[1];
    data[index++] = dateBegin & 0xFF;
    data[index++] = (dateBegin >> 8) & 0xFF;
    data[index++] = dateEnd & 0xFF;
    data[index++] = (dateEnd >> 8) & 0xFF;
    
    dateBegin = ints[2];
    dateEnd   = ints[3];
    data[index++] = dateBegin & 0xFF;
    data[index++] = (dateBegin >> 8) & 0xFF;
    data[index++] = dateEnd & 0xFF;
    data[index++] = (dateEnd >> 8) & 0xFF;
    
    dateBegin = ints[4];
    dateEnd   = ints[5];
    data[index++] = dateBegin & 0xFF;
    data[index++] = (dateBegin >> 8) & 0xFF;
    data[index++] = dateEnd & 0xFF;
    data[index++] = (dateEnd >> 8) & 0xFF;
    
    dateBegin = ints[6];
    dateEnd   = ints[7];
    data[index++] = dateBegin & 0xFF;
    data[index++] = (dateBegin >> 8) & 0xFF;
    data[index++] = dateEnd & 0xFF;
    data[index++] = (dateEnd >> 8) & 0xFF;
    
    int sum = 0;
    for (int i = 1; i < index; i++) {
        sum += (data[i]) ^ i;
    }
    data[index] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:count];
    [dataPush LogData];
    [self Command:dataPush uuidString:uuid charaUUID:RW_DrinkWaterToRemindTimeSection_UUID];
}



// 校准模式 1:进入  2:保存  3:退出
-(void)setCorrect: (NSString *)uuidString type:(int)type
{
    // 02 05 00 00-FD FA FF FF-00 00 00 00-00 00 00 00 进入传感器 ZERO 校准模式;
    // 02 06 00 00-FD F9 FF FF-00 00 00 00-00 00 00 00 保存传感器 ZERO 校准结果
    // 02 00 00 00-FD FF FF FF-00 00 00 00-00 00 00 00 退出传感器校准模式;
    
   
    char data[18];
    data[0] = DataFirst;
    data[1] = 0x02;
    switch (type) {
        case 1:
            data[2] = 0x05;
            data[6] = 0xFA;
            break;
        case 2:
            data[2] = 0x06;
            data[6] = 0xF9;
            break;
        case 3:
            data[2] = 0x00;
            data[6] = 0xFF;
            break;
            
        default:
            break;
    }
   
    data[3] = 0x00;
    data[4] = 0x00;
    data[5] = 0xFD;
    
    data[7] = 0xFF;
    data[8] = 0xFF;
    data[9] = data[10] = data[11] = data[12] = data[13] = data[14] = data[15] = data[16] = 0x00;
    
    int sum = 0;
    for (int i = 1; i < 17; i++) {
        sum += (data[i]) ^ i;
    }
    data[17] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:18];
    //[dataPush LogData];
    [self Command:dataPush uuidString:uuidString charaUUID:R_Balance_UUID];
}





@end
