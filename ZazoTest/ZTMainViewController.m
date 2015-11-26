//
//  ZTMainViewController.m
//  ZazoTest
//
//  Created by Usman Awan on 11/11/15.
//  Copyright © 2015 Usman Awan. All rights reserved.
//

#import "ZTMainViewController.h"

#import "ZTMainPresenter.h"

#import "ZTVideoItem.h"

#import "UIView+TSToast.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVKit/AVKit.h>

@interface ZTMainViewController () <AVCaptureFileOutputRecordingDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZTMainPresenter *mainPresenter;

@property (weak, nonatomic) IBOutlet UIView *centerPreviewView;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *otherPreviewCollection;

@property (strong, nonatomic) NSMutableArray *videoItemsArray;
@property (nonatomic) NSInteger currentActiveCellTag;

@property (strong, nonatomic) AVCaptureMovieFileOutput *fileOutput;

- (IBAction)resetButtonAction:(id)sender;


@end

@implementation ZTMainViewController

#pragma mark -- View Lifecycle Method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Zazo Test Task";

    _mainPresenter = [[ZTMainPresenter alloc] init];
    
    [_mainPresenter configureUserInterfaceForPresentation:self];
    
    [_mainPresenter fetchVideoEntries];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //Session intialization
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetLow;

    //Configuring Front Camera as Session Input
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    captureVideoPreviewLayer.frame = self.centerPreviewView.bounds;
    [self.centerPreviewView.layer addSublayer:captureVideoPreviewLayer];
    
    NSArray *possibleVideoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontCam;
    
    if (possibleVideoDevices && [possibleVideoDevices count]) {
        frontCam = [possibleVideoDevices lastObject];
    }
    
    NSError *errorVideo = nil;
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:frontCam error:&errorVideo];
    
    if (!inputVideo) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", errorVideo);
        [self presentingAlertWithTitle:@"Zazo Test" andMessage:@"Unable to open Camera Preview"];
    }else{
        [session addInput:inputVideo];
    }
    
    //Configuring Microphone as Session Input
    NSArray *possibleAudioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    AVCaptureDevice *microphone;
    
    if (possibleAudioDevices && [possibleAudioDevices count]) {
        microphone = [possibleAudioDevices firstObject];
    }

    NSError *errorAudio = nil;
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:microphone error:&errorAudio];
    
    if (!inputAudio) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open microphone: %@", errorAudio);
        [self presentingAlertWithTitle:@"Zazo Test" andMessage:@"Unable to open microphone"];
    }else{
        [session addInput:inputAudio];
    }
    
    //Configuring File for session output for record and save file.
    _fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 TotalSeconds = 60;			//Total seconds
    int32_t preferredTimeScale = 30;	//Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
    _fileOutput.maxRecordedDuration = maxDuration;
    
    _fileOutput.minFreeDiskSpaceLimit = 1024 * 1024;//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
    
    [session beginConfiguration];
    if ([session canAddOutput:_fileOutput])
        [session addOutput:_fileOutput];
    
    
    
    [session commitConfiguration];
    
    [session startRunning];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- ZTMainViewInterface Delegate Method

-(void) requestingCameraAndMicrophonePermission {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
                }else
                {
                    [self presentingAlertWithTitle:@"Zazo Test" andMessage:@"Please give microphone access for recording audio."];
                }
            }];
        }else{
            [self presentingAlertWithTitle:@"Zazo Test" andMessage:@"Please give camera access for recording video."];
        }
    }];
}

