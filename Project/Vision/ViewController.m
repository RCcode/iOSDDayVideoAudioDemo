//
//  ViewController.m
//  Demo Day
//
//  Created by zhao liang on 15/3/20.
//  Copyright (c) 2015年 zhao liang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TwoViewController.h"
#import "MP3TableViewCell.h"

@interface ViewController ()<AVAudioPlayerDelegate>

{
    UIButton *button;
    UIButton *label;
    AVAudioPlayer *audioplayer;
    NSMutableArray *array;
    NSArray *titleArray;
    NSInteger cur;
}
@end



//http://music.sogua.com/playernet/player.asp?id=3040n


#define kMusicFile @"http://music.sogua.com/playernet/player.asp?id=3040n"

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        array = [[NSMutableArray alloc]init];
        titleArray = @[@"你有病啊 剪辑版",@"小沈阳 上班最痛苦的事",@"周星驰  搞笑起床独白",@"郭德纲 - 活该，死去",@"林志玲 甜蜜嗲嗲滴来电",@"赵本山范伟经典台词串烧"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    button = [[UIButton alloc]initWithFrame:CGRectMake(20, 50, 60, 40)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"播放" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    label = [[UIButton alloc]initWithFrame:CGRectMake(80, 50, 200, 40)];
    [label setTitle:@"喜欢你" forState:UIControlStateNormal];
    [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    label.backgroundColor = [UIColor yellowColor];
    [label addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:label];
    
    
    
    
    double timer =  audioplayer.duration;
    NSLog(@"%f", timer);
}
-(void)getLocalMusic
{
    NSString *string = [[NSBundle mainBundle] pathForResource:@"1你有病啊 剪辑版.mp3" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:string];
    [array addObject:url];
    
    NSString *string1 = [[NSBundle mainBundle] pathForResource:@"2小沈阳 上班最痛苦的事.mp3" ofType:nil];
    NSURL *url1 = [NSURL fileURLWithPath:string1];
    [array addObject:url1];
    
    NSString *string2 = [[NSBundle mainBundle] pathForResource:@"3周星驰  搞笑起床独白.mp3" ofType:nil];
    NSURL *url2 = [NSURL fileURLWithPath:string2];
    [array addObject:url2];
    
    NSString *string3 = [[NSBundle mainBundle] pathForResource:@"4郭德纲 - 活该，死去.mp3" ofType:nil];
    NSURL *url3 = [NSURL fileURLWithPath:string3];
    [array addObject:url3];

    NSString *string4 = [[NSBundle mainBundle] pathForResource:@"5林志玲 甜蜜嗲嗲滴来电.mp3" ofType:nil];
    NSURL *url4 = [NSURL fileURLWithPath:string4];
    [array addObject:url4];
    
    NSString *string5 = [[NSBundle mainBundle] pathForResource:@"6赵本山范伟经典台词串烧.mp3" ofType:nil];
    NSURL *url5 = [NSURL fileURLWithPath:string5];
    [array addObject:url5];
    
}
-(AVAudioPlayer *)audioPlayer{
    if (!audioplayer) {
        NSError *error=nil;
        NSString *string = [[NSBundle mainBundle] pathForResource:@"1你有病啊 剪辑版.mp3" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:string];
        
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        audioplayer.numberOfLoops=0;//设置为0不循环
        audioplayer.delegate=self;
        [audioplayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return audioplayer;
}

#pragma mark -
#pragma mark UITableViewDataSource

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return (NSInteger)array.count;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"normalCell";
//    MP3TableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[MP3TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    NSString *string = [titleArray objectAtIndex:(NSUInteger)indexPath.row];
//    [cell.titleBtn setTitle:string forState:UIControlStateNormal];
//    cell.playBtn.tag = indexPath.row +100;
//
//    [cell.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
//    
//    return cell;
//}

-(void)click
{
    TwoViewController *vc = [[TwoViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)play{
    if (![self.audioPlayer isPlaying] && button.backgroundColor == [UIColor redColor]) {
        [audioplayer play];
        button.backgroundColor = [UIColor greenColor];
    } else if (button.backgroundColor == [UIColor greenColor]){
        [audioplayer pause];
        button.backgroundColor = [UIColor redColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
