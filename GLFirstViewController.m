//
//  GLFirstViewController.m
//  glamourAR
//
//  Created by Mahmood1 on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLFirstViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorSpaceUtilities.h"
#import "AppColors.h"
#import "GLAppDelegate.h"
#import "ScreenCapture.h"
#import <ImageIO/ImageIO.h>
#import "Appirater.h"
#import "ASJOverflowMenu.h"
#import "ASJOverflowButton.h"

BOOL isPad() {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

@interface GLFirstViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) ASJOverflowButton *overflowButton;
@property (copy, nonatomic) NSArray *overflowItems;

@property (nonatomic) CGPoint originalContentOffset;

- (void)setup;
- (void)setupDefaults;
- (void)setupOverflowItems;
- (void)setupOverflowButton;
- (void)handleOverflowBlocks;

@end


@implementation GLFirstViewController
@synthesize buttonLabels;
@synthesize modeButton2;
@synthesize cameraModeButton2;
@synthesize startStopButton2;
@synthesize screenshotButton2;
@synthesize arScreenshotButton2;
@synthesize facebookButton;
@synthesize helpButton;
@synthesize preferencesButton;
@synthesize transparencyLabel;
@synthesize hueLabel;
@synthesize activityIndicator;
@synthesize rotationRecognizer;
@synthesize startStopButton;
@synthesize timerArrow;
@synthesize saveCompositeButton;
@synthesize toolPanel;
@synthesize modeButton;
@synthesize screenshotButton;
@synthesize cameraModeButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize containerView;
@synthesize hueSlider;
@synthesize scrollView;
@synthesize pinchGestureRecognizer;
@synthesize arOverlayView;
@synthesize webView;
@synthesize transparencySlider;

@synthesize stillImage;
@synthesize stillImageOutput;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) loadDefaultContent
{
//    https://www.pexels.com/photo/adult-beautiful-beauty-blue-eyes-356225/
    
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"home" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
    
    
//    https://static.pexels.com/photos/37533/studio-portrait-woman-face-37533.jpeg
//     [self.webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.christopherteh.com/blog/wp-content/uploads/2016/02/Fotolia_84395549_Subscription_Monthly_M-900x600.jpg"]]];
    
//    [webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:searchEnginePref]]]
    
    //    [webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:searchEnginePref]]];
    
    //  [webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.christopherteh.com/blog/wp-content/uploads/2016/02/Fotolia_84395549_Subscription_Monthly_M-900x600.jpg"]]];
    //    [webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://static.pexels.com/photos/355164/pexels-photo-355164.jpeg"]]];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSURL* url =  [NSURL URLWithString:@"http://www.youtube.com/watch?v=U7dOBeyr5bk"];
    
    [self setup];
    
    [self copyCameraPage];
    
    self.tapToStopGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(buttonAction:)];
    self.tapToStopGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer: self.tapToStopGesture];
    

    self.tapToTakePhotoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(saveComposite:)];
    self.tapToTakePhotoGesture.numberOfTapsRequired = 1;
    self.tapToTakePhotoGesture.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer: self.tapToTakePhotoGesture];
    

    
    useFrontCamera = YES;
    
    for (UIView* v in self.controls) {
        [self styleView:v];
    }
    
    self.transparencyContainer.layer.borderWidth = 1;
    self.transparencyContainer.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.33].CGColor;
    self.transparencyContainer.layer.masksToBounds = YES;
    self.transparencyContainer.layer.cornerRadius = 4;
    self.transparencyContainer.backgroundColor = UIColor.clearColor;
    
    
    [self.transparencyContainer sendSubviewToBack:self.backgroundView];
    
//    self.scrollView.contentSize = CGSizeMake( arOverlayView.frame.size.width*3, arOverlayView.frame.size.height*3);
    self.scrollView.contentSize = CGSizeMake( 4096,4096);
    
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 0.25;
    
    self.scrollView.contentOffset = arOverlayView.frame.origin;
    self.originalContentOffset = arOverlayView.frame.origin;
    NSString* searchEnginePref = nil;
    searchEnginePref = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchEngine"];
    
    if(searchEnginePref ==nil ||searchEnginePref.length ==0){
        
        searchEnginePref = (!isPad())?@"http://images.google.com/search?tbm=isch&q=Beautiful+people":@"https://www.bing.com";
        [[NSUserDefaults standardUserDefaults] setValue:searchEnginePref forKey:@"searchEngine"];
        
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"saveToCamera"];
         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendEmail"];
    }
    
    [self loadDefaultContent];
    
     [arOverlayView setTransform:CGAffineTransformScale([arOverlayView transform], (CGFloat)0.667, (CGFloat)0.667)];
    
    alphaView = containerView;
    alphaView.alpha = transparencySlider.value;
     
    [self.view addGestureRecognizer:rotationRecognizer];
    
    //init labels
    transparencyLabel.text = [NSString stringWithFormat:@"%.2f",transparencySlider.value];
     hueLabel.text = [NSString stringWithFormat:@"%.2f",hueSlider.value];
//    [webView loadHTMLString:@"http://www.google.com" baseURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=U7dOBeyr5bk"]];
    

//    [self scanForCameraDevices];

    
    currentViewSource = VIEWSOURCE_UIIMAGEVIEW ;
    
    UIPanGestureRecognizer *panRecognizer;
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(wasDragged:)];
    // cancel touches so that touchUpInside touches are ignored
    panRecognizer.cancelsTouchesInView = YES;
    [self.dragButton addGestureRecognizer:panRecognizer];

    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.scrollView.zoomScale = 1;
     self.scrollView.contentOffset = arOverlayView.frame.origin;
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if(interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
//           for(CALayer* layer in  arOverlayView.layer.sublayers) 
//           {
//               layer.transform = CATransform3DMakeRotation(90, 1,0, 0);
//           }
        }else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
