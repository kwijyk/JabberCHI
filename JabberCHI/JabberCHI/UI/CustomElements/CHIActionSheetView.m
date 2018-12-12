//
//  CHIActionSheetView.m
//  CommonElementsCHI
//
//  Created by iosDeveloper on 04.11.15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import "CHIActionSheetView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+JabberCHIColors.h"
#import "UIFont+JabberCHIFonts.h"


@interface CHIActionSheetView ()

@property (nonatomic, strong) UIView *blackOutView;
@property (nonatomic, strong) UIView *baseButtonsView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat buttonWidth;


- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle primaryButtonTitle:(NSString *)primaryButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle firstOtherButtonTitle:(NSString *)firstOtherButtonTitle otherButtonTitlesList:(va_list)otherButtonsList;

- (void)setupButtons;
- (UIView *)buildBlackOutViewWithFrame:(CGRect)frame;

- (CHIActionSheetButton *)buildButtonWithTitle:(NSString *)title;
- (UIButton *)buildCancelButtonWithTitle:(NSString *)title;
- (CHIActionSheetButton *)buildPrimaryButtonWithTitle:(NSString *)title;
- (CHIActionSheetButton *)buildDestroyButtonWithTitle:(NSString *)title;

- (CGFloat)calculateSheetHeight;

- (void)buttonWasPressed:(id)button;

@end


const CGFloat kButtonPadding = 6;
const CGFloat kSideOffset = 6;
const CGFloat kButtonHeight = 42;
const CGFloat kCancelButtonHeight = 39;
const CGFloat kFontSize = 13;

const CGFloat kActionSheetAnimationTime = 0.2;
const CGFloat kBlackoutViewFadeInOpacity = 0.7;


@implementation CHIActionSheetView

@synthesize delegate;
@synthesize callbackBlock;

@synthesize buttons;
@synthesize blackOutView;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.buttons = [NSMutableArray array];
        self.opaque = YES;
    }
    
    return self;
}

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle firstOtherButtonTitle:(NSString *)firstOtherButtonTitle otherButtonTitlesList:(va_list)otherButtonsList {
    
    self = [self init];
    if (self) {
        
        // Build normal buttons
        NSString *argString = firstOtherButtonTitle;
        while (argString != nil) {
            
            UIButton *button = [self buildButtonWithTitle:argString];
            [self.buttons addObject:button];
            
            argString = va_arg(otherButtonsList, NSString *);
        }
        
        // Build cancel button
        UIButton *cancelButton = [self buildCancelButtonWithTitle:cancelButtonTitle];
        [self.buttons insertObject:cancelButton atIndex:0];
        
        [self.baseButtonsView setBackgroundColor:[UIColor whiteColor]];
        [self setupButtons];
        [self setupTitle];
        
    }
    
    return self;
}

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    va_list args;
    va_start(args, otherButtonTitles);
    self = [self initWithCancelButtonTitle:cancelButtonTitle firstOtherButtonTitle:otherButtonTitles otherButtonTitlesList:args];
    va_end(args);
    
    return self;
}

- (id)initWithTitle:(NSString *)title titleColor: (UIColor*)titleColor cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (title)
        self.titleLabel = [self buildTitleLabelWithTitle:title andColor: titleColor];
    va_list args;
    va_start(args, otherButtonTitles);
    self = [self initWithCancelButtonTitle:cancelButtonTitle firstOtherButtonTitle:otherButtonTitles otherButtonTitlesList:args];
    va_end(args);
    
    
    
    return self;
}

#pragma mark - View setup

- (void)layoutSubviews
{
    [self.baseButtonsView setFrame: CGRectMake(kSideOffset, 0, self.frame.size.width - kSideOffset * 2, self.frame.size.height - kCancelButtonHeight - kButtonPadding * 2)];
    self.baseButtonsView.layer.cornerRadius = 5;
    self.baseButtonsView.clipsToBounds = YES;
    
    self.buttonWidth = self.frame.size.width - kSideOffset * 2;
    
    [self updateTitle];
    [self updateButtons];
}

