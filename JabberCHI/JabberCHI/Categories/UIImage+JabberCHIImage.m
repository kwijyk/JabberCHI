//
//  UIImage+JabberCHIImage.m
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "UIImage+JabberCHIImage.h"

@implementation UIImage (JabberCHIImage)


- (UIImage*) imageInEllipse
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [path addClip];
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (UIImage*) imageWithColor: (UIColor*) color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage*) thumbnailForImage: (UIImage*) image;
{
    CGFloat a = image.size.width / image.size.height;
    
    CGSize newSize = CGSizeMake(300.0f * a, 300.0f);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect: CGRectMake(0,0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