//            for(CALayer* layer in  arOverlayView.layer.sublayers) 
//            {
//                layer.transform = CATransform3DMakeRotation(-90, 1,0, 0);
//            }
        }else{
//            for(CALayer* layer in  arOverlayView.layer.sublayers) 
//            {
//                layer.transform = CATransform3DIdentity;
//            } 
        } 
        
        
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)transparencyChanged:(id)sender {
    alphaView.alpha = transparencySlider.value;
     transparencyLabel.text = [NSString stringWithFormat:@"%.2f",transparencySlider.value];
}


- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [captureSession addOutput:[self stillImageOutput]];
}


- (IBAction)buttonAction:(id)sender {
    
    UIButton* button = nil;
    if([sender isKindOfClass:[UIButton class]])
    {
        button = sender;
    }
    
    if(running)
    {
        running = NO;
        [captureSession stopRunning];
        [animationTimer invalidate];
        
      
        [startStopButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
         [startStopButton2 setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
        self.playPauseLabel.text = @"Resume";
        [self.tabBarController.tabBar setHidden:NO];
        //clear sublayers
        
//        for (CALayer* layer in arOverlayView.layer.sublayers)
//        {
//            [layer removeFromSuperlayer];
//        }
        
    }else{
        running = YES;

        [self.tabBarController.tabBar setHidden:YES]; 
        
        
        [startStopButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
         [startStopButton2 setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        
        self.playPauseLabel.text = @"Freeze";
        [self activateCameraFeed];
        
    }
}


//- (IBAction)buttonAction:(id)sender {
//    
//    UIButton* button = nil;
//    if([sender isKindOfClass:[UIButton class]])
//    {
//        button = sender;
//    }
//    
//    if(running)
//    {
//        running = NO;
//        [captureSession stopRunning];
//        [animationTimer invalidate];
//        
//        if(button)
//        {
//            [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
//        }
//        
//        
//        //        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//        [self.tabBarController.tabBar setHidden:NO];
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        //clear sublayers
//        
//        for (CALayer* layer in arOverlayView.layer.sublayers)
//        {
//            [layer removeFromSuperlayer];
//        }
//        
//    }else{
//        running = YES;
//        //        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        [self.tabBarController.tabBar setHidden:YES]; 
//        
//        if(button)
//        {
//            [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//        }
//        captureSession = [[AVCaptureSession alloc] init];
//        AVCaptureDevice *audioCaptureDevice = nil;
//        
//        //           AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        
//        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//        
//        for (AVCaptureDevice *device in videoDevices) {
//            
//            if(useFrontCamera){
//                if (device.position == AVCaptureDevicePositionFront) {
//                    //FRONT-FACING CAMERA EXISTS
//                    audioCaptureDevice = device;
//                    break;
//                }
//            }else{
//                if (device.position == AVCaptureDevicePositionBack) {
//                    //Rear-FACING CAMERA EXISTS
//                    audioCaptureDevice = device;
//                    break;
//                }
//            }
//            
//        }
//        
//        //           AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        
//        NSError *error = nil;
//        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
//        
//        
//        
//        if (audioInput) {
//            [captureSession addInput:audioInput];
//        }
//        else {
//            // Handle the failure.
//        }
//        
//        [self addStillImageOutput];
//        
//        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
//        
//        
//        
//        UIView *aView = arOverlayView;
//        previewLayer.frame =CGRectMake(0,0, arOverlayView.frame.size.width,arOverlayView.frame.size.height); // Assume you want the preview layer to fill the view.
//        
//        [aView.layer addSublayer:previewLayer];
//        [captureSession startRunning];
//        
//    }
//}

- (IBAction)handlePinch:(id)sender {
//    NSLog(@"Handle Pinch");
}


-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
   
//    if(scrollView.zoomScale<1.0)
//    {
//        CGRect f = self.tableView.frame;
//        
//        self.tableView.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, 700);
//    }else{
//        CGRect f = self.tableView.frame;
//        
//        self.tableView.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, 350);
//    }
//    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"Offset: %.0f %.0f",scrollView.contentOffset.x, scrollView.contentOffset.y);
}



#pragma mark - BUTTONS


- (IBAction)switchCameraMode:(id)sender {
    

    
    useFrontCamera = !useFrontCamera;
    
    {
        
        [self swapCameras];
        
    }
    
    
}

- (IBAction)enableDisableOverlayInteraction:(id)sender {
    

    UIView* temp = nil;
    CGRect overlayFrame = self.scrollView.frame;
    CGRect webviewFrame = self.webView.frame;
    
    scrollView.userInteractionEnabled = !scrollView.userInteractionEnabled;
    
    //scroll view is on top
    if(scrollView.userInteractionEnabled)
    {
        [self showCamera];
        

        

        
    }else{
        [self showWeb];
        
    }
    
}

-(void)showCamera
{
    
    UIView* temp = nil;
    CGRect overlayFrame = self.scrollView.frame;
    CGRect webviewFrame = self.webView.frame;
    
    temp = scrollView;
    [scrollView removeFromSuperview];
    [self.view insertSubview:temp aboveSubview:self.webView];
    temp.frame = overlayFrame;
    alphaView = containerView;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.webControls.alpha = 0;
        self.cameraControls.alpha = 1;
        
    }];
    
}

-(void)showWeb
{
    
    UIView* temp = nil;
    CGRect overlayFrame = self.scrollView.frame;
    CGRect webviewFrame = self.webView.frame;
    
    //scroll view is below
    temp = webView;
    [webView removeFromSuperview];
    [self.view insertSubview:temp aboveSubview:self.scrollView];
    temp.frame = webviewFrame;
    alphaView = temp;

    [UIView animateWithDuration:0.3 animations:^{
        self.webControls.alpha = 1;
        self.cameraControls.alpha = 0;
        
    }];
    
}

- (IBAction)hueChanged:(id)sender {
    

    arOverlayView.backgroundColor = [UIColor colorWithHue:hueSlider.value saturation:1 brightness:1 alpha:1];
    if(hueSlider.value ==0)
    {
        arOverlayView.backgroundColor = [AppColors transparentColor];
    }
    
     hueLabel.text = [NSString stringWithFormat:@"%.2f",hueSlider.value];
    
}

-(void)saveOverlayInBackground:(id)sender
{
//    UIGraphicsBeginImageContext(arOverlayView.frame.size);
//    UIGraphicsBeginImageContext(scrollView.frame.size);
    UIGraphicsBeginImageContext(CGSizeMake(480, 640));
    [arOverlayView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    //    [appDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"saveToCamera"])
    {
        UIImageWriteToSavedPhotosAlbum(screenshot, self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"sendEmail"])
    {
        [self emailImage:screenshot];
    }
    [self hideButtons:NO];
    
}

- (IBAction)saveOverlay:(id)sender {
   
//    timerArrow.center = screenshotButton.center;
//    timerArrow.alpha = 1;
    
    [self hideButtons:YES];
    
    [self performSelectorInBackground:@selector(saveOverlayInBackground:) withObject:nil];
    
    
//    [ UIView animateWithDuration:2 delay:0 options:UIViewAnimationCurveLinear animations:^{
//        timerArrow.transform = CGAffineTransformMakeRotation(M_PI/2);
//    } completion:^(BOOL finished) {
//         timerArrow.alpha = 0; 
//        [self performSelectorInBackground:@selector(saveOverlayInBackground:) withObject:nil];
//       
//        timerArrow.transform = CGAffineTransformIdentity;
//    }];
//    
       
//    NSLog(@"saveOverlay");
//    GLAppDelegate* appDelegate =     [UIApplication sharedApplication].delegate;
 
  
    
//    AVCaptureConnection* connection = [imageOutput.connections objectAtIndex:0] ;
//    [  imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//    //        TestAudioFo
//       NSAssert(imageDataSampleBuffer !=nil,@"image data is nil!");
    //    
//        UIImage* overlay = [self imageFromSampleBuffer:imageDataSampleBuffer];
//        UIImage* screenshotComposite = [ScreenCapture UIViewToImage:alphaView withOverlayImage:overlay];
//    //    
//        UIImageWriteToSavedPhotosAlbum(overlay, self, 
//    //                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    } ];

    
}

- (IBAction)saveComposite:(id)sender {
//    NSLog(@"saveComposite");
//    [Appirater userDidSignificantEvent:YES];
    
//    timerArrow.center = saveCompositeButton.center;
//    timerArrow.alpha = 1;
   
    
//    [ UIView animateWithDuration:2 delay:0 options:UIViewAnimationCurveLinear animations:^{
//        timerArrow.transform = CGAffineTransformMakeRotation(M_PI/2);
//    } completion:^(BOOL finished) {
//         timerArrow.alpha = 0;
//         [self snapShot];       
//        timerArrow.transform = CGAffineTransformIdentity;
//
//    }];
    
    [self hideButtons:YES];
    
    [self snapShot];

//    
////    [self saveOverlay:nil];  
//    
////    [self    captureStillImage];
////     
//    GLAppDelegate* appDelegate =     [UIApplication sharedApplication].delegate;
//    
//    UIGraphicsBeginImageContext(appDelegate.window.bounds.size);
//    [appDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//    
////    UIImage *screenshot = [ScreenCapture UIViewToImage:self.view];
//     UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIImageWriteToSavedPhotosAlbum(screenshot, self, 
//                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
//
    
//    AVCaptureConnection* connection = [imageOutput.connections objectAtIndex:0] ;
//    
//    
//    UIImage* overlay = [ScreenCapture UIViewToImage:arOverlayView];
//    UIImage* screenshotComposite = [ScreenCapture UIViewToImage:alphaView withOverlayImage:overlay];
    
//    UIImageWriteToSavedPhotosAlbum(overlay, self, 
//                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);

    
//    
    
//[    imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
////        TestAudioFo
//    NSAssert(imageDataSampleBuffer !=nil,@"image data is nil!");
//    
//    UIImage* overlay = [self imageFromSampleBuffer:imageDataSampleBuffer];
//    UIImage* screenshotComposite = [ScreenCapture UIViewToImage:alphaView withOverlayImage:overlay];
//    
//    UIImageWriteToSavedPhotosAlbum(overlay, self, 
//                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
//} ];
    
}

- (IBAction)timerAction:(id)sender {
//    NSLog(@"timerAction");
}

- (IBAction)backArrowAction:(id)sender {
    
    [webView goBack];
}

- (IBAction)showImageSelector:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Select Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak GLFirstViewController* weakSelf = self;
    
    UIAlertAction* cameraRoll = [UIAlertAction actionWithTitle:@"From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakSelf;
        picker.allowsEditing = NO;
        picker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        
        [weakSelf presentViewController:picker animated:YES completion:NULL];
    }];
    
    UIAlertAction* takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = weakSelf;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [weakSelf presentViewController:picker animated:YES completion:NULL];
    }];
    
    UIAlertAction* web = [UIAlertAction actionWithTitle:@"From Web" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if(scrollView.userInteractionEnabled == YES)
        {
            [self enableDisableOverlayInteraction:nil];
            weakSelf.segmentedControl.selectedSegmentIndex = 1;
        }
    
        [weakSelf searchButton:nil];
        
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cameraRoll];
    [alert addAction:takePhoto];
    [alert addAction:web];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
}

