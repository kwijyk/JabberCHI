//
//  CHIAlertView.h
//  CommonElementsCHI
//
//  Created by iosDeveloper on 09.11.15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHIAlertView;

typedef void (^CancelAction)(id someParameter);
typedef void (^OtherAction)(id anotherParameter);

@protocol CHIAlertDelegate
- (void) chiAlertView: (CHIAlertView*) alertView clickedButtonAtIndex: (NSInteger) buttonIndex;
@end

@interface CHIAlertView : UIView
{
    id delegate;
}
@property id delegate;

@property (nonatomic, copy) CancelAction    cancelActionBlock;
@property (nonatomic, copy) OtherAction     otherActionBlock;


- (id)initWithBaseAppColor: (UIColor*) baseColor title:(NSString *)title message:(NSString *)message delegate:(id)AlertDelegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

- (id)initWithBaseAppColor: (UIColor*) baseColor title:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
     withCancelActionBlock: (CancelAction) cancelActionBlock
       andOtherActionBlock: (OtherAction) otherActionBlock;

- (void) show;

- (void) showSingleAlert;


@end