- (void)updateButtons
{
    CGFloat yOffset = self.frame.size.height - kButtonPadding - floorf(kCancelButtonHeight);
    
    
    for (CHIActionSheetButton *button in self.buttons)
    {
        if ([self.buttons indexOfObject:button] == 0)
        {
            button.frame = CGRectMake(kSideOffset, yOffset, self.buttonWidth, kCancelButtonHeight);
            yOffset -= kButtonPadding + kButtonHeight;
        }
        else
        {
            button.frame = CGRectMake(0, yOffset, self.buttonWidth, kButtonHeight);
            [self.baseButtonsView addSubview:button];
            yOffset -= kButtonHeight;
            button.dividerView.hidden = NO;
        }
        self.baseButtonsView.clipsToBounds = YES;
    }
    
}

- (void)setupButtons {
    
    CGFloat yOffset = self.frame.size.height - kButtonPadding - floorf(kCancelButtonHeight);
    
    for (CHIActionSheetButton *button in self.buttons)
    {
        if ([self.buttons indexOfObject:button] == 0)
        {
            button.frame = CGRectMake(kSideOffset, yOffset, self.buttonWidth, kCancelButtonHeight);
            [self addSubview:button];
            yOffset -= kButtonPadding + kButtonHeight;
        }
        else
        {
            button.frame = CGRectMake(0, yOffset, self.buttonWidth, kButtonHeight);
            button.dividerView.hidden = NO;
            
            [self.baseButtonsView addSubview:button];
            yOffset -= kButtonHeight;
        }
        self.baseButtonsView = [[UIView alloc] initWithFrame:CGRectZero ];
        [self addSubview:self.baseButtonsView];
        self.baseButtonsView.clipsToBounds = YES;
    }
    [self.baseButtonsView setBackgroundColor: [UIColor whiteColor]];
}

- (void) setupTitle
{
    [self.baseButtonsView addSubview:self.titleLabel];
}

- (void) updateTitle
{
    self.titleLabel.frame = CGRectMake(0, self.titleLabel.frame.origin.y, self.buttonWidth, kCancelButtonHeight);
    
}

#pragma mark - Blackout view builder

- (UIView *)buildBlackOutViewWithFrame:(CGRect)frame {
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor blackColor];
    view.opaque = YES;
    view.alpha = 0;
    
    return view;
}

#pragma mark - Button builders

- (UILabel *)buildTitleLabelWithTitle:(NSString *)title andColor: (UIColor*)titleColor {
    
    UIFont *titleFont = [UIFont helveticaNeueCyrRomanMEDIUMWithSize:kFontSize];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0, self.frame.size.width, kButtonHeight)];
    label.backgroundColor = titleColor;
    label.font = titleFont;
    label.numberOfLines = 0;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    return label;
}