-(NSString*) photoPath
{
    //obtaining saving path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* folderPath = [documentsDirectory stringByAppendingPathComponent:@"photos"];
    
    NSError* error = nil;
   BOOL success = [[NSFileManager defaultManager]createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error: &error];
    
    if(error != nil || success == NO)
    {
        //error creating folder
    }
    
    return folderPath;
}

-(void) copyCameraPage {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *filePath = [[self photoPath] stringByAppendingPathComponent:@"camera_content.html"];
    
    if ([fileManager fileExistsAtPath:filePath] == NO)
    {
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"camera_content" ofType:@"html"];
        [fileManager copyItemAtPath:resourcePath toPath:filePath error:&error];
        if (error) {
//            NSLog(@"Error on copying file: %@\nfrom path: %@\ntoPath: %@", error, resourcePath, filePath);
        }
    }
    
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    __weak GLFirstViewController* weakSelf = self;
    NSString *htmlFile = [[self photoPath] stringByAppendingPathComponent:@"camera_content.html"];
    NSURL* url = [NSURL URLWithString:htmlFile];
     [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    NSString *imagePath = [[self photoPath] stringByAppendingPathComponent:@"camera_image.jpg"];
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    
    NSData *webData = UIImageJPEGRepresentation( chosenImage,90);
    success = [webData writeToFile:imagePath atomically:YES];
    

    
    
   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:url]];
        [weakSelf.webView reload];
    });
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - SAVE IMAGE

