//
//  XCaptureView.h
//  bbm
//
//  Created by QFish on 1/10/14.
//  Copyright (c) 2014 com.geek-zoo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef void (^ XCaptureViewBlock)(void);
typedef void (^ XCaptureViewBlockI)(id result);
typedef CGRect (^ XCaptureViewBlockRS)( CGSize size );

#if TARGET_OS_IPHONE

@interface XCaptureView : UIView
#if !TARGET_IPHONE_SIMULATOR
<CAAction, AVCaptureVideoDataOutputSampleBufferDelegate>
#endif	// #if !TARGET_IPHONE_SIMULATOR

@property (nonatomic, copy)   XCaptureViewBlockRS     targetRect;
@property (nonatomic, assign) BOOL                    mirror;
@property (nonatomic, assign) CGFloat                 rotation;
@property (nonatomic, retain) NSString                * sessionPreset;
@property (nonatomic, assign) CGAffineTransform       layerTransform;
@property (nonatomic, assign) AVCaptureTorchMode      torchMode;
@property (nonatomic, assign) AVCaptureDevicePosition position;

@property (nonatomic, assign, getter = isPaused) BOOL paused;

@property (nonatomic, copy) XCaptureViewBlock  whenReady;
@property (nonatomic, copy) XCaptureViewBlockI whenSuccess;
@property (nonatomic, copy) XCaptureViewBlockI whenFailure;

- (void)stop;
- (void)start;
- (void)toggle;

@end

#else

@interface XCaptureView : NSView

@property (nonatomic, assign) BOOL                    mirror;
@property (nonatomic, assign) CGFloat                 rotation;
@property (nonatomic, retain) NSString                * sessionPreset;
@property (nonatomic, assign) CGAffineTransform       layerTransform;
@property (nonatomic, assign) AVCaptureTorchMode      torchMode;
@property (nonatomic, assign) AVCaptureDevicePosition position;

@property (nonatomic, copy) BeeServiceBlock  whenReady;
@property (nonatomic, copy) BeeServiceBlockO whenSuccess;
@property (nonatomic, copy) BeeServiceBlockO whenFailure;

- (void)stop;
- (void)start;
- (void)toggle;

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
