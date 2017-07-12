//
//  AudioManager.h
//  MusicPlayer
//
//  Created by 张仁杰 on 16/3/4.
//  Copyright © 2016年 张仁杰. All rights reserved.
//

// 伴奏
#define kBackGroundMusic @"老大伴奏"

// 原声
#define KBackGroundMusic1 @"Bridge - 老大"

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject

@property (nonatomic, strong) NSArray *musicArray;
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;


+(instancetype)defaultManager;
- (BOOL)playMusic:(NSString *)musicFileName;
//-(NSArray *)musicArray;
-(void)pause;///<暂停后继续播放 回到最初
-(void)stop;
-(BOOL)play;
-(BOOL)isPlaying;
@end