//image saved callback
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
//         NSLog(@"save failed");
        
    }
    else  // No errors
    {
//         NSLog(@"save successful");
        // Show message image successfully saved
    }
}








// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (IBAction)modeChanged:(id)sender {
}

//// Delegate routine that is called when a sample buffer was written
//- (void)captureOutput:(AVCaptureOutput *)captureOutput 
//didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
//       fromConnection:(AVCaptureConnection *)connection
//{ 
//    // Create a UIImage from the sample buffer data
//    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//    
//    //    < Add your code here that uses the image >
//    
//}


- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
    
//	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
//                                                                 NSLog(@"attachements: %@", exifAttachments);
                                                             } else {
//                                                                 NSLog(@"no attachments");
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             [self setStillImage:image];
                                                             
                                                             
                                                             UIImage* overlay = image;
                                                             UIImage* screenshotComposite = [ScreenCapture UIViewToImage:alphaView withOverlayImage:overlay];
                                                             
                                                             UIImageWriteToSavedPhotosAlbum(screenshotComposite, self, 
                                                                                            @selector(image:didFinishSavingWithError:contextInfo:), nil);

                                                            
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                         }];
}


- (void) swapCameras
{
    [captureSession stopRunning];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(cameraSwapAnimation:finished:context:)];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.arOverlayView cache:YES];
    [UIView commitAnimations];
    
   
    [captureSession beginConfiguration];
    [captureSession removeInput:captureInput];
    
//    [captureSession removeOutput:stillImageOutput];
    
    if ( currentCameraDeviceIndex==frontCameraDeviceIndex )
    {
        currentCameraDeviceIndex = backCameraDeviceIndex;
        cameraImageOrientation = UIImageOrientationRight;
    }
    else
    {
        currentCameraDeviceIndex = frontCameraDeviceIndex;
        cameraImageOrientation = UIImageOrientationLeftMirrored;
    }
    
    //
    // Re-map the Open/GL to account for imageOrientation change
    //
//    [self mapGLViewForOrientation:UIInterfaceOrientationPortrait];
    
    // Start the Camera
    //
    AVCaptureDevice *selectedCamera = [[AVCaptureDevice devices] objectAtIndex:(NSUInteger)currentCameraDeviceIndex];
    
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:selectedCamera error:nil];
    
    if ( [selectedCamera lockForConfiguration:nil] )
    {
        if ( [selectedCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] )
        {
            [selectedCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if ( [selectedCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] )
        {
            [selectedCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        if ( [selectedCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] )
        {
            [selectedCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if ( [selectedCamera isTorchModeSupported:AVCaptureTorchModeAuto] )
        {
            [selectedCamera setTorchMode:AVCaptureTorchModeOff];    // AVCaptureTorchModeOn turns the "torch" light ON
        }
        
        if ( [selectedCamera isFlashModeSupported:AVCaptureFlashModeAuto] )
        {
            [selectedCamera setFlashMode:AVCaptureFlashModeAuto];   // AVCaptureFlashModeAuto
        }
        
        [selectedCamera unlockForConfiguration];
    }
    
    if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480])
    {
        cameraDeviceSetting = CameraDeviceSetting640x480;
        [captureSession setSessionPreset:AVCaptureSessionPreset640x480];    // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
    }
    else
        if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetHigh] )
        {
            cameraDeviceSetting = CameraDeviceSettingHigh;
            [captureSession setSessionPreset:AVCaptureSessionPresetHigh];   // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
        }
        else
            if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetMedium] )
            {
                cameraDeviceSetting = CameraDeviceSettingMedium;
                [captureSession setSessionPreset:AVCaptureSessionPresetMedium]; // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
            }
            else
                if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetLow] )
                {
                    cameraDeviceSetting = CameraDeviceSettingLow;
                    [captureSession setSessionPreset:AVCaptureSessionPresetLow];    // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
    
                
                }   
    
