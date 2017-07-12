//
//  ViewController.m
//  MusicPlayer
//
//  Created by 我不是你二大爷 on 15/9/8.
//  Copyright (c) 2015年 张仁杰. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate>
//@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (weak, nonatomic) IBOutlet UIButton *isPlayer;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *leftTime;///<左边的时间Label
@property (weak, nonatomic) IBOutlet UILabel *rightTime;///<右边的时间Label
@property (strong, nonatomic) NSMutableArray *musictime;///<储存歌词时间数组
@property (strong, nonatomic) NSMutableArray *lyrics;///<存储歌词数组

@property (weak, nonatomic) IBOutlet UITableView *lyricsTable;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *AOW_Btn;
@property (strong, nonatomic) NSArray *musicArray;///<储存音乐的数组
@property (copy, nonatomic) NSString *leftTimeString;///<左边的时间
@property (copy, nonatomic) NSString *rightTimeString;///<右边的时间
@property (assign, nonatomic) NSInteger line;///<用来装歌词时间与歌曲时间比较好的位置
@property (strong, nonatomic) NSMutableDictionary *lrcDic;///<储存歌词与时间字典
@property (copy, nonatomic) NSString *lyricPath;///<歌词路径

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.lyricsTable.delegate = self;
    self.lyricsTable.dataSource = self;
    

    self.isPlayer.selected = YES;
    self.volumeSlider.value = 1;
    self.volumeSlider.minimumValue = 0;///<Slider下限值
    self.volumeSlider.maximumValue = 1;///<Slider上限值
    self.index = 0;
    
    [[AudioManager defaultManager] playMusic:KBackGroundMusic1];
    self.rightTime.text = self.rightTimeString;///<音乐右边时间

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMusic) userInfo:NULL repeats:YES];
    self.progressSlider.maximumValue = [[AudioManager defaultManager]musicPlayer].duration;///<设置进度条的上限值等于播放音乐的长度 duration :持续时间
    self.musicName.text = self.musicArray[0];
    self.backgroundImage.image = [UIImage imageNamed:@"Bridge"];
    
    [[AudioManager defaultManager]musicPlayer].delegate = self;

    
    self.lyricsTable.hidden = YES;
    
    [self parselyric];

    [self configPlayingInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent*)event{
    if(event.type == UIEventTypeRemoteControl){
        switch(event.subtype){
                
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
 
                [self resumeOrPause];
                // 切换播放、暂停按钮
                
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                [self playPrev];
                // 播放上一曲按钮
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                
                [self playNext];
                // 播放下一曲按钮
                
                break;
                
            default:
                
                
                break;
        }
    }
}

