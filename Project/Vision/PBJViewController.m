//
//  PBJViewController.m
//  Vision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013 Patrick Piemonte. All rights reserved.
//

#import "PBJViewController.h"
#import "PBJVision.h"
#import "PBJStrobeView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>



@interface UIButton (ExtendedHit)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation UIButton (ExtendedHit)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface PBJViewController () <
    PBJVisionDelegate,
    UIAlertViewDelegate,AVAudioPlayerDelegate>


{
    PBJStrobeView *_strobeView;
    UIButton *_doneButton;
    UIButton *_flipButton;
    AVAudioPlayer *audioplayer;
    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    UIProgressView *playProgress;//播放进度
    NSTimer *timer;//进度更新定时器
    
    UIButton *startPlay;
    NSTimer *timer1;
    float second;
    UIActivityIndicatorView *activity;
    BOOL _recording;

    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
}

@end

@implementation PBJViewController

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
        [self _setup];
        second = 0;
    }
    return self;
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


-(NSTimer *)timer{
    if (!timer) {
        timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:true];
    }
    return timer;
}



- (void)_setup
{
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    // done button
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(viewWidth - 20.0f - 20.0f, 20.0f, 20.0f, 20.0f);
    
    UIImage *buttonImage = [UIImage imageNamed:@"capture_yep"];
    [_doneButton setImage:buttonImage forState:UIControlStateNormal];
    
    [_doneButton addTarget:self action:@selector(_handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    
    // elapsed time and red dot
    _strobeView = [[PBJStrobeView alloc] initWithFrame:CGRectZero];
    CGRect strobeFrame = _strobeView.frame;
    strobeFrame.origin = CGPointMake(15.0f, 15.0f);
    _strobeView.frame = strobeFrame;
    [self.view addSubview:_strobeView];

    
    // preview
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectZero;
    previewFrame.origin = CGPointMake(0, 60.0f);
    CGFloat previewWidth = self.view.frame.size.width;
    previewFrame.size = CGSizeMake(previewWidth, previewWidth);
    _previewView.frame = previewFrame;

    // add AV layer
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    CGRect previewBounds = _previewView.layer.bounds;
    _previewLayer.bounds = previewBounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.position = CGPointMake(CGRectGetMidX(previewBounds), CGRectGetMidY(previewBounds));
    [_previewView.layer addSublayer:_previewLayer];
    [self.view addSubview:_previewView];

    // flip button
    _flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *flipImage = [UIImage imageNamed:@"capture_flip"];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    
    _flipButton.frame = CGRectMake(20, self.view.frame.size.height - 50, 20, 20);
    
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flipButton];
    
    
    playProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 150, self.view.frame.size.width - 20, 20)];
    
    [self.view addSubview:playProgress];
    
    
    startPlay = [[UIButton alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height - 100, 100, 30)];
    [startPlay setTitle:@"开始" forState:UIControlStateNormal];
    [startPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startPlay.backgroundColor = [UIColor blueColor];
    [startPlay addTarget:self action:@selector(clickTostartPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startPlay];
    
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//指定进度轮的大小
    
    [activity setCenter:CGPointMake(160, 140)];//指定进度轮中心点
    
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
    
    [self.view addSubview:activity];

    
}

#pragma mark - view lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PBJVision sharedInstance] stopPreview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [[PBJVision sharedInstance] pauseVideoCapture];
}

- (void)_resumeCapture
{
    [[PBJVision sharedInstance] resumeVideoCapture];
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
}

- (void)_resetCapture
{
    [_strobeView stop];

    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraDevice:PBJCameraDeviceBack];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeAutoFocus];
}

#pragma mark - UIButton

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    if (vision.cameraDevice == PBJCameraDeviceBack) {
        [vision setCameraDevice:PBJCameraDeviceFront];
    } else {
        [vision setCameraDevice:PBJCameraDeviceBack];
    }
}