//    [self addStillImageOutput];
    
    [captureSession addInput:captureInput];
    [captureSession commitConfiguration];
    
    [captureSession startRunning];
}

#pragma mark - SCAN FOR CAMERAS
- (void) scanForCameraDevices
{
    cameraCount = 0;
    frontCameraDeviceIndex = -1;
    backCameraDeviceIndex = -1;
    
    AVCaptureDevice *backCameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray *deviceList = [AVCaptureDevice devices];
    NSRange cameraSearch;
    NSUInteger i;
    
    for ( i=0; i<[deviceList count]; i++ )
    {
        AVCaptureDevice *currentDevice = (AVCaptureDevice *)[deviceList objectAtIndex:i];
        
        //
        // This is the best info so skip string the string searches
        // that follow if we have a match on this
        //
        if ( currentDevice==backCameraDevice )
        {
            backCameraDeviceIndex = i;
            cameraCount++;
            continue;
        }
        
        cameraSearch = [[currentDevice description] rangeOfString:@"front camera" options:NSCaseInsensitiveSearch];
        if ( frontCameraDeviceIndex<0 && cameraSearch.location != NSNotFound )
        {
            frontCameraDeviceIndex = i;
            cameraCount++;
            continue;
        }
        
        cameraSearch = [[currentDevice description] rangeOfString:@"back camera" options:NSCaseInsensitiveSearch];
        if ( backCameraDevice<0 && cameraSearch.location != NSNotFound )
        {
            backCameraDeviceIndex = i;
            cameraCount++;
            continue;
        }
        
        cameraSearch = [[currentDevice description] rangeOfString:@"camera" options:NSCaseInsensitiveSearch];
        if ( backCameraDevice<0 && cameraSearch.location != NSNotFound )
        {
            backCameraDeviceIndex = i;
            cameraCount++;
            continue;
        }
    }
    
    
    [self buttonAction:self.startStopButton];
    [self showCamera];
//    [self enableDisableOverlayInteraction:self.modeButton];
    
    
}
- (void) activateCameraFeed
{
    videoSettings = nil;
    
    pixelFormatCode = [[NSNumber alloc] initWithUnsignedInt:(unsigned int)kCVPixelFormatType_32BGRA];
    pixelFormatKey = [[NSString alloc] initWithString:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    videoSettings = [[NSDictionary alloc] initWithObjectsAndKeys:pixelFormatCode, pixelFormatKey, nil]; 
    
    dispatch_queue_t queue = dispatch_queue_create("com.AugmentedRealityGlamour.ImageCaptureQueue", NULL);
    
    captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [captureOutput setAlwaysDiscardsLateVideoFrames:YES];
    [captureOutput setSampleBufferDelegate:self queue:queue];
    [captureOutput setVideoSettings:videoSettings];
    
//    dispatch_release(queue);
    
    AVCaptureDevice *selectedCamera;
    
      
    currentCameraDeviceIndex = -1;
    
    // default to front facing camera
    //
    if ( useFrontCamera )
    {
        currentCameraDeviceIndex = frontCameraDeviceIndex;
        cameraImageOrientation = UIImageOrientationLeftMirrored;
    }
    else
    {
        currentCameraDeviceIndex = backCameraDeviceIndex;
        cameraImageOrientation = UIImageOrientationRight;
    }
    
    if ( currentCameraDeviceIndex < 0 )
        selectedCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    else
        selectedCamera = [[AVCaptureDevice devices] objectAtIndex:(NSUInteger)currentCameraDeviceIndex];
    
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:selectedCamera error:nil];
    
    if ( [selectedCamera lockForConfiguration:nil] )
    {
        if ( [selectedCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] )
        {
            [selectedCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if ( [selectedCamera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance] )
        {
            [selectedCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        if ( [selectedCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] )
        {
            [selectedCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        
        if ( [selectedCamera isTorchModeSupported:AVCaptureTorchModeAuto] )
        {
            [selectedCamera setTorchMode:AVCaptureTorchModeOff];    // AVCaptureTorchModeOn turns the "torch" light ON
        }
        
        if ( [selectedCamera isFlashModeSupported:AVCaptureFlashModeAuto] )
        {
            [selectedCamera setFlashMode:AVCaptureFlashModeAuto];   // AVCaptureFlashModeAuto
        }
        
        [selectedCamera unlockForConfiguration];
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];
    
    if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPreset640x480])
    {
        cameraDeviceSetting = CameraDeviceSetting640x480;
        [captureSession setSessionPreset:AVCaptureSessionPreset640x480];    // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
    }
    else
        if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetHigh] )
        {
            cameraDeviceSetting = CameraDeviceSettingHigh;
            [captureSession setSessionPreset:AVCaptureSessionPresetHigh];   // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
        }
        else
            if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetMedium] )
            {
                cameraDeviceSetting = CameraDeviceSettingMedium;
                [captureSession setSessionPreset:AVCaptureSessionPresetMedium]; // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
            }
            else
                if ( [selectedCamera supportsAVCaptureSessionPreset:AVCaptureSessionPresetLow] )
                {
                    cameraDeviceSetting = CameraDeviceSettingLow;
                    [captureSession setSessionPreset:AVCaptureSessionPresetLow];    // AVCaptureSessionPresetHigh or AVCaptureSessionPreset640x480
                }   
    
    [captureSession addInput:captureInput];
    [captureSession addOutput:captureOutput];
//    [captureSession addOutput:stillImageOutput];
    
//    [self addStillImageOutput];

    [captureSession commitConfiguration];
    
   
    [captureSession startRunning];
}