-(void)updateMusic
{
    self.progressSlider.value = [[AudioManager defaultManager]musicPlayer].currentTime;

    //判断数组是否包含某个元素;
    if ([self.musictime containsObject:self.leftTimeString]) {
        self.line = [self.musictime indexOfObject:self.leftTimeString];
        [self.lyricsTable reloadData];
        //选中 tableView 的这一行;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.line inSection:0];
        [self.lyricsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        
    }

    self.leftTime.text = self.leftTimeString;
}

-(NSString *)leftTimeString
{
    self.leftTimeString = nil;
    if(!_leftTimeString)
   {
        NSString *leftMinutes = [NSString stringWithFormat:@"%02li",(NSInteger)[[AudioManager defaultManager]musicPlayer].currentTime/60];
        NSString *leftSec = [NSString stringWithFormat:@"%02li",(NSInteger)[[AudioManager defaultManager]musicPlayer].currentTime%60];
        NSString *time1 = [NSString stringWithFormat:@"%@:%@",leftMinutes,leftSec];
        _leftTimeString = time1;
    }
    return _leftTimeString;
}

-(NSString *)rightTimeString
{
    self.rightTimeString = nil;
    if(!_rightTimeString)
    {
        NSString *rightMinutes = [NSString stringWithFormat:@"%02li",(NSInteger)[[AudioManager defaultManager]musicPlayer].duration/60];
        NSString *rightSec = [NSString stringWithFormat:@"%02li",(NSInteger)[[AudioManager defaultManager]musicPlayer].duration%60];
        NSString *time2 = [NSString stringWithFormat:@"%@:%@",rightMinutes,rightSec];
        _rightTimeString = time2;
    }
    return _rightTimeString;
}

/**
 * 解析歌词
 */
-(void)parselyric
{
    if([self.musicName.text isEqualToString:KBackGroundMusic1])
    {
        self.lyricPath = [[NSBundle mainBundle]pathForResource:@"老大歌词" ofType:@"lrc"];///<歌词文件路径
    }
    else if([self.musicName.text isEqualToString:kBackGroundMusic])
    {
        self.lyricPath = [[NSBundle mainBundle]pathForResource:@"老大歌词" ofType:@"lrc"];
    }
    if ([self.lyricPath length]) {
        
        //get the lyric string
        NSString *lyc = [NSString stringWithContentsOfFile:self.lyricPath encoding:NSUTF8StringEncoding error:nil];
        
        //init
        _musictime = [[NSMutableArray alloc]init];
        _lyrics = [[NSMutableArray alloc]init];
        self.musictime = [NSMutableArray arrayWithCapacity:0];
        self.lrcDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSArray *array = [lyc componentsSeparatedByString:@"\n"];
        
        for (int i = 0; i < array.count; i++)
        {
            
            NSString *lineString = [array objectAtIndex:i];
            
            NSArray *lineArray = [lineString componentsSeparatedByString:@"]"];
            
            if ([lineArray[0] length] > 7) {
                NSString *str1 = [lineString substringWithRange:NSMakeRange(3, 1)];
                NSString *str2 = [lineString substringWithRange:NSMakeRange(6, 1)];
                if ([str1 isEqualToString:@":"]&&[str2 isEqualToString:@"."])
                {
                    //截取歌词和时间;
                    NSString *timeStr = [lineString substringWithRange:NSMakeRange(1, 5)];
                    NSString *lrcStr = [lineString substringFromIndex:10   ];///<歌词字符串
                    [self.musictime addObject:timeStr];
                    [self.lrcDic setObject:lrcStr forKey:timeStr];

                }
 
            }
        }
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musictime.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[self.lyricsTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *key = self.musictime[indexPath.row ] ;
    cell.textLabel.text = self.lrcDic[key];
    
    if(indexPath.row==self.line)
        
        cell.textLabel.textColor = [UIColor greenColor];
    
    else
    
        cell.textLabel.textColor = [UIColor blackColor];
    
    
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.backgroundColor=[UIColor clearColor];///<设置cell背景色为透明
    tableView.backgroundColor = [UIColor clearColor];///<设置tableView背景色为透明
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;///<隐藏tableView边框线
    cell.selectionStyle = UITableViewCellSelectionStyleNone;///<隐藏cell背景色
    
    
    return cell;
    
}
#pragma mark - 播放器播放暂停按钮
- (IBAction)playerBtn:(UIButton *)sender {
    
    [self resumeOrPause];
}
#pragma mark - 点击音量Slider事件
- (IBAction)volumeController:(UISlider *)sender
{
    [[AudioManager defaultManager]musicPlayer].volume  = sender.value;
}
#pragma mark - 点击进度条Slider事件
- (IBAction)progressSlider:(UISlider *)sender {
    
    [[AudioManager defaultManager]musicPlayer].currentTime = self.progressSlider.value;

}

#pragma mark - 伴奏/原唱
- (IBAction)AccompanyOrWalkers:(UIButton *)sender {
    
    if([sender.titleLabel.text isEqualToString:@"伴奏"]){
        [sender setTitle:@"原唱" forState:UIControlStateNormal];
        [[AudioManager defaultManager]playMusic:self.musicArray[1]];
        [[AudioManager defaultManager]musicPlayer].currentTime = self.progressSlider.value;
    }else{
        [sender setTitle:@"伴奏" forState:UIControlStateNormal];
        [[AudioManager defaultManager]stop];
        [[AudioManager defaultManager]playMusic:self.musicArray[0]];
        [[AudioManager defaultManager]musicPlayer].currentTime = self.progressSlider.value;

    }

}

#pragma mark - 点击左键事件
- (IBAction)leftBtn:(UIButton *)sender
{
    [self playPrev];
}

#pragma mark - 点击右键事件
- (IBAction)rightBtn:(UIButton *)sender
{
    [self playNext];
}

// 切换播放、暂停按钮
- (void) resumeOrPause{
    if(self.isPlayer.selected == YES)
    {
        self.isPlayer.selected = NO;
        [[AudioManager defaultManager]stop];
    }
    else if(self.isPlayer.selected == NO)
    {
        self.isPlayer.selected =YES;
        [[AudioManager defaultManager]play];
    }
}

// 播放上一曲按钮
- (void) playPrev{
    self.index++;
    if(self.index == 1)
    {
        
        [[AudioManager defaultManager]playMusic:self.musicArray[0]];
        self.rightTime.text = self.rightTimeString;
        self.musicName.text = self.musicArray[1];
        self.backgroundImage.image = [UIImage imageNamed:@"Bridge"];
        [self.AOW_Btn setTitle:@"伴奏" forState:UIControlStateNormal];
        [self parselyric];
        [self.lyricsTable reloadData];
    }
    else if(self.index >= self.musicArray.count)
    {
        self.index = 0;
        [[AudioManager defaultManager]playMusic:self.musicArray[0]];
        self.rightTime.text = self.rightTimeString;
        self.musicName.text = self.musicArray[1];
        self.backgroundImage.image = [UIImage imageNamed:@"Bridge"];
        [self.AOW_Btn setTitle:@"伴奏" forState:UIControlStateNormal];
        [self parselyric];
        [self.lyricsTable reloadData];
        
    }
    if(self.isPlayer.selected == NO)
    {
        self.isPlayer.selected = YES;
    }
}

// 播放下一曲按钮
- (void) playNext{
    self.index++;
    if(self.index == 1)
    {
        [[AudioManager defaultManager]playMusic:self.musicArray[0]];
        self.rightTime.text = self.rightTimeString;
        self.musicName.text = self.musicArray[1];
        self.backgroundImage.image = [UIImage imageNamed:@"Bridge"];
        [self parselyric];
        [self.lyricsTable reloadData];
        
    }
    else if(self.index >= self.musicArray.count)
    {
        self.index = 0;
        [[AudioManager defaultManager]playMusic:self.musicArray[0]];
        self.rightTime.text = self.rightTimeString;
        self.musicName.text = self.musicArray[1];
        self.backgroundImage.image = [UIImage imageNamed:@"Bridge"];
        [self.AOW_Btn setTitle:@"伴奏" forState:UIControlStateNormal];
        [self parselyric];
        [self.lyricsTable reloadData];
        
        
    }
    if(self.isPlayer.selected == NO)
    {
        self.isPlayer.selected = YES;
    }
}

- (void)configPlayingInfo{
    if(NSClassFromString(@"MPNowPlayingInfoCenter")){
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:@"Bridge - 老大" forKey:MPMediaItemPropertyTitle];
        
        
        [dict setObject:@"Bridge" forKey:MPMediaItemPropertyArtist];
        
        
        [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Bridge"]]  forKey:MPMediaItemPropertyArtwork];
        
        
        
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
    
}

#pragma mark - AVAudioPlayerDelegate 
/**
 * 自动播放下一首
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNext];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    // 解码失败，自动播放下一首
    [self playNext];
}

//  音乐播放器被打断 (如开始 打、接电话)
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // 会自动暂停  do nothing ...
    NSLog(@"audioPlayerBeginInterruption---被打断");
}

//  音乐播放器打断终止 (如结束 打、接电话)
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    // 手动恢复播放
    [player play];
    NSLog(@"audioPlayerEndInterruption---打断终止");
}

- (IBAction)segment:(UISegmentedControl *)sender
{
    if(self.segment.selectedSegmentIndex == 1)
    {
        self.backgroundImage.alpha = 0.5;
        self.lyricsTable.hidden = NO;
    }
    else if(self.segment.selectedSegmentIndex == 0)
    {
        self.backgroundImage.alpha = 1;
        self.lyricsTable.hidden = YES;
    }
}

-(NSArray *)musicArray
{
    if(!_musicArray)
    {
        _musicArray = @[KBackGroundMusic1,kBackGroundMusic];
    }
    return _musicArray;
}



@end
