//
//  XCaptureView.m
//  bbm
//
//  Created by QFish on 1/10/14.
//  Copyright (c) 2014 com.geek-zoo. All rights reserved.
//

#import "ZXingObjC.h"
#import "XCaptureView.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@interface XCaptureView()
#if !TARGET_IPHONE_SIMULATOR
{
	int  _orderInSkip;
	int  _orderOutSkip;
	BOOL _running;
	BOOL _cameraIsReady;
}

@property (nonatomic, retain) id<ZXReader> reader;
@property (nonatomic, retain) ZXDecodeHints * hints;

@property (nonatomic, retain) AVCaptureDevice  * device;
@property (nonatomic, retain) AVCaptureSession * session;
@property (nonatomic, retain) AVCaptureDeviceInput * deviceInput;
@property (nonatomic, retain) AVCaptureVideoDataOutput * videoDataOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer * previewLayer;

@property (nonatomic, strong) dispatch_queue_t captureQueue;
#endif
@end

@implementation XCaptureView

#if !TARGET_IPHONE_SIMULATOR
- (void)dealloc
{
	self.whenReady = nil;
	self.whenFailure = nil;
	self.whenSuccess = nil;
	
	if ( _deviceInput && _session )
		[_session removeInput:_deviceInput];

	if ( _videoDataOutput && _session )
		[_session removeOutput:_videoDataOutput];

	if (_captureQueue) {
//		dispatch_release(_captureQueue);
		_captureQueue = nil;
	}
	
	self.previewLayer = nil;
	self.reader = nil;
	self.hints = nil;
}

- (void)initialize
{
	_paused	  = NO;
    _mirror   = NO;
    _rotation = 90.f;
	_cameraIsReady = NO;
    _position = AVCaptureDevicePositionBack;
	_layerTransform = CGAffineTransformIdentity;
	
	_captureQueue = dispatch_queue_create("bee.service.zxing", NULL);
	
	self.session = [[AVCaptureSession alloc] init];
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
	_previewLayer.frame = CGRectZero;
	_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_previewLayer setAffineTransform:_layerTransform];
	
	[self.layer addSublayer:_previewLayer];
	
    self.reader = [[ZXQRCodeReader alloc] init];
    self.hints  = [ZXDecodeHints hints];
    [self.hints addPossibleFormat:kBarcodeFormatQRCode];
}

- (id)init
{
	self = [super init];
	if ( self ) {
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self ) {
		[self initialize];
	}
	return self;
}

- (BOOL)isPaused
{
    return _paused;
}

- (void)layoutSubviews
{
	self.previewLayer.frame = self.frame;
}

// Adapted from http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/ and https://github.com/JanX2/CreateRotateWriteCGImage
- (CGImageRef)createRotatedImage:(CGImageRef)original degrees:(float)degrees {
    if (degrees == 0.0f) {
        return original;
    } else {
        double radians = degrees * M_PI / 180;
        
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians;
#endif
        
        size_t _width = CGImageGetWidth(original);
        size_t _height = CGImageGetHeight(original);
        
        CGRect imgRect = CGRectMake(0, 0, _width, _height);
        CGAffineTransform _transform = CGAffineTransformMakeRotation(radians);
        CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, _transform);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     rotatedRect.size.width,
                                                     rotatedRect.size.height,
                                                     CGImageGetBitsPerComponent(original),
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
        CGContextSetAllowsAntialiasing(context, FALSE);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGColorSpaceRelease(colorSpace);
        
        CGContextTranslateCTM(context,
                              +(rotatedRect.size.width/2),
                              +(rotatedRect.size.height/2));
        CGContextRotateCTM(context, radians);
        
        CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                                               -imgRect.size.height/2,
                                               imgRect.size.width,
                                               imgRect.size.height),
                           original);
        
        CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        
        return rotatedImage;
    }
}

#pragma mark - setup CaptureDevice

- (AVCaptureDevice *)device
{
	if ( !_device )
	{
		NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
		
		for ( AVCaptureDevice * device in devices ) {
			if ( device.position == _position ) {
				_device = device;
				break;
			}
		}
		
		if ( !_device )
			_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	}
	
	return _device;
}