- (void) saveGLView
{
   
}

-(void)saveInBackground:(id)sender
{
  
    
//    UIImageWriteToSavedPhotosAlbum(photo, self, @selector(savedSnapShot:didFinishSavingWithError:contextInfo:), nil);
    
    GLAppDelegate* appDelegate =     [UIApplication sharedApplication].delegate;
    
    UIGraphicsBeginImageContext(appDelegate.window.bounds.size);
    [appDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    ////    UIImage *screenshot = [ScreenCapture UIViewToImage:self.view];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"saveToCamera"])
    {
        UIImageWriteToSavedPhotosAlbum(screenshot, self, 
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"sendEmail"])
    {
        [self emailImage:screenshot];
    }
    [self hideButtons:NO];
 
}

- (void) saveDisplayView
{
    
       

    
    
    
    [self performSelectorInBackground:@selector(saveInBackground:) withObject:nil];
    
    //    UIImage *photo = [ScreenCapture UIViewToImage:displayView];   
//    UIImage *photo = [ScreenCapture UIViewToImage:self.view];
//    // returns an autoreleased image
//    
//    if ( photo == nil )
//        return;
//    
//    UIImageWriteToSavedPhotosAlbum(photo, self,                                                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
//
   
}


- (void) snapShot
{
    if ( ignoreImageStream )
        return;
    
    ignoreImageStream = YES;
    
    if ( currentViewSource==VIEWSOURCE_OPENGLVIEW )
        [self saveGLView];
    else
        if ( currentViewSource==VIEWSOURCE_UIIMAGEVIEW )
            [self saveDisplayView];
    
    ignoreImageStream = NO;
}

//
// This method releases the 'newimage' because it may change it
// so the references passed can no longer be released by the
// caller of this method
//
- (void) newCameraImageNotification:(UIImage*)newImage
{
    if ( newImage == nil )
        return;
    
    if ( currentViewSource == VIEWSOURCE_UIIMAGEVIEW )
    {
        
        [arOverlayView setImage:newImage];

    }
    else
        if ( currentViewSource == VIEWSOURCE_OPENGLVIEW )
        {}
//        {
//            size_t textureBufferWidth = (size_t)rintf( cameraTextureRect.size.width );
//            size_t textureBufferHeight = (size_t)rintf( cameraTextureRect.size.height );
//            
//            //      memset( cameraTextureImageBuffer, (unsigned char)0, textureBufferWidth * textureBufferHeight * 4 ); // needs to be done to avoid shadowing under transparency
//            
//            // Draw the full image into our cameraTextureImageBuffer (which is sized to account for this) even though
//            // for texture mapping to work, we will only bind to a 512x512 section of the image
//            //
//            CGRect extractRect = CGRectMake((CGFloat)0.0, (CGFloat)0.0, (CGFloat)CGImageGetWidth(newImage), (CGFloat)CGImageGetHeight(newImage));
//            CGContextDrawImage(cameraTextureContext, extractRect, newImage);
//            glBindTexture(GL_TEXTURE_2D, cameraTextureTag);
//            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureBufferWidth, textureBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, cameraTextureImageBuffer);
//            
//            [self refreshVBObjects];
//        }
    
//    CGImageRelease(newImage);
}



- (void) performImageCaptureFrom:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer;
    
    if ( CMSampleBufferGetNumSamples(sampleBuffer) != 1 )
        return;
    if ( !CMSampleBufferIsValid(sampleBuffer) )
        return;
    if ( !CMSampleBufferDataIsReady(sampleBuffer) )
        return;
    
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    
    if ( CVPixelBufferGetPixelFormatType(imageBuffer) != kCVPixelFormatType_32BGRA )
        return;
    
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
    
    CGImageRef newImage = nil;
    
    if ( cameraDeviceSetting == CameraDeviceSetting640x480 )
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        newImage = CGBitmapContextCreateImage(newContext);
        CGColorSpaceRelease( colorSpace );
        CGContextRelease(newContext);
    }
    else
    {
        uint8_t *tempAddress = malloc( 640 * 4 * 480 );
        memcpy( tempAddress, baseAddress, bytesPerRow * height );
        baseAddress = tempAddress;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,  kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
        newImage = CGBitmapContextCreateImage(newContext);
        CGContextRelease(newContext);
        newContext = CGBitmapContextCreate(baseAddress, 640, 480, 8, 640*4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGContextScaleCTM( newContext, (CGFloat)640/(CGFloat)width, (CGFloat)480/(CGFloat)height );
        CGContextDrawImage(newContext, CGRectMake(0,0,640,480), newImage);
        CGImageRelease(newImage);
        newImage = CGBitmapContextCreateImage(newContext);
        CGColorSpaceRelease( colorSpace );
        CGContextRelease(newContext);
        free( tempAddress );
    }
    
    if ( newImage != nil )
    {
        
    tempImage =  [[UIImage alloc] initWithCGImage:newImage scale:(CGFloat)1.0 orientation:cameraImageOrientation];
    CGImageRelease(newImage);
        
        [self performSelectorOnMainThread:@selector(newCameraImageNotification:) withObject:tempImage waitUntilDone:YES];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ( ignoreImageStream )
        return;
       [self performImageCaptureFrom:sampleBuffer];
    
} 


- (IBAction)searchButton:(id)sender {
    [webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"searchEngine"]]]];
}

- (IBAction)helpButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://luciddreamingapp.com/augmented-reality/augmented-reality-controls/"]];
}

