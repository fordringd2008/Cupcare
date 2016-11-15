/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderViewController.h"
#import "QRCameraSwitchButton.h"
#import "QRCodeReaderView.h"
#import "UIViewController+GetAccess.h"
//#import "ZBarSDK.h"

#import <ZXingObjC/ZXingObjC.h>
#import <AVFoundation/AVFoundation.h>

#define mainHeight     [[UIScreen mainScreen] bounds].size.height
#define mainWidth      [[UIScreen mainScreen] bounds].size.width
#define navBarHeight   self.navigationController.navigationBar.frame.size.height

@interface QRCodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate,QRCodeReaderViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> // ZBarReaderDelegate
@property (strong, nonatomic) QRCameraSwitchButton *switchCameraButton;
@property (strong, nonatomic) QRCodeReaderView     *cameraView;
@property (strong, nonatomic) AVAudioPlayer        *beepPlayer;
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) UIImageView          *imgLine;
@property (strong, nonatomic) UILabel              *lblTip;
@property (strong, nonatomic) NSTimer              *timerScan;

@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDevice            *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) CIDetector *detector;

@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation QRCodeReaderViewController

- (id)init
{
    NSString * wavPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
    NSData* data = [[NSData alloc] initWithContentsOfFile:wavPath];
    _beepPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    
    return [self initWithCancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
    if ((self = [super init])) {
        self.view.backgroundColor = [UIColor blackColor];

        [self setupAVComponents];
        [self configureDefaultComponents];
        [self setupUIComponentsWithCancelButtonTitle:cancelTitle];
        [self setupAutoLayoutConstraints];

        [_cameraView.layer insertSublayer:self.previewLayer atIndex:0];
    }
    return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
  return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButton:nil text:@"返回"];
    [self initRightButton:nil text:@"相册"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAccessNext:CameraAccess block:^{}];
    [self startScanning];
}

-(void)rightButtonClick
{
    [self getAccessNext:PhotosAccess block:^{}];
    [self clickRightBarButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self stopScanning];
  [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  _previewLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (void)scanAnimate
{
    _imgLine.frame = CGRectMake(0, _cameraView.innerViewRect.origin.y, mainWidth, 12);
    [UIView animateWithDuration:2 animations:^{
        _imgLine.frame = CGRectMake(_imgLine.frame.origin.x, _imgLine.frame.origin.y + _cameraView.innerViewRect.size.height - 6, _imgLine.frame.size.width, _imgLine.frame.size.height);
    }];
}

- (void)loadView:(CGRect)rect
{
    _imgLine.frame = CGRectMake(0, _cameraView.innerViewRect.origin.y, mainWidth, 12);
    [self scanAnimate];
}

#pragma mark - Managing the Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  [_cameraView setNeedsDisplay];
  
  if (self.previewLayer.connection.isVideoOrientationSupported) {
    self.previewLayer.connection.videoOrientation = [[self class] videoOrientationFromInterfaceOrientation:toInterfaceOrientation];
  }
}

+ (AVCaptureVideoOrientation)videoOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  switch (interfaceOrientation) {
    case UIInterfaceOrientationLandscapeLeft:
      return AVCaptureVideoOrientationLandscapeLeft;
    case UIInterfaceOrientationLandscapeRight:
      return AVCaptureVideoOrientationLandscapeRight;
    case UIInterfaceOrientationPortrait:
      return AVCaptureVideoOrientationPortrait;
    default:
      return AVCaptureVideoOrientationPortraitUpsideDown;
  }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
    self.cameraView                                       = [[QRCodeReaderView alloc] init];
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _cameraView.clipsToBounds                             = YES;
    _cameraView.delegate                                  = self;
    [self.view addSubview:_cameraView];

    if (_frontDevice) {
        _switchCameraButton = [[QRCameraSwitchButton alloc] init];
        [_switchCameraButton setHidden:YES];
        [_switchCameraButton setTranslatesAutoresizingMaskIntoConstraints:false];
        [_switchCameraButton addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchCameraButton];
    }

    self.cancelButton                                       = [[UIButton alloc] init];
    self.cancelButton.hidden                                = YES;
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    
    
    CGFloat c_width = mainWidth - 100;
    CGFloat s_height = mainHeight - 40 - NavBarHeight;
    CGFloat y = (s_height - c_width) / 2 - s_height / 6;
    
    _lblTip = [[UILabel alloc] initWithFrame:CGRectMake(0,y + 90 + c_width, mainWidth, 40)];
    _lblTip.numberOfLines = 2;
    _lblTip.text = kString(@"将二维码放入框内,即可自动扫描");
    _lblTip.textColor = [UIColor whiteColor];
    _lblTip.font = [UIFont systemFontOfSize:13];
    _lblTip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_lblTip];
    
    CGFloat corWidth = 16;
    
    UIImageView* img1 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + 76, corWidth, corWidth)];
    img1.image = [UIImage imageNamed:@"cor1"];
    [self.view addSubview:img1];
    
    UIImageView* img2 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + 76, corWidth, corWidth)];
    img2.image = [UIImage imageNamed:@"cor2"];
    [self.view addSubview:img2];
    
    UIImageView* img3 = [[UIImageView alloc] initWithFrame:CGRectMake(49, y + c_width + 64, corWidth, corWidth)];
    img3.image = [UIImage imageNamed:@"cor3"];
    [self.view addSubview:img3];
    
    UIImageView* img4 = [[UIImageView alloc] initWithFrame:CGRectMake(35 + c_width, y + c_width + 64, corWidth, corWidth)];
    img4.image = [UIImage imageNamed:@"cor4"];
    [self.view addSubview:img4];
    
    
    _imgLine = [[UIImageView alloc] init];
    _imgLine.image = [UIImage imageNamed:@"QRCodeScanLine"];
    [self.view addSubview:_imgLine];
}

