//
//  ZxingController.m
//  tabbarDemo
//
//  Created by WebosterBob on 4/27/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ZxingController.h"
#import "imageViewController.h"

#define SCANNER_WIDTH 200.0f

@interface ZxingController ()

- (IBAction)returnImageView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *decodeLabel;
@property (weak, nonatomic) IBOutlet UIView *zxingScanView;
@property (strong,nonatomic) ZXCapture *capture;

@end

@implementation ZxingController
{
    CGFloat scanner_X;
    CGFloat scanner_Y;
    CGRect viewFrame;
}
@synthesize decodeLabel = _decodeLabel;
@synthesize zxingScanView = _zxingScanView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)returnImageView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

//扫描线动画
-(void)lineAnimation
{
    float y = self.lineView.frame.origin.y;
    if (y <= scanner_Y)
    {
        self.willUp = NO;
    }
    else if(y >= scanner_Y+SCANNER_WIDTH)
    {
        self.willUp = YES;
    }
    
    if(self.willUp)
    {
        y -= 2;
        self.lineView.frame = CGRectMake(scanner_X, y, SCANNER_WIDTH, 2);
    }
    else
    {
        y += 2;
        self.lineView.frame = CGRectMake(scanner_X, y, SCANNER_WIDTH, 2);
    }
}

-(void)initBackgroundView
{
    CGRect scannerFrame = CGRectMake(scanner_X, scanner_Y,SCANNER_WIDTH, SCANNER_WIDTH);
    float x = scannerFrame.origin.x;
    float y = scannerFrame.origin.y;
    float width  = scannerFrame.size.width;
    float height = scannerFrame.size.height;
    float mainWidth  = viewFrame.size.width;
    float mainHeight = viewFrame.size.height;
    
    UIView *upView    = [[UIView alloc]initWithFrame:CGRectMake(0,       70,          mainWidth,             y)];
    UIView *leftView  = [[UIView alloc]initWithFrame:CGRectMake(0,       y+70,        x,                     height)];
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(x+width, y+70,        mainWidth - x - width, height)];
    UIView *downView  = [[UIView alloc]initWithFrame:CGRectMake(0,       y+height+70, mainWidth,             mainHeight-y-height)];
    
    NSArray *viewArray = [NSArray arrayWithObjects:upView,downView,leftView,rightView, nil];
    for (UIView *view in viewArray)
    {
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        [self.view addSubview:view];
    }
}

#pragma mark - View Controller Methods
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"enter xib");
    
    self.capture = [[ZXCapture alloc] init];
    NSLog(@"open camera");
    self.capture.delegate = self;
    self.capture.rotation = 90.0f;
    self.capture.camera = self.capture.back;          //use the back camera
    self.capture.layer.frame = self.view.bounds;
    [_zxingScanView.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.decodeLabel];
        
    //坐标初始化
    CGRect frame = _zxingScanView.frame;
    //如果是ipad，横屏，交换坐标
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        viewFrame = CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);
    }else{
        viewFrame = _zxingScanView.frame;
    }
    CGPoint centerPoint = CGPointMake(viewFrame.size.width/2, viewFrame.size.height/2 + 35);
    //扫描框的x、y坐标
    scanner_X = centerPoint.x - (SCANNER_WIDTH/2);
    scanner_Y = centerPoint.y - (SCANNER_WIDTH/2);
    
    //扫描框
    UIImageView *borderView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"border"]];
    borderView.frame = CGRectMake(scanner_X-5, scanner_Y-5, SCANNER_WIDTH+10, SCANNER_WIDTH+10);
    [self.view addSubview:borderView];
    //扫描线
    self.lineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
    self.lineView.frame = CGRectMake(scanner_X, scanner_Y, SCANNER_WIDTH, 2);
    [self.view addSubview:self.lineView];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
    NSString *formatString;
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    NSLog(@"%@,%@", formatString,result.text);
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];

}

#pragma mark - ZXCaptureDelegate Methods
- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    if (result) {
        // We got a result. Display information about the result onscreen.
        [self.decodeLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];
        
        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
