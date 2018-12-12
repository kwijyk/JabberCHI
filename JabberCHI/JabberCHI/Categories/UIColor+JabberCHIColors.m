//
//  UIColor+JabberCHIColors.m
//  JabberCHI
//
//  Created by Yuri on 7/13/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "UIColor+JabberCHIColors.h"

@implementation UIColor (JabberCHIColors)


+(instancetype)mainColor
{
    return [UIColor customColorWithRed: 84 green: 191 blue: 166];
}

+(instancetype)mainTextColor
{
    return [UIColor blackColor];
}

+(instancetype)loginTextFieldColor
{
    return [UIColor customColorWithRed: 255 green: 255 blue: 255 alpha: 0.5];
}

+(instancetype)hightLightedTextColor
{
    return [UIColor lightGrayColor];
}

+(instancetype)segmentedControlColor
{
    return [UIColor customColorWithRed: 44 green: 141 blue: 172];
}

+(instancetype)buttonsColor
{
    return [UIColor customColorWithRed:4 green:132 blue:264];
}

+(instancetype)deliveredTextColor
{
    return [UIColor customColorWithRed:6 green:141 blue:177 alpha:0.5];
}

+ (instancetype) cancelButtonColor
{
    return [UIColor customColorWithRed:238 green:122 blue:96];
}

+ (instancetype) backgroundColor
{
    return [UIColor customColorWithRed:0 green:0 blue:0 alpha:0.7];
    
}

+ (instancetype) infoBackgroundColor

{
    return [UIColor customColorWithRed:0 green:0 blue:0 alpha:0.2];
    
}
#pragma mark - Privete

+(UIColor *)customColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

+(UIColor *)customColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
}

@end
