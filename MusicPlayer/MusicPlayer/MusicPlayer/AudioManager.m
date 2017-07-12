
//
//  AudioManager.m
//  MusicPlayer
//
//  Created by 张仁杰 on 16/3/4.
//  Copyright © 2016年 张仁杰. All rights reserved.
//

#import "AudioManager.h"
@interface AudioManager()


@end
@implementation AudioManager


+(instancetype)defaultManager
{
    static AudioManager *manager = nil;
    @synchronized(self) {
        if (!manager) {
            manager = [[AudioManager alloc] init];
        }
    }
    return manager;
}
-(BOOL)playMusic:(NSString *)musicFileName
{
    NSURL *musicURL = [[NSBundle mainBundle]URLForResource:musicFileName withExtension:@"mp3"];
    if(!musicURL)
    {
        return NO;
    }
    NSError *error = nil;
    self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:musicURL error:&error];
    if(error)
    {
        NSLog(@"播放文件%@出错,错误为%@",musicFileName,error);
    }
//    self.musicPlayer.numberOfLoops = -1;///<音乐循环播放
    [self.musicPlayer play];
    return YES;
}

-(void)pause
{
    [self.musicPlayer pause];
}

-(void)stop
{
    [self.musicPlayer stop];
//    self.musicPlayer.currentTime = 0;
}

-(BOOL)play
{
    if([self.musicPlayer prepareToPlay])
    {
        [self.musicPlayer play];
        return YES;
    }
    return NO;
}

-(BOOL)isPlaying
{
    return self.musicPlayer.isPlaying;
}


@end
