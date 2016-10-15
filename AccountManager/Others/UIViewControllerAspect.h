//
//  UIViewControllerAspect.h
//  IphoneIJiJin
//
//  Created by wangxiao on 15/11/5.
//
//

#import <Foundation/Foundation.h>


#define ClassNeedToBeRegisteredInAllKindOfUIViewController @[@"PositionAdjustorAccordingKeyBoard"]
#define ClassNeedToBeRegisteredInSpecificKindOfUIViewController @{}

@protocol UIViewControllerAspectDelegate <NSObject>

@optional
- (void)doSomethingInViewWillAppearOfViewController:(UIViewController *)viewController;
- (void)doSomethingInViewDidAppeareOfViewController:(UIViewController *)viewController;
- (void)doSomethingInViewWillDisappearOfViewController:(UIViewController *)viewController;
- (void)doSomethingInViewDidDisappearOfViewController:(UIViewController *)viewController;
@end

@interface UIViewControllerAspect : NSObject

@end
