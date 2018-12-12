//
//  UIFont+JabberCHIFonts.m
//  jabber
//
//  Created by CityHall on 9/8/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "UIFont+JabberCHIFonts.h"


@implementation UIFont (JabberCHIFonts)


+ (instancetype) helveticaNeueCyrLightWithSize: (float) size
{
    return [UIFont fontWithName: @"HelveticaNeue-Light" size: size];
}

+ (instancetype) proximaNovaLightWithSize: (float) size
{
    return [UIFont fontWithName: @"ProximaNova-Light" size: size];
}

+ (instancetype) proximaNovaBoldWithSize: (float) size
{
    return [UIFont fontWithName: @"ProximaNova-Bold" size: size];
}

+ (instancetype) helveticaNeueCyrRomanWithSize: (CGFloat) size
{
    return [UIFont fontWithName:@"HelveticaNeueCyr-Roman" size:size];
}

+ (instancetype) helveticaNeueCyrRomanBOLDWithSize: (CGFloat) size
{
    return [UIFont fontWithName:@"helveticaneuecyr-bold" size:size];
}

+ (instancetype) helveticaNeueCyrRomanMEDIUMWithSize: (CGFloat) size
{
    return [UIFont fontWithName:@"helveticaneuecyr-medium" size:size];
}

@end