- (CHIActionSheetButton *)buildButtonWithTitle:(NSString *)title {
    
    CHIActionSheetButton *button = [[CHIActionSheetButton alloc] init];
    [button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;
    button.opaque = YES;
    
    button.clipsToBounds = YES;
    
    [button.titleLabel setFont:[UIFont helveticaNeueCyrRomanWithSize:kFontSize]];
    UIColor *titleColor = [UIColor blackColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    
    button.titleLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    button.titleLabel.layer.shadowRadius = 0.0;
    button.titleLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    button.titleLabel.layer.shadowOpacity = 0.5;
    
    return button;
}

- (UIButton *)buildCancelButtonWithTitle:(NSString *)title {
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;
    button.opaque = YES;
    
    [button.titleLabel setFont:[UIFont helveticaNeueCyrRomanMEDIUMWithSize:kFontSize]];
    UIColor *titleColor = [UIColor whiteColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.layer.cornerRadius = 20;
    
    [button setBackgroundColor: [UIColor cancelButtonColor]];
    
    button.clipsToBounds = YES;
    
    return button;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
    return [[[self.buttons objectAtIndex:buttonIndex] titleLabel] text];
}

#pragma mark - Button actions

- (void)buttonWasPressed:(id)button {
    NSInteger buttonIndex = [self.buttons indexOfObject:button];
    
    if (self.callbackBlock) {
        self.callbackBlock(CHIActionSheetCallbackTypeClickedButtonAtIndex, buttonIndex, [[[self.buttons objectAtIndex:buttonIndex] titleLabel] text]);
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
            [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
        }
    }
    
    [self hideActionSheetWithButtonIndex:buttonIndex];
}

- (void)hideActionSheetWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0) {
        if (self.callbackBlock) {
            self.callbackBlock(CHIActionSheetCallbackTypeWillDismissWithButtonIndex, buttonIndex, [[[self.buttons objectAtIndex:buttonIndex] titleLabel] text]);
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
                [self.delegate actionSheet:self willDismissWithButtonIndex:buttonIndex];
            }
        }
    }
    [UIView animateWithDuration:kActionSheetAnimationTime animations:^{
        CGFloat endPosition = self.frame.origin.y + self.frame.size.height;
        self.frame = CGRectMake(self.frame.origin.x, endPosition, self.frame.size.width, self.frame.size.height);
        self.blackOutView.alpha = 0;
    } completion:^(BOOL finished) {
        if (buttonIndex >= 0) {
            if (self.callbackBlock) {
                self.callbackBlock(CHIActionSheetCallbackTypeWillDismissWithButtonIndex, buttonIndex, [[[self.buttons objectAtIndex:buttonIndex] titleLabel] text]);
            }
            else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                    [self.delegate actionSheet:self didDismissWithButtonIndex:buttonIndex];
                }
            }
        }
        [self removeFromSuperview];
    }];
}

-(void)cancelActionSheet {
    [self hideActionSheetWithButtonIndex:-1];
}

#pragma mark - Present action sheet

- (void)show
{
    UIView *topView  =  [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    
    if ([topView isKindOfClass:[UIView class]])
    {
        CGFloat startPosition = topView.bounds.origin.y + topView.bounds.size.height;
        self.frame = CGRectMake(0, startPosition, topView.bounds.size.width, [self calculateSheetHeight]);
        [topView addSubview:self];
        
        self.blackOutView = [self buildBlackOutViewWithFrame:topView.bounds];
        [topView insertSubview:self.blackOutView belowSubview:self];
        
        if (self.callbackBlock) {
            self.callbackBlock(CHIActionSheetCallbackTypeWillPresentActionSheet, -1, nil);
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
                [self.delegate willPresentActionSheet:self];
            }
        }
        
        [UIView animateWithDuration:kActionSheetAnimationTime
                         animations:^{
                             CGFloat endPosition = startPosition - self.frame.size.height;
                             self.frame = CGRectMake(self.frame.origin.x, endPosition, self.frame.size.width, self.frame.size.height);
                             self.blackOutView.alpha = kBlackoutViewFadeInOpacity;
                         }
                         completion:^(BOOL finished) {
                             if (self.callbackBlock) {
                                 self.callbackBlock(CHIActionSheetCallbackTypeWillPresentActionSheet, -1, nil);
                             }
                             else {
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
                                     [self.delegate didPresentActionSheet:self];
                                 }
                             }
                         }];

    }
}

#pragma mark - Helpers

- (CGFloat)calculateSheetHeight
{
    return floorf((kButtonHeight * (self.buttons.count - 1)) + kCancelButtonHeight + kButtonPadding * 2) + self.titleLabel.frame.size.height;
}

@end


@implementation CHIActionSheetButton

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        self.dividerView = [[UIView alloc] init];
        self.dividerView.backgroundColor = [UIColor colorWithRed:227/255 green:227/255 blue:227/255 alpha:0.1];
        [self addSubview:self.dividerView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.dividerView.frame = CGRectMake(kSideOffset, kButtonHeight - 1, self.frame.size.width - kSideOffset, 1);
}
@end