//
//  SettingsViewController.m
//  CHIJabberClient
//
//  Created by CHI Developer on 7/8/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsView.h"
#import "KeychainManager.h"
#import "AppDelegate.h"
#import "JabberManager.h"
#import "XMPPvCardTemp.h"
#import "CHIAlertView.h"
#import "UIColor+JabberCHIColors.h"
#import "CHIActionSheetView.h"


@interface SettingsViewController()
<
SettingsViewDelegate,
UIAlertViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CHIAlertDelegate,
CHIActionSheetDelegate
>


@property (nonatomic, strong) SettingsView *mainView;
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;


@end



@implementation SettingsViewController


- (instancetype) init
{
    self = [super init];
    if (self)
    {
        if (!self.user)
        {
            [self getUserProfile];
        }
    }
    
    return self;
}


- (void) loadView
{
    self.view = self.mainView;
    
    self.mainView.delegate = self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //    self.view.backgroundColor = [UIColor greenColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"";
    
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"Settings", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadUserPhoto];
}


- (SettingsView *)mainView
{
    if(!_mainView)
    {
        _mainView = [[SettingsView alloc] initWithDelegate: self];
    }
    
    return _mainView;
}

#pragma mark - SettingsView Delegate


- (void)showChangePhotoActionSheet
{
    
    CHIActionSheetView *actionSheet = [[CHIActionSheetView alloc] initWithTitle:NSLocalizedString(@"change photo", nil) titleColor:[UIColor mainColor] cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                              otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Photo Library", nil), nil];
    actionSheet.delegate = self;
    [actionSheet show];
    
    
    
    //    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Change photo", nil)
    //                                                       delegate: self
    //                                              cancelButtonTitle: @"Cancel"
    //                                         destructiveButtonTitle: nil
    //                                              otherButtonTitles:
    //                            @"Photo Library",
    //                            @"Take Photo",
    //                            nil];
    //    popup.tag = 1;
    //    [popup showInView: [UIApplication sharedApplication].keyWindow];
}




-(void) logOutButtonAction:(id)sender
{
    CHIAlertView *alertView = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:NSLocalizedString(@"Log out", nil) message:NSLocalizedString(@"Do you want to logout?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitle:NSLocalizedString(@"Yes", nil)];
    [alertView show];
}


- (void) logoutAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidLogOut" object:nil];
    
    NSString *name =  [[NSUserDefaults standardUserDefaults] objectForKey: @"LogInName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"LogInName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[KeychainManager shared] deleteItemForUserName:name];
    [[JabberManager shared] disconnect];
    AppDelegate *applicationDelegate = [UIApplication sharedApplication].delegate;
    [applicationDelegate showLoginScreen];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

#pragma mark - KeyBoardNotifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue     = [userInfo objectForKey: UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue: &animationDuration];
    
    [UIView animateWithDuration: animationDuration animations:^{
        self.mainView.keyboardOffset = keyboardRect.size.height;
        [self.mainView layoutSubviews];
    }];
    
    
}

- (void) keyboardWillHide:(NSNotification*) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue: &animationDuration];
    
    [UIView animateWithDuration: animationDuration animations:^{
        self.mainView.keyboardOffset = 0.0f;
        [self.mainView layoutSubviews];
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - CHIActionSheetDelegate

- (void)actionSheet:(CHIActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return;
    }
    else if (buttonIndex == 1)
    {
        if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO))
            return;
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        cameraUI.allowsEditing = NO;
        cameraUI.delegate = self;
        
        [self presentViewController: cameraUI animated: YES completion: nil];
    }
    else if (buttonIndex == 2)
    {
        UIImagePickerController *picker;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController: picker animated: YES completion: nil];
        }
    }
    else
    {
        return;
    }
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [self.mainView.changePhotoButton setEnabled: NO];
    
    [self updateAvatar: chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.mainView.changePhotoButton setEnabled: YES];

    }];
}


- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid;
{
    [self loadUserPhoto];
}


- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    [self loadUserPhoto];
}


- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    
    CHIAlertView *alertView = [[CHIAlertView alloc] initWithBaseAppColor:[UIColor mainColor] title:nil message:NSLocalizedString(@"Can not update photo", nil) delegate:self cancelButtonTitle:nil otherButtonTitle:@"OK"];
    [alertView show];
    
    [self.mainView.changePhotoButton setEnabled: YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - CHIAlertViewDelegate

- (void)chiAlertView:(CHIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //YES
    if (buttonIndex == 1)
    {
        [self logoutAction];
    }
}


#pragma mark - UIAlertView


- (void)            alertView : (UIAlertView*) alertView
    didDismissWithButtonIndex : (NSInteger)    buttonIndex
{
    if(buttonIndex == 1)
    {
        [self logoutAction];
    }
}


#pragma mark - Private


- (void) getUserProfile
{
    NSManagedObjectContext *context = [[JabberManager shared] managedObjectContext_roster];
    XMPPStream *stream = [[JabberManager shared] xmppStream];
    self.user = [[[JabberManager shared] xmppRosterStorage] myUserForXMPPStream: stream
                                                           managedObjectContext: context];
    
}


- (void) configurePhotoForImageView: (UIImageView*) imageView
{
    XMPPJID *myjid = [[[JabberManager shared] xmppStream] myJID];
    
    NSData *photoData = [[[JabberManager shared] xmppvCardAvatarModule] photoDataForJID: myjid];
    
    if (photoData != nil)
    {
        imageView.image = [UIImage imageWithData: photoData];
    }
    else
    {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = [UIImage imageNamed: @"defolt_avatar"];
    }
}


- (void) loadUserPhoto
{
    XMPPJID *myjid = [[[JabberManager shared] xmppStream] myJID];
    NSString *userName = [NSString stringWithFormat:@"%@@%@",myjid.user, myjid.domain];
    if (!userName)
    {
        self.mainView.accountNameLabel.text = @"Cannot get user display name";
    }
    else
    {
        self.mainView.accountNameLabel.text = userName;
    }
    [self configurePhotoForImageView: self.mainView.userPictureImageView];
}


- (void) updateAvatar: (UIImage *) avatar
{
    
//    NSData *imageData = [self imageWithImage:avatar scaledToSize:CGSizeMake(128, 128)];
//    
//    XMPPvCardTempModule *vCardTempModule = [[JabberManager shared] xmppvCardTempModule];
//    
//    [vCardTempModule addDelegate: self delegateQueue: dispatch_get_main_queue()];
//    
//    XMPPvCardTemp *myVcardTemp = [vCardTempModule myvCardTemp];
//    [myVcardTemp setPhoto:imageData];
//    
//    [vCardTempModule updateMyvCardTemp:myVcardTemp];
    UIImage *img = squareCropImageToSideLength(avatar, 64.0f);

    NSData *imageData1 = UIImageJPEGRepresentation(img,0.5);
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE"stringValue:@"image/jpeg"];
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[imageData1 base64EncodedStringWithOptions:0]];
    
    NSLog(@"%lu", (unsigned long)[[imageData1 base64EncodedStringWithOptions:0] length]);
    
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    XMPPvCardTemp *myvCardTemp = [[[JabberManager shared] xmppvCardTempModule]myvCardTemp];
    if (myvCardTemp) {
        [myvCardTemp setPhoto:imageData1];
        [[[JabberManager shared] xmppvCardTempModule] updateMyvCardTemp
         :myvCardTemp];
        
    }
    else{
        
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
        [[[JabberManager shared] xmppvCardTempModule] updateMyvCardTemp:newvCardTemp];
    }
    self.mainView.userPictureImageView.image = img;
}

UIImage *squareCropImageToSideLength(UIImage *sourceImage,
                                     CGFloat sideLength)
{
    // input size comes from image
    CGSize inputSize = sourceImage.size;
    
    // round up side length to avoid fractional output size
    sideLength = ceilf(sideLength);
    
    // output size has sideLength for both dimensions
    CGSize outputSize = CGSizeMake(sideLength, sideLength);
    
    // calculate scale so that smaller dimension fits sideLength
    CGFloat scale = MAX(sideLength / inputSize.width,
                        sideLength / inputSize.height);
    
    // scaling the image with this scale results in this output size
    CGSize scaledInputSize = CGSizeMake(inputSize.width * scale,
                                        inputSize.height * scale);
    
    // determine point in center of "canvas"
    CGPoint center = CGPointMake(outputSize.width/2.0,
                                 outputSize.height/2.0);
    
    // calculate drawing rect relative to output Size
    CGRect outputRect = CGRectMake(center.x - scaledInputSize.width/2.0,
                                   center.y - scaledInputSize.height/2.0,
                                   scaledInputSize.width,
                                   scaledInputSize.height);
    
    // begin a new bitmap context, scale 0 takes display scale
    UIGraphicsBeginImageContextWithOptions(outputSize, YES, 0);
    
    // optional: set the interpolation quality.
    // For this you need to grab the underlying CGContext
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    // draw the source image into the calculated rect
    [sourceImage drawInRect:outputRect];
    
    // create new image from bitmap context
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up
    UIGraphicsEndImageContext();
    
    // pass back new image
    return outImage;
}

- (NSData *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(newImage);
}

@end