- (void)setupAutoLayoutConstraints
{
  NSDictionary *views = NSDictionaryOfVariableBindings(_cameraView, _cancelButton);
  
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView][_cancelButton(0)]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:
   [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelButton]-|" options:0 metrics:nil views:views]];
  
  if (_switchCameraButton) {
    NSDictionary *switchViews = NSDictionaryOfVariableBindings(_switchCameraButton);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_switchCameraButton(50)]" options:0 metrics:nil views:switchViews]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_switchCameraButton(70)]|" options:0 metrics:nil views:switchViews]];
  }
}

- (void)setupAVComponents
{
  self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  if (_defaultDevice) {
    self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
    self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
    self.session            = [[AVCaptureSession alloc] init];
    self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
      if (device.position == AVCaptureDevicePositionFront) {
        self.frontDevice = device;
      }
    }
    
    if (_frontDevice) {
      self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontDevice error:nil];
    }
  }
}

- (void)configureDefaultComponents
{
  [_session addOutput:_metadataOutput];
  
  if (_defaultDeviceInput) {
    [_session addInput:_defaultDeviceInput];
  }
  
  [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
  if ([[_metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
    [_metadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
  }
  [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [_previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
  
  if ([_previewLayer.connection isVideoOrientationSupported]) {
    
      _previewLayer.connection.videoOrientation = [[self class] videoOrientationFromInterfaceOrientation:self.interfaceOrientation];
    
  }
}

- (void)switchDeviceInput
{
  if (_frontDeviceInput) {
    [_session beginConfiguration];
    
    AVCaptureDeviceInput *currentInput = [_session.inputs firstObject];
    [_session removeInput:currentInput];
    
    AVCaptureDeviceInput *newDeviceInput = (currentInput.device.position == AVCaptureDevicePositionFront) ? _defaultDeviceInput : _frontDeviceInput;
    [_session addInput:newDeviceInput];
    
    [_session commitConfiguration];
  }
}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
  [self stopScanning];
  
  if (_completionBlock) {
    _completionBlock(nil);
  }
  
  if (_delegate && [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
    [_delegate readerDidCancel:self];
  }
}

- (void)switchCameraAction:(UIButton *)button
{
  [self switchDeviceInput];
}

#pragma mark - Controlling Reader

- (void)startScanning;
{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
    
    if(_timerScan)
    {
        [_timerScan invalidate];
        _timerScan = nil;
    }
    
    _timerScan = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scanAnimate) userInfo:nil repeats:YES];
}

- (void)stopScanning;
{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    if(_timerScan)
    {
        [_timerScan invalidate];
        _timerScan = nil;
    }
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [current.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];

            [self stopScanning];
            if (_completionBlock) {
                [_beepPlayer play];
                _completionBlock(scannedResult);
            }

            if (_delegate && [_delegate respondsToSelector:@selector(reader:didScanResult:)]) {
                [_delegate reader:self didScanResult:scannedResult];
            }

            break;
        }
    }
}

#pragma mark - Checking the Metadata Items Types

+ (BOOL)isAvailable
{
  @autoreleasepool {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!captureDevice) {
      return NO;
    }
    
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!deviceInput || error) {
      return NO;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    if (![output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
      return NO;
    }
    
    return YES;
  }
}

#pragma mark - Checking RightBarButtonItem
-(void)clickRightBarButton
{
//    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = NO;
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self.navigationController presentViewController:picker animated:YES completion:nil];
    
//    ZBarReaderController *reader = [ZBarReaderController new];
//    reader.allowsEditing = YES;
//    reader.readerDelegate = self;
//    reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentViewController:reader animated:YES completion:^{}];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{}];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self dismissViewControllerAnimated:YES completion:^{
        [self getURLWithImage:image];
    }
     ];
