//
//  PositionAdjustorAccordingKeyBoard.m
//  IphoneIJiJin
//
//  Created by wangxiao on 15/11/30.
//
//

#import "PositionAdjustorAccordingKeyBoard.h"
#import <objc/runtime.h>

@interface PositionAdjustorAccordingKeyBoard ()
@property (nonatomic, weak)  UIViewController * viewController;
@property (nonatomic, strong)UITextField      * textField;
@property (nonatomic)        CGRect             keyBoardRect;
@property (nonatomic)        CGRect             initialFrame;
@end

@implementation PositionAdjustorAccordingKeyBoard
#pragma mark - UIViewControllerAspectDelegate
- (void)doSomethingInViewWillAppearOfViewController:(UIViewController *)viewController {
    if (!viewController.enableAdjustPositionAccordingKeyBoard) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _viewController = viewController;
}

- (void)doSomethingInViewWillDisappearOfViewController:(UIViewController *)viewController {
    if (!viewController.enableAdjustPositionAccordingKeyBoard) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doSomethingInViewDidAppeareOfViewController:(UIViewController *)viewController {
    if (!viewController.enableAdjustPositionAccordingKeyBoard) {
        return;
    }
   _initialFrame = _viewController.view.frame;
}
#pragma mark - private API
- (void)textFieldViewDidBeginEditing:(NSNotification *)notify {
    _textField = notify.object;
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    _keyBoardRect = CGRectZero;
    [self recoverPosition];
}

- (void)recoverPosition {
    [UIView animateWithDuration:0.3 animations:^{
        [_viewController.view setFrame:_initialFrame];
    }];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    _keyBoardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self adjustPosition];
}

-(void)adjustPosition
{
    if (_textField == nil)   return;
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect textViewRectOnWindow = [[_textField superview] convertRect:_textField.frame
                                                              toView:keyWindow];
    const CGFloat distanceBetweenTextViewAndKeyBoard = 20;
    const CGFloat moveDistance = textViewRectOnWindow.origin.y + textViewRectOnWindow.size.height + distanceBetweenTextViewAndKeyBoard - _keyBoardRect.origin.y;
    if (moveDistance > 0) {
        [self animateMoveAction:moveDistance];
    }
    else {
        if (_viewController.view.frame.origin.y - moveDistance <= 0) {
            [self animateMoveAction:moveDistance];
        }
    }
}

- (void)animateMoveAction:(CGFloat)distance {
    [UIView animateWithDuration:0.3 animations:^{
        _viewController.view.frame = CGRectMake(_viewController.view.frame.origin.x,
                                                _viewController.view.frame.origin.y - distance,
                                                _viewController.view.frame.size.width,
                                                _viewController.view.frame.size.height);
    } completion:nil];
}
@end


static char key;
@implementation UIViewController(PositionAdjustorAccordingKeyBoard)
@dynamic enableAdjustPositionAccordingKeyBoard;
- (void)setEnableAdjustPositionAccordingKeyBoard:(BOOL)enableAdjustPositionAccordingKeyBoard {
    objc_setAssociatedObject(self, &key, [NSNumber numberWithBool:enableAdjustPositionAccordingKeyBoard], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)enableAdjustPositionAccordingKeyBoard {
    return [objc_getAssociatedObject(self, &key) boolValue];
}
@end