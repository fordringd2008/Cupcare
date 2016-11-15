//
//  Clock.m
//  
//
//  Created by 丁付德 on 15/11/12.
//
//

#import "Clock.h"

@implementation Clock

// Insert code here to add functionality to your man1aged object subclass
-(void)perfect
{
    self.strTime = [NSString stringWithFormat:@" %02d:%02d", [self.hour intValue], [self.minute intValue]];
    //NSLog(@"strTime:%@",self.strTime);
    switch ([self.type intValue])
    {
        case 0:
            self.strType = [NSString stringWithFormat:@" %@", kString(@"普通闹钟")]; // 未设置
            break;
        case 1:
            self.strType = [NSString stringWithFormat:@" %@", kString(@"普通闹钟")];
            break;
        case 2:
            self.strType = [NSString stringWithFormat:@" %@", kString(@"吃药提醒")];
            break;
        case 4:
            self.strType = [NSString stringWithFormat:@" %@", kString(@"要事提醒")];
            break;
            
        default:
            break;
    }
    
    NSMutableString *strRepeat = [NSMutableString new];
    NSArray *arrRepeat = [self.repeat componentsSeparatedByString:@"-"];
    
    if ([arrRepeat[0] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周日")]];
    if ([arrRepeat[1] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周一")]];
    if ([arrRepeat[2] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周二")]];
    if ([arrRepeat[3] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周三")]];
    if ([arrRepeat[4] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周四")]];
    if ([arrRepeat[5] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周五")]];
    if ([arrRepeat[6] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周六")]];
    if (!strRepeat.length)
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"不重复")]];
    self.strRepeat = [NSString stringWithFormat:@"%@", strRepeat];
    if([arrRepeat[0] intValue] && [arrRepeat[1] intValue] && [arrRepeat[2] intValue] && [arrRepeat[3] intValue] && [arrRepeat[4] intValue] && [arrRepeat[5] intValue] && [arrRepeat[6] intValue])
    {
        self.strRepeat = kString(@" 每天");
    }
}



+(void)initClockData
{
    NSArray *arrClock = [Clock findAllInContext:DBefaultContext];
    if (arrClock.count != 8)
    {
        for (int i = 0; i < 8; i++)
        {
            Clock *cl = [Clock MR_createEntityInContext:DBefaultContext];
            cl.iD = @(i);
            cl.type = @0;
            cl.repeat = @"0-0-0-0-0-0-0";
            cl.hour = @0;
            cl.minute = @0;
            cl.strTime = @" 00:00";
            cl.isOn = @NO;
            [cl perfect];
        }
        DBSave;
    }
    else
    {
        for (int i = 0; i < 8; i++)
        {
            Clock *cl = arrClock[i];
            [cl perfect];
        }
        DBSave;
    }
}

+(void)resetClockData
{
    for (int i = 0; i < 8; i++)
    {
        Clock *cl = [Clock MR_createEntityInContext:DBefaultContext];
        cl.iD = @(i);
        cl.type = @(0);
        cl.repeat = @"0-0-0-0-0-0-0";
        cl.hour = @(0);
        cl.minute = @(0);
        cl.strTime = @" 00:00";
        cl.isOn = @(NO);
    }
    DBSave;
}


@end
