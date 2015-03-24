//
//  TwoViewController.m
//  Demo Day
//
//  Created by zhao liang on 15/3/20.
//  Copyright (c) 2015年 zhao liang. All rights reserved.
//

#import "TwoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PBJViewController.h"


@interface TwoViewController ()<AVAudioPlayerDelegate>

{
    AVAudioPlayer *audioplayer;
    UIButton *button;
    UIButton *makeVideoBtn;
    UILabel *label;
}
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    button = [[UIButton alloc]initWithFrame:CGRectMake(20, 50, 40, 40)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"播放" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    makeVideoBtn = [[UIButton alloc]init];
    makeVideoBtn.backgroundColor = [UIColor redColor];
    [makeVideoBtn setFrame:CGRectMake(20, 150, 40, 40)];
    [makeVideoBtn setTitle:@"试镜" forState:UIControlStateNormal];
    [makeVideoBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [makeVideoBtn addTarget:self action:@selector(makeVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:makeVideoBtn];

    
    NSString *fileName = @"台词.txt";
    NSString *textPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSLog(@"%@",textPath);
    NSString *myText = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
    if (!myText) {
        NSLog(@"读取文件出错");
        return;
    }
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(10, 200, 300, 300)];
    label.lineBreakMode = 0;
    label.numberOfLines = 0;
    
    label.text = myText;
    [self.view addSubview: label];//加入到整个页面中
    
}


-(void)makeVideo
{
    PBJViewController *editVideoViewController = [[PBJViewController alloc]init];
    editVideoViewController.a = (float)audioplayer.duration;
    [self presentViewController:editVideoViewController animated:YES completion:nil];
}



-(AVAudioPlayer *)audioPlayer{
    if (!audioplayer) {
        NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"4郭德纲 - 活该，死去.mp3" ofType:nil];
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        NSError *error=nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        audioplayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        //设置播放器属性
        audioplayer.numberOfLoops=0;//设置为0不循环
        audioplayer.delegate = self;
        [audioplayer prepareToPlay];//加载音频文件到缓存
        double timer =  audioplayer.duration;
        NSLog(@"%f", timer);
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return audioplayer;
}

-(void)play{
    
    if (![self.audioPlayer isPlaying] && button.backgroundColor == [UIColor redColor]) {
        [self.audioPlayer play];
        button.backgroundColor = [UIColor greenColor];
        double timer =  audioplayer.duration;
        NSLog(@"%f", timer);
    } else if (button.backgroundColor == [UIColor greenColor]){
        [self.audioPlayer pause];
        button.backgroundColor = [UIColor redColor];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
