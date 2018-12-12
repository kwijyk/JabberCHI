//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "PhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "NSData+Base64Additions.h"


@interface PhotoMediaItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;
@property (strong, nonatomic) UIImage     *fullImage;

@end


@implementation PhotoMediaItem

#pragma mark - Initialization


- (instancetype) initWithMessageString: (NSString*) messageString
{
    self = [super init];
    if (self)
    {
        [self setupThumbnailWithString: messageString];
        [self setupFullImageWith64BaseEncodedString: messageString];
        
        _cachedImageView = nil;
    }
    
    return self;
}

- (void)dealloc
{
    _image = nil;
    _cachedImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}


- (void) setupThumbnailWithString: (NSString*) messageString
{
    NSString *attchm = [[messageString componentsSeparatedByString: @"<thumbnail>"] objectAtIndex: 1];
    NSString *str    = [[attchm componentsSeparatedByString: @"</thumbnail>"] objectAtIndex: 0];
    
    NSData *base64Photo = [NSData decodeBase64ForString: str];
    self.image = [UIImage imageWithData: base64Photo];
}


- (void) setupFullImageWith64BaseEncodedString: (NSString*) string
{
//    if (!self.fullImage)
//    {
//        UIImageView *imageView  = [[UIImageView alloc] init];
//        imageView.backgroundColor = [UIColor lightGrayColor];
//        
//        __weak PhotoMediaItem *weakSelf = self;
//        
//        dispatch_queue_t myQueue = dispatch_queue_create("com.chisw.jabber.ImageMessageQueue", 0);
//        
//        dispatch_async(myQueue, ^{
//            
//            NSString *attchm = [[string componentsSeparatedByString: @"<attachment>"] objectAtIndex: 1];
//            NSString *str    = [[attchm componentsSeparatedByString: @"</attachment>"] objectAtIndex: 0];
//            
//            NSData *base64Photo = [NSData decodeBase64ForString: str];
//            weakSelf.fullImage = [UIImage imageWithData: base64Photo];
//            
//            CGSize size = [weakSelf mediaViewDisplaySize];
//            UIImageView *imageView  = [[UIImageView alloc] initWithImage: weakSelf.image];
//            imageView.frame         = CGRectMake(0.0f, 0.0f, size.width, size.height);
//            imageView.contentMode   = UIViewContentModeScaleAspectFill;
//            imageView.clipsToBounds = YES;
//            
//            [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView: imageView
//                                                                        isOutgoing: weakSelf.appliesMediaViewMaskAsOutgoing];
//            //
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.cachedImageView = imageView;
//            });
//        });
//    }
}


#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView*)mediaView
{
    if (self.image == nil)
    {
        return nil;
    }
    
    if (self.cachedImageView == nil)
    {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView: imageView
                                                                    isOutgoing: self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}

#pragma mark - NSCopying

//- (instancetype)copyWithZone:(NSZone *)zone
//{
//    PhotoMediaItem *copy = [[PhotoMediaItem allocWithZone:zone] initWithImage:self.image];
//    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
//    return copy;
//}

@end
