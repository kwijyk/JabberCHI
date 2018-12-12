//
//  CHIJButton.m
//  JabberCHI
//
//  Created by CHI Developer on 7/13/15.
//  Copyright (c) 2015 CHISoftware. All rights reserved.
//

#import "CHIJButton.h"
#import "UIColor+JabberCHIColors.h"
#import "UIFont+JabberCHIFonts.h"

@implementation CHIJButton

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor mainColor];
        self.layer.cornerRadius = 2.5f;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont helveticaNeueCyrLightWithSize: 15.f];
    }
    return self;
}

- (instancetype)initChangePhoto
{
    self = [super init];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.cornerRadius = 0.f;
        
        UIColor *color = [UIColor colorWithRed:(CGFloat)30.0f/255.0
                                         green:(CGFloat)88.0f/255.0
                                          blue:(CGFloat)121.0f/255.0
                                         alpha:(CGFloat)1.0f];
        
        [self setTitleColor: color forState: UIControlStateNormal];
        
        self.titleLabel.font = [UIFont helveticaNeueCyrLightWithSize: 15.f];
    }
    return self;
}

@end
