//
//  CHIActionSheetView.h
//  CommonElementsCHI
//
//  Created by iosDeveloper on 04.11.15.
//  Copyright © 2015 iosDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHIActionSheetView;

@protocol CHIActionSheetDelegate;


typedef enum CHIActionSheetResult {
    CHIActionSheetButtonResultSelected,
    CHIActionSheetResultResultCancelled
} CHIActionSheetResult;

typedef enum CHIActionSheetCallbackType {
    CHIActionSheetCallbackTypeClickedButtonAtIndex,
    CHIActionSheetCallbackTypeDidDismissWithButtonIndex,
    CHIActionSheetCallbackTypeWillDismissWithButtonIndex,
    CHIActionSheetCallbackTypeWillPresentActionSheet,
    CHIActionSheetCallbackTypeDidPresentActionSheet
} CHIActionSheetCallbackType;

typedef void(^CHIActionSheetCallbackBlock)(CHIActionSheetCallbackType result, NSInteger buttonIndex, NSString *buttonTitle);


@interface CHIActionSheetView : UIView

@property (strong, nonatomic) NSMutableArray *buttons;
@property (weak, nonatomic) id <CHIActionSheetDelegate> delegate;
@property (copy, nonatomic) CHIActionSheetCallbackBlock callbackBlock;

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (id)initWithCancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (id)initWithTitle:(NSString *)title titleColor: (UIColor*)titleColor cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)show;
- (void)cancelActionSheet;

@end


@protocol CHIActionSheetDelegate <NSObject>
@optional
- (void)willPresentActionSheet:(CHIActionSheetView *)actionSheet;  // before animation and showing view
- (void)didPresentActionSheet:(CHIActionSheetView *)actionSheet;  // after animation
- (void)actionSheet:(CHIActionSheetView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;  // when user taps a button
- (void)actionSheet:(CHIActionSheetView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after hide animation
- (void)actionSheet:(CHIActionSheetView *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex;  // before hide animation
@end

@interface CHIActionSheetButton : UIButton

@property (nonatomic, strong) UIView *dividerView;

@end