- (IBAction)facebookButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Augmented-Reality-Glamour/160885867357601"]];
}

- (IBAction)preferencesButtonAction:(id)sender {
//    NSLog(@"preferences");
    //does a segue to preferences
}



- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self.tabBarController.tabBar setHidden:NO]; 
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            //            NSLog(@"Result: saved");
        { 
//            [dataManager cleanupCSVFiles];
            break;
        }
        case MFMailComposeResultSent:
            //            NSLog(@"Result: sent");
        {
//            [dataManager cleanupCSVFiles];
            break;
        }
        case MFMailComposeResultFailed:
            //            NSLog(@"Result: failed");
            break;
        default:
            //            NSLog(@"Result: not sent");
            break;
    }
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)displayComposerSheetWithFile:(id)image_
{
    MFMailComposeViewController *picker = [MFMailComposeViewController alloc];
    picker = [picker init];
    
    
    picker.mailComposeDelegate = self;
    
    NSLog(@"DEVICE MODEL: %@",[[UIDevice currentDevice] model]);
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    
    
    // MAKING A SCREENSHOT
    //    Lucid_Dreaming_AppAppDelegate* appDelegate = ((Lucid_Dreaming_AppAppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    UIImage* image = image_;
      // ATTACHING A SCREENSHOT
    NSData *myData = UIImagePNGRepresentation(image);
    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"AugmentedRealityScreenshot.png"];     
    
    NSString* filename = [NSString stringWithFormat:@"Augmented Reality Screenshot (%@) %@",[[UIDevice currentDevice] model], [dateFormatter stringFromDate:[NSDate date]] ];
    [picker setSubject:filename];
    NSArray *toRecipients = nil;
    // Set up recipients
    NSString* email= [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    if(email!=nil){
       toRecipients = [NSArray arrayWithObject:email]; 
    }else{
         toRecipients = [NSArray arrayWithObject:@""];
    }
    //     NSArray *ccRecipients = [NSArray arrayWithObjects:@"science@luciddreamingapp.com",nil]; 
    // NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
    
    [picker setToRecipients:toRecipients];
    // [picker setCcRecipients:ccRecipients];   
    // [picker setBccRecipients:bccRecipients];

    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:@"Augmented Reality Screenshot:\n transparency: %.2f hue: %.2f",                          
                           transparencySlider.value,
                           hueSlider.value                           
                           ];
    [picker setMessageBody:emailBody isHTML:NO];
    [self.navigationController presentModalViewController:picker animated:YES];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    
}
-(void)emailImage:(UIImage*)image
{ 
//    [self.tabBarController.tabBar setHidden:YES]; 
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelectorOnMainThread:@selector(displayComposerSheetWithFile:) withObject:image waitUntilDone: NO]   ;
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
      [activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
     [activityIndicator stopAnimating];
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if([gestureRecognizer isEqual:rotationRecognizer])
    {
        savedRotation=   [[NSUserDefaults standardUserDefaults] floatForKey:@"outerDialRotation"];;
    }
    return YES;
    
}

- (IBAction)rotateView:(id)sender {
    
    if([sender isKindOfClass:[UIRotationGestureRecognizer class]])
    {
        UIRotationGestureRecognizer* recognizer = sender;
    
        float recognizerRotation = [recognizer rotation];

        float rotation = (savedRotation+recognizerRotation);
        
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
        
        
        //causes major spinning of the view
        //        backgroundReminderView.transform = CGAffineTransformRotate(backgroundReminderView.transform, [recognizer rotation]);
        
        //         rotation = atan2(backgroundReminderView.transform.b, backgroundReminderView.transform.a);
        
        arOverlayView.transform = transform;
        rotation = atan2(arOverlayView.transform.b, arOverlayView.transform.a);
        
        rotation = rotation<0?(2*M_PI)-fabs(rotation):rotation;
        
        [[NSUserDefaults standardUserDefaults] setFloat: rotation forKey:@"outerDialRotation"];
        
        
    }
    
}


-(void)hideButtons:(BOOL) hide{
    self.transparencyContainer.alpha = (hide)?0:1;    
    
}

-(void)styleView:(UIView*)view
{
    view.layer.borderWidth = 2;
//    view.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.66].CGColor;
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    view.layer.masksToBounds = YES;
//    view.layer.cornerRadius = view.bounds.size.width/2.0;
    view.layer.cornerRadius = 11;
//    view.backgroundColor = UIColor.clearColor;
}

-(BOOL)isRunning{
    return running;
}

#pragma mark - OVERFLOW BUTTON

- (void)setup
{

    [self setupOverflowItems];
    [self setupOverflowButton];
    [self handleOverflowBlocks];
}