- (void)setupCaptureSession
{
	[_session beginConfiguration];
	
	if ( _session && _deviceInput )
	{
		[_session removeInput:_deviceInput];
		self.deviceInput = nil;
	}
	
	AVCaptureDevice * device = self.device;
	NSError * error = nil;
	
	if ( device )
	{
		self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
		
		if ( !error )
		{
			if ( !_sessionPreset )
				_sessionPreset = AVCaptureSessionPresetMedium;
			if ( [_session canSetSessionPreset:_sessionPreset] )
				_session.sessionPreset = _sessionPreset;
			if ( [_session canAddInput:_deviceInput] )
				[_session addInput:_deviceInput];
		}
//		else
//		{
//			NSLog( @"%@", error );
//		}
	}
	
	[_session commitConfiguration];
}

- (AVCaptureVideoDataOutput *)videoDataOutput
{
	if ( !_videoDataOutput )
	{
		_videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
		
		NSDictionary * settings = @{
		    (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA) };
		
		[_videoDataOutput setVideoSettings:settings];
		[_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
		[_videoDataOutput setSampleBufferDelegate:self queue:self.captureQueue];
	}

	return _videoDataOutput;
}

#pragma mark -

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
	_torchMode = torchMode;
	
	[_deviceInput.device lockForConfiguration:nil];
	_deviceInput.device.torchMode = torchMode;
	[_deviceInput.device unlockForConfiguration];
}

- (void)setLayerTransform:(CGAffineTransform)layerTransform
{
	_layerTransform = layerTransform;
	_previewLayer.affineTransform = layerTransform;
}

- (void)setPosition:(AVCaptureDevicePosition)position
{
	_position = position;
	
	[self setDevice:nil];
	[self setupCaptureSession];
}

- (void)start
{
	if ( _running )
		return;

    if ( !self.previewLayer.session )
    {
        [self setupCaptureSession];
        [self.previewLayer setSession:self.session];
    }

	if ( _whenSuccess ) {
				
		if ( [self.session canAddOutput:self.videoDataOutput] ) {
			[self.session addOutput:self.videoDataOutput];
		}
	}
	
	if ( !self.session.running ) {
		[self.session startRunning];
	}
	
	_running = YES;
}

- (void)stop
{
	if ( !_running )
		return;
	
	if ( self.session.running )
		[self.session stopRunning];
	
	_running = NO;
	_cameraIsReady = NO;
}

- (void)toggle
{
	if ( _running )
	{
		[self stop];
	}
	else
	{
		 [self start];
	}
}

- (BOOL)hasFrontCamera
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1;
}

- (BOOL)hasBackCamera
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0;
}

- (BOOL)hasTorch
{
	return ( self.device == nil && _device.hasTorch );
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
	if ( !_running || _paused )
		return;
	
	@autoreleasepool
	{
		if ( !_cameraIsReady )
		{
			_cameraIsReady = YES;

			if ( self.whenReady )
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					self.whenReady();
				});
			}
		}
		
		if ( self.whenSuccess )
		{
            CVImageBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
            // rotate
			CGImageRef videoFrameImage = [ZXCGImageLuminanceSource createImageFromBuffer:videoFrame];
            CGImageRef rotatedImage = [self createRotatedImage:videoFrameImage degrees:self.rotation];
            CFRelease(videoFrameImage);
            
            // crop if needed
            if ( self.targetRect )
            {
                CGRect cropFrame = self.targetRect( CGSizeMake(CGImageGetWidth(rotatedImage), CGImageGetHeight(rotatedImage)) );
                CGImageRef croppedImage = CGImageCreateWithImageInRect( rotatedImage, cropFrame );
                CFRelease(rotatedImage);
                rotatedImage = croppedImage;
            }

            ZXCGImageLuminanceSource * source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:rotatedImage];
            CFRelease(rotatedImage);
            
			ZXHybridBinarizer * binarizer = [[ZXHybridBinarizer alloc] initWithSource:source];
			ZXBinaryBitmap * bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
			
			NSError *error;
			ZXResult *result = [self.reader decode:bitmap hints:self.hints error:&error];
            
			if (result)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					self.whenSuccess(result);
				});
			}
			else
			{
				if ( self.whenFailure ) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.whenFailure(error);
					});
				}
			}
		}
	};
}

#else

- (void)stop{}
- (void)start{}
- (void)toggle{}

#endif
#endif //  (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@end