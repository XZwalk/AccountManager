//
//  UIViewControllerAspect.m
//  IphoneIJiJin
//
//  Created by wangxiao on 15/11/5.
//
//

#import "UIViewControllerAspect.h"
#import "Aspects.h"


@interface UIViewControllerAspect ()
@property (nonatomic, strong)NSArray * registeredObjsInAllKindOfController;
@property (nonatomic, strong)NSDictionary * registeredObjsInSpecificKindOfController;
@end

@implementation UIViewControllerAspect
+ (void)load
{
    /* + (void)load 会在应用启动的时候自动被runtime调用，通过重载这个方法来实现最小的对业务方的“代码入侵” */
    [super load];
    [UIViewControllerAspect sharedInstance];
}

/*
 
 按道理来说，这个sharedInstance单例方法是可以放在头文件的，但是对于目前这个应用来说，暂时还没有放出去的必要
 
 当业务方对这个单例产生配置需求的时候，就可以把这个函数放出去
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static UIViewControllerAspect *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIViewControllerAspect alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self createRegisteredObjsInAllKindOfController];
        [self createRegisteredObjsInSpecificKindOfController];
        
        /* 在这里做好方法拦截 */
        [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo, BOOL animated){
            [self viewWillAppear:animated viewController:[aspectInfo instance]];
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
            [self viewDidAppear:animated viewController:[aspectInfo instance]];
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo>aspectInfo, BOOL animated){
            [self viewWillDisappear:animated viewController:[aspectInfo instance]];
        } error:NULL];
        
        [UIViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated){
            [self viewDidDisappear:animated viewController:[aspectInfo instance]];
        } error:NULL];
    }
    return self;
}

#pragma - Private API
- (void)createRegisteredObjsInAllKindOfController {
    NSMutableArray * registeredObjs = [NSMutableArray array];
    for (NSString * className in ClassNeedToBeRegisteredInAllKindOfUIViewController) {
        [registeredObjs addObject:[[NSClassFromString(className) alloc] init]];
    }
    _registeredObjsInAllKindOfController = registeredObjs;
}

- (void)createRegisteredObjsInSpecificKindOfController {
    NSMutableDictionary * registeredObjs = [NSMutableDictionary dictionary];
    NSDictionary * classNeedToBeRegisteredInSpecificKindOfUIViewController = ClassNeedToBeRegisteredInSpecificKindOfUIViewController;
    for (NSString * className in [classNeedToBeRegisteredInSpecificKindOfUIViewController allKeys]) {
        id obj = [[NSClassFromString(className) alloc] init];
        registeredObjs[obj] = classNeedToBeRegisteredInSpecificKindOfUIViewController[className];
    }
    _registeredObjsInSpecificKindOfController = registeredObjs;
}

//- (BOOL)isViewControllerInRegistered:(UIViewController *)viewController {
//    for (id obj in [_registeredObjsInSpecificKindOfController allKeys]) {
//        NSArray * viewControllerNames = _registeredObjsInSpecificKindOfController[obj];
//        NSString * viewControllerName = NSStringFromClass([viewController class]);
//        if ([viewControllerNames containsObject:viewControllerName]) {
//            return YES;
//        }
//    }
//    return NO;
//}

#pragma - aspect methed
- (void)viewWillAppear:(BOOL)animated viewController:(UIViewController *)viewController {
    for (id<UIViewControllerAspectDelegate> obj in _registeredObjsInAllKindOfController) {
        if ([obj respondsToSelector:@selector(doSomethingInViewWillAppearOfViewController:)]) {
            [obj doSomethingInViewWillAppearOfViewController:viewController];
        }
    }
    
    for (id obj in [_registeredObjsInSpecificKindOfController allKeys]) {
        NSArray * viewControllerNames = _registeredObjsInSpecificKindOfController[obj];
        NSString * viewControllerName = NSStringFromClass([viewController class]);
        if ([viewControllerNames containsObject:viewControllerName]) {
            if ([obj respondsToSelector:@selector(doSomethingInViewWillAppearOfViewController:)]) {
                [obj doSomethingInViewWillAppearOfViewController:viewController];
            }
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated viewController:(UIViewController *)viewController {
    for (id<UIViewControllerAspectDelegate> obj in _registeredObjsInAllKindOfController) {
        if ([obj respondsToSelector:@selector(doSomethingInViewDidAppeareOfViewController:)]) {
            [obj doSomethingInViewDidAppeareOfViewController:viewController];
        }
    }
    
    for (id obj in [_registeredObjsInSpecificKindOfController allKeys]) {
        NSArray * viewControllerNames = _registeredObjsInSpecificKindOfController[obj];
        NSString * viewControllerName = NSStringFromClass([viewController class]);
        if ([viewControllerNames containsObject:viewControllerName]) {
            if ([obj respondsToSelector:@selector(doSomethingInViewDidAppeareOfViewController:)]) {
                [obj doSomethingInViewDidAppeareOfViewController:viewController];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated viewController:(UIViewController *)viewController {
    for (id<UIViewControllerAspectDelegate> obj in _registeredObjsInAllKindOfController) {
        if ([obj respondsToSelector:@selector(doSomethingInViewDidDisappearOfViewController:)]) {
            [obj doSomethingInViewDidDisappearOfViewController:viewController];
        }
    }
    
    for (id obj in [_registeredObjsInSpecificKindOfController allKeys]) {
        NSArray * viewControllerNames = _registeredObjsInSpecificKindOfController[obj];
        NSString * viewControllerName = NSStringFromClass([viewController class]);
        if ([viewControllerNames containsObject:viewControllerName]) {
            if ([obj respondsToSelector:@selector(doSomethingInViewDidDisappearOfViewController:)]) {
                [obj doSomethingInViewDidDisappearOfViewController:viewController];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated viewController:(UIViewController *)viewController {
    for (id<UIViewControllerAspectDelegate> obj in _registeredObjsInAllKindOfController) {
        if ([obj respondsToSelector:@selector(doSomethingInViewWillDisappearOfViewController:)]) {
            [obj doSomethingInViewWillDisappearOfViewController:viewController];
        }
    }
    
    for (id obj in [_registeredObjsInSpecificKindOfController allKeys]) {
        NSArray * viewControllerNames = _registeredObjsInSpecificKindOfController[obj];
        NSString * viewControllerName = NSStringFromClass([viewController class]);
        if ([viewControllerNames containsObject:viewControllerName]) {
            if ([obj respondsToSelector:@selector(doSomethingInViewWillDisappearOfViewController:)]) {
                [obj doSomethingInViewWillDisappearOfViewController:viewController];
            }
        }
    }
}
@end