- (void)setupOverflowItems
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    
    
    ASJOverflowItem *item = [ASJOverflowItem itemWithName:@"Instructions"
                                                    image:nil
                                          backgroundColor:nil];
    [temp addObject:item];
    
   item = [ASJOverflowItem itemWithName:@"Web Help"
                                                    image:[UIImage imageNamed:@"help"]
                                          backgroundColor:nil];
    [temp addObject:item];
    
    
    
    item = [ASJOverflowItem itemWithName:@"Drag to position"
                                                    image:[UIImage imageNamed:@"1105-finger-drag-toolbar"]
                                          backgroundColor:nil];
    [temp addObject:item];
    
    
    
    
    item = [ASJOverflowItem itemWithName:@"Pinch to zoom"
                                   image:[UIImage imageNamed:@"1109-pinch-toolbar"]
                         backgroundColor:nil];
    [temp addObject:item];
    
    
    item = [ASJOverflowItem itemWithName:@"Rotate camera"
                                   image:[UIImage imageNamed:@"1110-rotate-toolbar"]
                         backgroundColor:nil];
    [temp addObject:item];
    
    
    item = [ASJOverflowItem itemWithName:@"1 Finger Freeze"
                                                    image:[UIImage imageNamed:@"1102-one-finger-tap-toolbar"]
                                          backgroundColor:nil];
    [temp addObject:item];
    
    item = [ASJOverflowItem itemWithName:@"2 Finger Save"
                                   image:[UIImage imageNamed:@"1103-two-finger-tap-toolbar"]
                         backgroundColor:nil];
    [temp addObject:item];
    
    item = [ASJOverflowItem itemWithName:@"Flick to locate"
                                   image:[UIImage imageNamed:@"1111-flick-left-toolbar"]
                         backgroundColor:nil];
    
    item = [ASJOverflowItem itemWithName:@"Drag Free Transform"
                                   image:[UIImage imageNamed:@"1107-vertical-swipe-toolbar"]
                         backgroundColor:nil];
    [temp addObject:item];


    
    _overflowItems = [NSArray arrayWithArray:temp];
}

- (void)setupOverflowButton
{
    UIImage *image = [UIImage imageNamed:@"1102-one-finger-tap-toolbar"];
    
    _overflowButton = [[ASJOverflowButton alloc] initWithImage:image items:_overflowItems];
    _overflowButton.dimsBackground = YES;
    _overflowButton.hidesSeparator = NO;
    _overflowButton.hidesShadow = NO;
    _overflowButton.dimmingLevel = 0.3f;
    _overflowButton.menuItemHeight = 50.0f;
    _overflowButton.widthMultiplier = 0.5f;
    _overflowButton.itemTextColor = [UIColor blackColor];
    _overflowButton.menuBackgroundColor = [UIColor whiteColor];
    _overflowButton.itemHighlightedColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    _overflowButton.menuMargins = MenuMarginsMake(7.0f, 7.0f, 7.0f);
    _overflowButton.separatorInsets = SeparatorInsetsMake(10.0f, 5.0f);
    _overflowButton.menuAnimationType = MenuAnimationTypeZoomIn;
    _overflowButton.itemFont = [UIFont fontWithName:@"Verdana" size:13.0f];
    
    self.navigationItem.rightBarButtonItem = _overflowButton;
}

- (void)handleOverflowBlocks
{
    __weak typeof(self) weakSelf = self;
    [_overflowButton setItemTapBlock:^(ASJOverflowItem *item, NSInteger idx)
     {
         
         NSString* title = @"";
         NSString* message = @"";
         
         
         switch (idx) {
                 
             case 0:
                //show help
             {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if(weakSelf.isRunning)
                         {
                             [weakSelf buttonAction:nil];
                         }
                         
                         weakSelf.transparencySlider.value = 1.0;
                         [weakSelf transparencyChanged:weakSelf.transparencySlider];
                         
                         UIImage* instructions = [UIImage imageNamed:@"augmented-reality-help"];
                         [weakSelf.arOverlayView setImage:instructions];
                     });
                    return;
                 
                 return;
                 break;
                 
             }
             case 1:
             {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf helpButtonAction:nil];
                     
                 });
                 return;
                 
                 return;
                 
             }
                 
                 
             case 2:
                 title = @"Position Image";
                 message = @"While in camera mode - drag camera feed around to position it and alight with web image";
                 break;
             case 3:
                 title = @"Resize Image";
                 message = @"Resize camera or web content with two finger pinch gesture";
                 break;
             case 4:
                 title = @"Rotate Image";
                 message = @"Adjust image rotation with two finger clockwise movement";
                 break;
                 
             case 5:
                 title = @"Freeze camera";
                 message = @"Tap screen with one finger to freeze camera";
                 break;
                 
             case 6:
                 title = @"Take photo";
                 message = @"Tap screen with two fingers to save photo to camera roll";
                 break;
                 
             case 7:
                 title = @"Free transform";
                 message = @"Start dragging from free transform button to change camera proportions or reflect it horizontally";
                 break;

                 
             default:
                 break;
         }
         
         
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
             
         }];
         [alert addAction:cancel];
         
         [weakSelf presentViewController:alert animated:YES completion:^{
             
         }];
         
     }];
    
    [_overflowButton setHideMenuBlock:^{
        NSLog(@"hidden");
    }];

}

- (IBAction)draggedOut:(id)sender {
    
}

- (IBAction)restoreTransform:(id)sender {
    self.arOverlayView.transform = CGAffineTransformIdentity;
}

- (void)wasDragged:(UIPanGestureRecognizer *)recognizer {
    UIButton *button = (UIButton *)recognizer.view;
    CGPoint translation = [recognizer translationInView:button];
    
//    button.center = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
//    [recognizer setTranslation:CGPointZero inView:button];
//   self.arOverlayView.transform = CGAffineTransformScale(self.arOverlayView.transform, 1.0 + (translation.x / button.bounds.size.width),
//                           1.0 + (translation.y / button.bounds.size.height));
//    self.arOverlayView.layer.anchorPoint = CGPointMake(0, 0);
    
    self.arOverlayView.transform = CGAffineTransformMakeScale(1.0 + (translation.x / button.bounds.size.width),
                                                              1.0 + (translation.y / button.bounds.size.height));
//    NSLog(@"Translation: %.0f %.0f",translation.x, translation.y);
}

- (IBAction)buttonWasTapped:(id)sender {
    NSLog(@"%s - button tapped",__FUNCTION__);
}



@end