//    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
//    if ([info count]>2) {
//        int quality = 0;
//        ZBarSymbol *bestResult = nil;
//        for(ZBarSymbol *sym in results) {
//            int q = sym.quality;
//            if(quality < q) {
//                quality = q;
//                bestResult = sym;
//            }
//        }
//        [self performSelector: @selector(presentResult:) withObject: bestResult afterDelay: .001];
//    }else {
//        ZBarSymbol *symbol = nil;
//        for(symbol in results)
//            break;
//        [self performSelector: @selector(presentResult:) withObject: symbol afterDelay: .001];
//    }
//    
////    [picker dismissModalViewControllerAnimated:YES];
//    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)getURLWithImage:(UIImage *)img{
    
    UIImage *loadImage= img;
    CGImageRef imageToDecode = loadImage.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (_completionBlock) {
        [_beepPlayer play];
        _completionBlock(result ? result.text : @"");
    }
}


//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
//{
//    NSLog(@"didFinishPickingImage");
//}
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    NSLog(@"imagePickerControllerDidCancel");
//}
//
//- (void) presentResult: (ZBarSymbol*)sym {
//    if (sym) {
//        NSString *tempStr = sym.data;
//        if ([sym.data canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
//            tempStr = [NSString stringWithCString:[tempStr cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
//        }
//        
//        
//        if (_completionBlock) {
//            [_beepPlayer play];
//            _completionBlock(tempStr);
//        }
//        
//    }
//}

//#pragma mark - UIImagePickerControllerDelegate
//- ( void )imagePickerController:( UIImagePickerController *)picker didFinishPickingMediaWithInfo:( NSDictionary *)info
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    if (!image){
//        image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    }
//    
//        NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]
//                                                   options:@{CIDetectorImageOrientation:[NSNumber numberWithInt:1]}];
////    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
//    if (features.count >=1) {
//        CIQRCodeFeature *feature = [features objectAtIndex:0];
//        NSString *scannedResult = feature.messageString;
//        if (_completionBlock) {
//            [_beepPlayer play];
//            _completionBlock(scannedResult);
//        }
//        
//        if (_delegate && [_delegate respondsToSelector:@selector(reader:didScanResult:)]) {
//            [_delegate reader:self didScanResult:scannedResult];
//        }
//    }
//}
@end
