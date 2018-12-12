//
//  CHIAlertView.m
//  CommonElementsCHI
//
//  Created by iosDeveloper on 09.11.15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import "CHIAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+JabberCHIFonts.h"
#import "UIColor+JabberCHIColors.h"
#import "AlertManager.h"

#define BUTTON_HEIGHT 31.0
#define BUTTON_WIDTH 90.0
#define CORNER_RADIUS_BUTTON 15.0
#define CORNER_RADIUS_ALERT 5.0
#define TITLE_HEIGHT 36.0
#define MESSAGE_HEIGHT 40.0
#define OFFSET 15.0

@interface CHIAlertView ()

@property (nonatomic, assign) CGFloat  alertHeight;
@property (nonatomic, assign) CGFloat  alertWidth;
@property (nonatomic, assign) CGFloat  messageLabelHeight;
@property (nonatomic, strong) UIView   *alertView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UILabel  *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *otherButton;
@property (nonatomic, assign) BOOL     isBothButtonsInitialized;

@end


@implementation CHIAlertView

@synthesize delegate;

#pragma mark - init

- (id)initWithBaseAppColor: (UIColor*) baseColor title:(NSString *)title message:(NSString *)message delegate:(id)AlertDelegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self)
    {
        delegate = AlertDelegate;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        //minimal height
        self.alertHeight = OFFSET;
        self.alertWidth = 260.0;
        if (title)
        {
            [self setupTitleLabelWithText:title andColor:baseColor];
            self.alertHeight += TITLE_HEIGHT;
        }
        
        if (message)
        {
            [self setupMessageLabelWithText:message];
            self.alertHeight +=  self.messageLabelHeight + OFFSET;
        }
        
        self.isBothButtonsInitialized = NO;
        
        if (cancelButtonTitle && otherButtonTitle)
        {
            self.isBothButtonsInitialized = YES;
            
            [self customizeOtherButtonWithTitle: otherButtonTitle andColor: baseColor];
            
            [self customizeCancelButtonWithTitle:cancelButtonTitle andColor:[UIColor cancelButtonColor]];
            
            self.alertHeight += BUTTON_HEIGHT + OFFSET;
        }
        else if (cancelButtonTitle)
        {
            [self customizeCancelButtonWithTitle:cancelButtonTitle andColor:[UIColor cancelButtonColor]];
            
            
            self.alertHeight += BUTTON_HEIGHT + OFFSET;
        }
        else if (otherButtonTitle)
        {
            [self customizeOtherButtonWithTitle: otherButtonTitle andColor: baseColor];
            
            
            self.alertHeight += BUTTON_HEIGHT + OFFSET;
        }
        
        [self setupAlertView];
        
        if (title)
        {
            [self.alertView addSubview:self.titleLabel];
        }
        if (message)
        {
            [self.alertView addSubview:self.messageLabel];
        }
        
        if (otherButtonTitle)
        {
            [self.alertView addSubview:self.otherButton];
        }
        if (cancelButtonTitle)
        {
            [self.alertView addSubview:self.cancelButton];
        }
    }
    return self;
}

- (id)initWithBaseAppColor: (UIColor*) baseColor title:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
     withCancelActionBlock: (CancelAction) cancelActionBlock
       andOtherActionBlock: (OtherAction) otherActionBlock
{
    self = [self initWithBaseAppColor:baseColor title:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle];
    
    if (self)
    {
        self.cancelActionBlock = cancelActionBlock;
        self.otherActionBlock = otherActionBlock;
    }
    return self;
}

