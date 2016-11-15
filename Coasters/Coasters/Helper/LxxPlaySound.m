//
//  LxxPlaySound.m
//  
//
//  Created by 丁付德 on 15/6/18.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "LxxPlaySound.h"

@implementation LxxPlaySound

-(id)initForPlayingVibrate
{
    self = [super init];
    if (self) {
        soundID = kSystemSoundID_Vibrate;
    }
    return self;
}



 -(id)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type
{
    self = [super init];
    if (self) {
        //NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:resourceName ofType:type];
        NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",resourceName,type];
        
        if (path) {
            SystemSoundID theSoundID;
            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    }
    return self;
}



-(id)initForPlayingSoundEffectWith:(NSString *)filename
{
    self = [super init];
    if (self)
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil)
        {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError)
            {
                soundID = theSoundID;
            }
            else
            {
                NSLog(@"Failed to create sound ");
            }
        }
    }
    return self;
}



-(void)play
{
//    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlaySystemSound(1002);
}


-(void)dealloc
{
     AudioServicesDisposeSystemSoundID(soundID);
}
 @end