- (void)_handleDoneButton:(UIButton *)button
{
    // resets long press
    [self _endCapture];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - UIGestureRecognizer

-(void)clickTostartPlay:(UIButton *)button
{
    if (button.backgroundColor == [UIColor blueColor]) {
        
            [self _startCapture];
            [self.audioPlayer play];
            self.timer.fireDate=[NSDate distantPast];//恢复定时器
            button.backgroundColor = [UIColor grayColor];
        [button setTitle:@"取消" forState:UIControlStateNormal];
         timer1 = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    } else {
        if ([self.audioPlayer isPlaying]) {
            [self _endCapture];
            [self.audioPlayer pause];
            self.timer.fireDate=[NSDate distantFuture];//暂停定时器，注意不能调用invalidate方法，此方法会取消，之后无法恢复
        }
        button.backgroundColor = [UIColor blueColor];
        [button setTitle:@"开始" forState:UIControlStateNormal];
    }
    
    
}

-(void)timerAction
{
    second++;
//    NSLog(@"%d",second);
    int a = (int)audioplayer.duration * 20;
    if (second == a){
        
         [self _endCapture];
        [activity startAnimating];
        
         [playProgress setProgress:0.0f];
        startPlay.backgroundColor = [UIColor blueColor];
        [startPlay setTitle:@"开始" forState:UIControlStateNormal];
        second = 0;
    }
}

//- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//{
//    
//    switch (gestureRecognizer.state) {
//      case UIGestureRecognizerStateBegan:
//        {
//            if (!_recording){
//                [self _startCapture];
//                [self.audioPlayer play];
//                self.timer.fireDate=[NSDate distantPast];//恢复定时器
//            }
//            else{
//                [self _resumeCapture];
//                [self.audioPlayer play];
//                self.timer.fireDate=[NSDate distantPast];//恢复定时器
//            }
//            break;
//        }
//      case UIGestureRecognizerStateEnded:
//      case UIGestureRecognizerStateCancelled:
//      case UIGestureRecognizerStateFailed:
//        {
//            [self _pauseCapture];
//            [self.audioPlayer pause];
//            self.timer.fireDate=[NSDate distantFuture];
//            break;
//        }
//      default:
//        break;
//    }
//}


-(void)updateProgress{
    
    double progress = audioplayer.currentTime /audioplayer.duration;
//    NSLog(@"%f", audioplayer.currentTime);
    [playProgress setProgress:(float)progress animated:true];
    if (audioplayer.currentTime == audioplayer.duration) {
        [self _pauseCapture];
//        button.backgroundColor = [UIColor blueColor];
//        [button setTitle:@"开始" forState:UIControlStateNormal];
    }
    
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
        audioplayer.delegate=self;
        [audioplayer prepareToPlay];//加载音频文件到缓存
        if(error){
            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            return nil;
        }
    }
    return audioplayer;
}



#pragma mark - PBJVisionDelegate

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
}

- (void)visionPreviewDidStart:(PBJVision *)vision
{
   
}

- (void)visionPreviewWillStop:(PBJVision *)vision
{
  
}

- (void)visionModeWillChange:(PBJVision *)vision
{
}

- (void)visionModeDidChange:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision cleanApertureDidChange:(CGRect)cleanAperture
{
}

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    [_strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    _recording = NO;

    if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    _currentVideo = videoDict;
    
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    
    NSString *videoUrlPath = [ NSString stringWithFormat : @"file://%@" ,videoPath];
    
    NSString *path =[[NSBundle mainBundle]pathForResource:@"4郭德纲 - 活该，死去.mp3" ofType:nil];
    
    NSURL *audioUrl = [ NSURL fileURLWithPath :path];
    
    AVURLAsset * audioAsset = [[ AVURLAsset alloc ] initWithURL :audioUrl options : nil ];
    
    NSLog ( @"audioAsset===%@==" ,audioAsset);
    
    float duration = (float)audioAsset.duration.value/(float)audioAsset.duration.timescale;
    NSLog ( @"audioAsset===%f==" ,duration);
    
    AVURLAsset * videoAsset = [[ AVURLAsset alloc ] initWithURL :[ NSURL URLWithString :videoUrlPath] options : nil ];
    
    NSLog ( @"videoAsset===%@==" ,videoAsset);
    
    // 下面就是合成的过程了。
    
    AVMutableComposition * mixComposition = [ AVMutableComposition composition ];
    
    AVMutableCompositionTrack *compositionCommentaryTrack = [mixComposition addMutableTrackWithMediaType : AVMediaTypeAudio
                                                             
                                                                                        preferredTrackID : kCMPersistentTrackID_Invalid ];
    
    [compositionCommentaryTrack insertTimeRange : CMTimeRangeMake ( kCMTimeZero , audioAsset. duration )
     
                                        ofTrack :[[audioAsset tracksWithMediaType : AVMediaTypeAudio ] objectAtIndex : 0 ]
     
                                         atTime : kCMTimeZero error : nil ];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType : AVMediaTypeVideo
                                                        
                                                                                   preferredTrackID : kCMPersistentTrackID_Invalid ];
    
    [compositionVideoTrack insertTimeRange : CMTimeRangeMake ( kCMTimeZero , videoAsset. duration )
     
                                   ofTrack :[[videoAsset tracksWithMediaType : AVMediaTypeVideo ] objectAtIndex : 0 ]
     
                                    atTime : kCMTimeZero error : nil ];
    
    
    AVAssetExportSession * _assetExport = [[ AVAssetExportSession alloc ] initWithAsset :mixComposition
                                          
                                                                            presetName : AVAssetExportPresetPassthrough ];
    
    NSString * videoName = @"export.mov" ; // 这里换成 wmv 格式的就不行了。
    
    NSString *exportPath = [ NSTemporaryDirectory () stringByAppendingPathComponent :videoName];
    
    NSLog ( @"exportPaht === %@" ,exportPath);
    
    NSURL     *exportUrl = [ NSURL fileURLWithPath :exportPath];
    
    if ([[ NSFileManager defaultManager ] fileExistsAtPath :exportPath])
        
        [[ NSFileManager defaultManager ] removeItemAtPath :exportPath error : nil ];
    
    _assetExport. outputFileType = @"com.apple.quicktime-movie" ;
    
    NSLog ( @"file type %@" ,_assetExport. outputFileType );
    
    _assetExport. outputURL = exportUrl;
    
    _assetExport. shouldOptimizeForNetworkUse = YES ;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler :
     
     ^( void ) {
    
    [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:exportPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        [activity removeFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];
     }];
}

@end