#pragma mark - layoutSubviews

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentY = 0;
    
    [self.alertView setFrame: CGRectMake((self.frame.size.width - self.alertWidth) / 2,
                                         (self.frame.size.height - self.alertHeight) / 2,
                                         self.alertWidth,
                                         self.alertHeight)];
    
    if (self.titleLabel)
    {
        [self.titleLabel setFrame: CGRectMake(0, currentY, self.alertWidth, TITLE_HEIGHT)];
        currentY = TITLE_HEIGHT;
    }
    
    if (self.messageLabel)
    {
        [self.messageLabel setFrame: CGRectMake(OFFSET, currentY + OFFSET
                                                , self.alertWidth - OFFSET*2,  self.messageLabelHeight)];
        currentY +=  self.messageLabelHeight + OFFSET;
    }
    
    currentY += OFFSET;
    if (self.isBothButtonsInitialized == YES)
    {
        
        CGFloat spaceBetweenButtons = self.alertWidth - 55 - BUTTON_WIDTH * 2;
        CGFloat offsetToFirstButton = (self.alertWidth - BUTTON_WIDTH * 2 - spaceBetweenButtons) / 2;
        [self.otherButton setFrame: CGRectMake(offsetToFirstButton, currentY, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [self.cancelButton setFrame: CGRectMake(CGRectGetMaxX(self.otherButton.frame) + spaceBetweenButtons, currentY, BUTTON_WIDTH, BUTTON_HEIGHT)];
    }
    else
    {
        [self.otherButton setFrame: CGRectMake(self.alertView.frame.size.width / 2 - BUTTON_WIDTH / 2, currentY, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [self.cancelButton setFrame: CGRectMake(self.alertView.frame.size.width / 2 - BUTTON_WIDTH / 2,currentY, BUTTON_WIDTH, BUTTON_HEIGHT)];
    }
    
}

#pragma mark - Setup

- (void) setupTitleLabelWithText:(NSString*) text andColor: (UIColor*) color
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.font = [UIFont helveticaNeueCyrRomanMEDIUMWithSize:13.0];
    self.titleLabel.textAlignment  = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = color;
    self.titleLabel.text = text;
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel sizeToFit];
    
    self.titleLabel.textColor = [UIColor whiteColor];
}

- (void) setupMessageLabelWithText:(NSString*) text
{
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont helveticaNeueCyrRomanWithSize:11.0]
                             range:NSMakeRange(0, attributedString.length)];
    self.messageLabel.attributedText = attributedString ;
    self.messageLabel.numberOfLines = 0;
    [self.messageLabel sizeThatFits:attributedString.size];
    
    CGRect paragraphRect =
    [attributedString boundingRectWithSize:CGSizeMake(self.alertWidth - OFFSET * 2, 500.0f)
                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                   context:nil];
    self.messageLabelHeight = paragraphRect.size.height + 2;
}

- (void) setupAlertView
{
    self.alertView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.alertView setBackgroundColor: [UIColor whiteColor]];
    self.alertView.opaque = YES;
    self.alertView.clipsToBounds = YES;
    self.alertView.layer.cornerRadius = CORNER_RADIUS_ALERT;
    
    [self addSubview:self.alertView];
}

- (void) customizeOtherButtonWithTitle: (NSString*) title andColor: (UIColor*) color
{
    self.otherButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.otherButton setTag:1001];
    [self.otherButton setTitle:title forState:UIControlStateNormal];
    [self.otherButton.titleLabel setFont:[UIFont helveticaNeueCyrRomanWithSize:12]];
    [self.otherButton setBackgroundColor:color];
    self.otherButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [self.otherButton addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) customizeCancelButtonWithTitle: (NSString*) title andColor: (UIColor*) color
{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.cancelButton setTag:1000];
    [self.cancelButton setTitle:title forState:UIControlStateNormal];
    [self.cancelButton.titleLabel setFont:[UIFont helveticaNeueCyrRomanWithSize:12]];
    [self.cancelButton setBackgroundColor: [UIColor cancelButtonColor]];
    self.cancelButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    
    [self.cancelButton addTarget:self action:@selector(onBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Show

- (void)show
{
    [([AlertManager shared].alertsArray) addObject: self];
    
    if ([AlertManager shared].alertsArray.count == 1 && (![AlertManager shared].isAlreadyShowed))
    {
        [[AlertManager shared] showAlert];
    }
}

- (void) showSingleAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *topView = [[UIApplication sharedApplication].delegate window].rootViewController.view;
        if ([topView isKindOfClass:[UIView class]])
        {
            [topView endEditing:YES];
            [topView addSubview:self];
            [self animateShow];
        }
    });
}

#pragma mark - ButtonMethods

- (void)onBtnPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSInteger button_index = button.tag - 1000;
    
    if ([delegate respondsToSelector:@selector(chiAlertView:clickedButtonAtIndex:)])
    {
        [delegate chiAlertView:self clickedButtonAtIndex:button_index];
    }
    else
    {
        if((button_index == 0) && self.cancelActionBlock)
        {
            self.cancelActionBlock(@(button_index));
        }
        else if (self.otherActionBlock)
        {
            self.otherActionBlock(@(button_index));
        }
    }
    [self animateHide];
    
    [[AlertManager shared] alertCallBack];
    
}

#pragma mark - Animations

- (void)animateShow
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.3;
    
    [self.alertView.layer addAnimation:animation forKey:@"show"];
}

- (void)animateHide
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.0, 0.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:0.9],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.3;
    
    [self.alertView.layer addAnimation:animation forKey:@"hide"];
    
    [self performSelector:@selector(removeFromSuperview) withObject:self afterDelay:0.105];
}

@end