- (void)formattingPreviewCells
{
    // Formatting other video preview cells
    for (UIView *aView in _otherPreviewCollection) {
        
        // Formatting other video preview cells
        
        aView.layer.borderColor = [UIColor colorWithRed:129.f/225.0f green:176.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
        aView.layer.borderWidth = 1.0f;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration=1;
        longPress.numberOfTouchesRequired = 1;
        
        [aView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [longPress requireGestureRecognizerToFail:longPress];
        
        [aView addGestureRecognizer:tapGesture];
    
    }
}

- (void)loadVideoItemsInPreviews:(NSArray *)videoItemsArray
{
    _videoItemsArray = [NSMutableArray arrayWithArray:videoItemsArray];
    
    for (UIView *aView in _otherPreviewCollection) {
        ZTVideoItem *videoItem;
        for (ZTVideoItem *aVideoItem in _videoItemsArray) {
            
            NSInteger videoItemName = [aVideoItem.name integerValue];
            NSInteger videoItemTag = [aView tag];
            if (videoItemName == videoItemTag) {
                videoItem = aVideoItem;
                break;
            }
        }
        
        if (videoItem) {
            [self addVideoPlayerLayerInView:aView
                               withFileName:videoItem.localPath];
        }
    }
}

- (void)removeVideoEntriesFromView
{
    for (UIView *aView in _otherPreviewCollection) {
        for (CALayer *layer in aView.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    }
}

- (void) presentingAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [myAlertController addAction:ok];
    [self presentViewController:myAlertController animated:YES completion:nil];
}

#pragma mark -- Gestures Recognizers Action Methods

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    UIView *view = [sender view];
    
    _currentActiveCellTag = [view tag];
    
    CALayer *viewLayer = self.centerPreviewView.layer;
    
    viewLayer.borderColor = [UIColor redColor].CGColor;
    if ([sender state] == UIGestureRecognizerStateBegan) {
        viewLayer.borderWidth = 2.0f;
        
        
        NSURL *documentDirectory = [self getDocumentDirectory];
        
        NSString *outputPath = [documentDirectory.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.mp4",(long)_currentActiveCellTag]];
        
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        
        [_fileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        
    }else if([sender state] == UIGestureRecognizerStateEnded){
        [_fileOutput stopRecording];
        
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    
    UIView *view = [sender view];
    _currentActiveCellTag = [view tag];
    
    [self playVideoItemInView:view];
}

#pragma mark -- Audio Recorder Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    CALayer *viewLayer = self.centerPreviewView.layer;
    viewLayer.borderWidth = 0.0f;
    
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            recordedSuccessfully = [value boolValue];
        }
        [self.view makeToast:@"Video recorded started" duration:1.0f position:@"bottom" disableView:NO];
    }
    if (recordedSuccessfully)
    {
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        UIView *view = [self.otherPreviewCollection objectAtIndex:
                    _currentActiveCellTag];
        NSString *videoName = [NSString stringWithFormat:@"%ld",(long)_currentActiveCellTag];
        NSDate *date = [NSDate date];
        NSString *videoLocalPath = [NSString stringWithFormat:@"%@.mp4",videoName];
        
        [self addVideoPlayerLayerInView:view
                            withFileName:videoLocalPath];

        //Saving video item in local database
        
        [self saveVideoItemWithName:videoName
                           duration:nil
                               date:date
                        andFilePath:videoLocalPath];
        
        [self.view makeToast:@"Video recorded succesfully" duration:1.0f position:@"bottom" disableView:NO];
        
    }
}

#pragma mark -- Video Method

- (void)addVideoPlayerLayerInView:(UIView *)activeView withFileName:(NSString *)fileName
{
    NSURL *documentDirectory = [self getDocumentDirectory];
    
    NSString *outputPath = [documentDirectory.path stringByAppendingPathComponent:fileName];
    
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    
    for (CALayer *layer in activeView.layer.sublayers) {
        [layer removeFromSuperlayer];
    }
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[outputPath stringByReplacingOccurrencesOfString:@"file:///" withString:@"/"]];
    if (fileExists) {
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:outputURL];
        
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerLayer.frame = activeView.bounds;
        [playerLayer setTimeOffset:1.0];
        [activeView.layer addSublayer:playerLayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[player currentItem]];
    }
    
}

- (void)saveVideoItemWithName:(NSString *)name duration:(NSNumber *)duration date:(NSDate *)date andFilePath:(NSString *)filePath
{
    [_mainPresenter saveVideoEntryWithName:name date:date duration:duration serverPath:nil localPath:filePath];
}

- (void)playVideoItemInView:(UIView *)activeView
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[[activeView.layer sublayers] firstObject];
    playerLayer.player.volume = 1.0f;
    [playerLayer.player play];
}

#pragma mark -- Video Event Callback
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

#pragma mark -- Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -- Button Action Method

- (IBAction)resetButtonAction:(id)sender {
    
    UIAlertController *removeVideosEntriesController = [UIAlertController alertControllerWithTitle:@"Zazo Test Task" message:@"Are you sure you want to delete video entries?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:@"Cancel"
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction * action)
                         {
                             
                             [removeVideosEntriesController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [_mainPresenter removeAllVideoEntries];
                             [removeVideosEntriesController dismissViewControllerAnimated:YES completion:nil];
                             [self.view makeToast:@"Video previews removed succesfully" duration:1.0f position:@"bottom" disableView:NO];
                             
                         }];
    
    [removeVideosEntriesController addAction: cancel];
    [removeVideosEntriesController addAction: ok];
    [self presentViewController:removeVideosEntriesController animated:YES completion:nil];
    
    
    
}

- (NSURL *)getDocumentDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] firstObject];
}

@end
