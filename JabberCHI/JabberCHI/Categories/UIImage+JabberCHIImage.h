//
//  UIImage+JabberCHIImage.h
//  jabber
//
//  Created by Roman on 9/10/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JabberCHIImage)

- (UIImage*) imageInEllipse;


+ (UIImage*) imageWithColor: (UIColor*) color;


+ (UIImage*) thumbnailForImage: (UIImage*) image;


@end
