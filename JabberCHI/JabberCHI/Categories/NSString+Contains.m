//
//  NSString+Contains.m
//  jabber
//
//  Created by Developer on 10/19/15.
//  Copyright © 2015 CHISoftware. All rights reserved.
//

#import "NSString+Contains.h"

@implementation NSString (Contains)

- (BOOL)containsSecondString:(NSString*)secondString
{
    NSRange range = [self rangeOfString:secondString];
    return range.length != 0;
}

@end

