//
//  PositionAdjustorAccordingKeyBoard.h
//  IphoneIJiJin
//
//  Created by wangxiao on 15/11/30.
//
//

#import <Foundation/Foundation.h>
#import "UIViewControllerAspect.h"


@interface PositionAdjustorAccordingKeyBoard : NSObject<UIViewControllerAspectDelegate>

@end


@interface UIViewController (PositionAdjustorAccordingKeyBoard)
@property (nonatomic) BOOL enableAdjustPositionAccordingKeyBoard;
@end