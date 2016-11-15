//
//  LxxPlaySound.h
//  
//
//  Created by 丁付德 on 15/6/18.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface LxxPlaySound : NSObject
{
    SystemSoundID soundID;
}



/**
    20
    21  *  @brief  为播放震动效果初始化
    22
    23  *
    24
    25  *  @return self
    26
    27  */
-(id)initForPlayingVibrate;



/**
    34
    35  *  @brief  为播放系统音效初始化(无需提供音频文件)
    36
    37  *
    38
    39  *  @param resourceName 系统音效名称
    40
    41  *  @param type 系统音效类型
    42
    43  *
    44
    45  *  @return self
    46
    47  */

-(id)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type;



/**
    54
    55  *  @brief  为播放特定的音频文件初始化（需提供音频文件）
    56
    57  *
    58
    59  *  @param filename 音频文件名（加在工程中）
    60
    61  *
    62
    63  *  @return self
    64
    65  */

-(id)initForPlayingSoundEffectWith:(NSString *)filename;



/**
    72 
    73  *  @brief  播放音效
    74 
    75  */

-(void)play;



@end
