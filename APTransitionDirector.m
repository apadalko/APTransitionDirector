//
//  APTransitionDirector.m
//  APTransitionDirector
//
//  Created by Alex Padalko on 01/10/15.
//  Copyright (c) 2014 Alex Padalko. All rights reserved.
//

#import "APTransitionDirector.h"
#import <objc/runtime.h>
#pragma mark - RUNTimeHelper
@interface RuntimeHelper : NSObject
@end
@implementation RuntimeHelper
#pragma mark helper for UIViewController
+(void)superPresentViewController:(id)vc animated:(BOOL)animated fromViewController:(id)rootVC{
    IMP imp=class_getMethodImplementation([UIViewController class],@selector(presentViewController:animated:completion:));
    typedef void (*func)(id,SEL,id,BOOL,void (^)(void));
    func f = (func)imp;
    f(rootVC,@selector(presentViewController:animated:completion:),vc,animated,nil);
}
+(void)superDismissViewControllerAnimated:(BOOL)animated fromViewController:(id)rootVC{
    IMP imp=class_getMethodImplementation([UIViewController class],@selector(dismissViewControllerAnimated:completion:));
    typedef void (*func)(id,SEL,BOOL,void (^)(void));
    func f = (func)imp;
    f(rootVC,@selector(presentViewController:animated:completion:),animated,nil);
}
#pragma mark  helper for navigation controller
+(void)superPushViewController:(id)vc animated:(BOOL)animated fromNavigationController:(id)nav{
    IMP imp=class_getMethodImplementation([UINavigationController class],@selector(pushViewController:animated:));
    typedef void (*func)(id,SEL,id,BOOL);
    func f = (func)imp;
    f(nav,@selector(pushViewController:animated:),vc,animated);
}
+(UIViewController*)superPopViewControllerAnimated:(BOOL)animated fromNavigationController:(id)nav{
    IMP imp=class_getMethodImplementation([UINavigationController class],@selector(popViewControllerAnimated:));
    typedef UIViewController* (*func)(id,SEL,BOOL);
    func f = (func)imp;
    return f(nav,@selector(popViewControllerAnimated:),animated);
}
+(void)superSelectIndex:(NSUInteger)idx fromTabBarController:(id)tab{
    IMP imp=class_getMethodImplementation([UITabBarController class],@selector(setSelectedIndex:));
    typedef UIViewController* (*func)(id,SEL,NSUInteger);
    func f = (func)imp;
    f(tab,@selector(popViewControllerAnimated:),idx);
}

@end
#pragma markr - global methods
#pragma mark
Class gestureClassForType(enum APGestureType type){
    Class cl;
    switch (type) {
        case APGestureTypeEdgePan:
            cl=[UIScreenEdgePanGestureRecognizer class];
            break;
        case APGestureTypePan:
            cl=[UIPanGestureRecognizer class];
            break;
        case APGestureTypePinch:
            cl=[UIPinchGestureRecognizer class];
            break;
        case APGestureTypeRotation:
            cl=[UIRotationGestureRecognizer class];
            break;
        default:
            break;
            
    }
    return cl;
}
#pragma mark
enum APGestureType typeFromGesture(UIGestureRecognizer*gesture){
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            return APGestureTypeEdgePan;
        }else {
            
            return APGestureTypePan;
        }
        
        
    }else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]){
        
        
        return APGestureTypeRotation;
    }else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]){
        
        return APGestureTypePinch;
    }else{
        
        return APGestureTypeNone;
    }
}
#pragma mark - APTransactionRule
@interface APTransactionRule()


@end

@implementation APTransactionRule : NSObject
+(instancetype)ruleWithGesture:(enum APGestureType)gestureType{
    
    return [[self alloc] initWithGesture:gestureType];
}
-(instancetype)initWithGesture:(enum APGestureType)gestureType{
    if (self == [super init]) {
        _gestureType=gestureType;
    }
    return self;
}
-(instancetype)setupGesture:(void(^)(UIGestureRecognizer*gesture))setupGestureBlock{
    self.setupGestureBlock=setupGestureBlock;
    return self;
}
-(instancetype)valueCalculationBlock:(ValueCallBlock)valueCalculationBlock{
    self.valueCallBlock=valueCalculationBlock;
    return self;
}
-(instancetype)gestureShouldBeginBlock:(BOOL (^)(UIGestureRecognizer *))gestureShouldBegin{
    self.gestureShouldBeginBlock=gestureShouldBegin;
    return self;
}
-(instancetype)actionBlockForValue:(ActionBlockForValue)valueBlock{
    _actionBlockForValue=valueBlock;
    return self;
}
-(instancetype)setDuration:(float)duration andComplitPercent:(float)percentToComplite{
    self.duration=duration;
    self.percentToComplite=percentToComplite;
    return self;
}
-(void)dealloc{
    NSLog(@"DEALLOC: %@",self.description );
}

@end

#pragma mark - APTransitions Categorys

#pragma mark  UIViewController
@implementation UIViewController(APTransitions)
-(void)APTransactionPresentViewController:(UIViewController*)viewController{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    if ([self conformsToProtocol:@protocol(APTransitionProtocol)]) {
        id <APTransitionProtocol> obj = (NSObject<APTransitionProtocol> *)self;
        [a setDelegate:obj];
        [viewController setTransitioningDelegate:a];
        
    }
   [RuntimeHelper superPresentViewController:viewController animated:YES fromViewController:self];
   viewController.transitioningDelegate = nil;
}
-(void)APTransactionPresentViewController:(UIViewController*)viewController withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    [a setDelegate:transitionProtocol];
    [viewController setTransitioningDelegate:a];
    [RuntimeHelper superPresentViewController:viewController animated:YES fromViewController:self];
    viewController.transitioningDelegate = nil;
}
-(void)APTransactionDismissViewController{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    if ([self conformsToProtocol:@protocol(APTransitionProtocol)]) {
        id <APTransitionProtocol> obj = (NSObject<APTransitionProtocol> *)self;
        [a setDelegate:obj];
        [self setTransitioningDelegate:a];
    }
    [RuntimeHelper superDismissViewControllerAnimated:YES fromViewController:self];
    self.transitioningDelegate = nil;
}
-(void)APTransactionDismissViewControllerWithTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    [a setDelegate:transitionProtocol];
    [self setTransitioningDelegate:a];
    [RuntimeHelper superDismissViewControllerAnimated:YES fromViewController:self];
    self.transitioningDelegate = nil;
}
@end
#pragma mark  UINavigationController
@implementation UINavigationController (APTransitions)
-(void)APTransactionPushViewController:(UIViewController*)viewController{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    if ([self conformsToProtocol:@protocol(APTransitionProtocol)]) {
        id <APTransitionProtocol> obj = (NSObject<APTransitionProtocol> *)self;
        [a setDelegate:obj];
        [self setDelegate:a];
    }
    [RuntimeHelper superPushViewController:viewController animated:YES fromNavigationController:self];
    self.delegate = nil;
}
-(void)APTransactionPushViewController:(UIViewController*)viewController withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    [a setDelegate:transitionProtocol];
    [self setDelegate:a];
    [RuntimeHelper superPushViewController:viewController animated:YES fromNavigationController:self];
    self.delegate = nil;
}
-(UIViewController*)APTransactionPopViewController{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    
    if ([self conformsToProtocol:@protocol(APTransitionProtocol)]) {
        id <APTransitionProtocol> obj = (NSObject<APTransitionProtocol> *)self;
        [a setDelegate:obj];
        [self setDelegate:a];
    }
    UIViewController * vc= [RuntimeHelper superPopViewControllerAnimated:YES fromNavigationController:self];
    
    
    self.delegate=nil;
    
    return vc;
}
-(UIViewController*)APTransactionPopViewControllerWithTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    [a setDelegate:transitionProtocol];
    [self setDelegate:a];
    UIViewController * vc= [RuntimeHelper superPopViewControllerAnimated:YES fromNavigationController:self];
    self.delegate=nil;
    return vc;
}
@end

#pragma mark  UITabBarController

@implementation UITabBarController (APTransitions)
/**
 * simple switch to index, sender(UITabBarController) will be asked for conform APTransitionProtocol
 *
 */
-(void)APTransactionSelectIndex:(NSUInteger)idx{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    if ([self conformsToProtocol:@protocol(APTransitionProtocol)]) {
        id <APTransitionProtocol> obj = (NSObject<APTransitionProtocol> *)self;
        [a setDelegate:obj];
        [self setDelegate:a];
        
    }
    [RuntimeHelper superSelectIndex:idx fromTabBarController:self];
    self.delegate = nil;
}
-(void)APTransactionSelectIndex:(NSUInteger)idx withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    APTransitionDirector * a=[[APTransitionDirector alloc]init];
    [a setDelegate:transitionProtocol];
    [self setDelegate:a];
    [RuntimeHelper superSelectIndex:idx fromTabBarController:self];
    self.delegate = nil;
}

@end
#pragma mark -


#pragma mark - APRuleInteractiveTransitions Categorys


@implementation  UIViewController (APRuleInteractiveTransitions)
static NSMutableDictionary * gestureDict=nil;

-(void)baseInteractiveGestureSetup{
    if (!gestureDict) {
        gestureDict=[[NSMutableDictionary alloc]init];
    }
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [(UINavigationController*) self interactivePopGestureRecognizer].enabled = NO;
    }
}
-(void)registerInteractiveTransactionWithRule:(APTransactionRule *)rule andTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol{
    enum APGestureType type=rule.gestureType;
    UIGestureRecognizer * panGesture =[[gestureClassForType(type) alloc] initWithTarget:self action:@selector(recognizerMethod:)];
    NSMutableDictionary * inDict=[gestureDict valueForKey:self.description];
    if (!inDict) {
        inDict=[[NSMutableDictionary alloc] init];
    }
    inDict[@(type)]=[NSDictionary dictionaryWithObjectsAndKeys:panGesture,@"gesture",rule,@"rule",transitionProtocol,@"prot", nil];
    [gestureDict setValue:inDict forKey:self.description];
    [self.view addGestureRecognizer:panGesture];
    [panGesture setDelegate:self];
    
}
-(void)registerInteractiveTransactionWithRule:(APTransactionRule *)rule withAnimationBlockForValueAndGesture:(AnimationBlock (^)(float, UIGestureRecognizer *))animationBlockForValue{
    
    [self registerInteractiveTransactionWithRule:rule withAnimationBlockForValueAndGesture:animationBlockForValue andUpdateBlockForValueAndGesture:nil];
}
-(void)registerInteractiveTransactionWithRule:(APTransactionRule *)rule withAnimationBlockForValueAndGesture:(AnimationBlock (^)(float, UIGestureRecognizer *))animationBlockForValue andUpdateBlockForValueAndGesture:(void (^)(APTransitionDirector * , float, UIGestureRecognizer *))updateBlockForValue{
    [self baseInteractiveGestureSetup];
    enum APGestureType type=rule.gestureType;
    UIGestureRecognizer * panGesture =[[gestureClassForType(type) alloc] initWithTarget:self action:@selector(recognizerMethod:)];
    NSMutableDictionary * inDict=[gestureDict valueForKey:self.description];
    if (!inDict) {
        inDict=[[NSMutableDictionary alloc] init];
    }
    inDict[@(type)]=[NSDictionary dictionaryWithObjectsAndKeys:panGesture,@"gesture",rule,@"rule",animationBlockForValue,@"anim",updateBlockForValue,@"update", nil];
    [gestureDict setValue:inDict forKey:self.description];
    [self.view addGestureRecognizer:panGesture];
    [panGesture setDelegate:self];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    enum APGestureType type=typeFromGesture(gestureRecognizer);
    NSDictionary * inDict=[gestureDict valueForKey:self.description][@(type)];
    if ([self isKindOfClass:[UITabBarController class]]) {
        
        if (CGRectContainsPoint([(UITabBarController*)self tabBar].frame, [gestureRecognizer locationInView:self.view])) {
            return NO;
        }
        
    }
   APTransactionRule * rule=[inDict valueForKey:@"rule"];
    if (rule.gestureShouldBeginBlock) {
        return rule.gestureShouldBeginBlock(gestureRecognizer);
    }
    return YES;
}
- (void)recognizerMethod:(UIGestureRecognizer*)sender {
    static CGPoint firstTouch;
    static APTransitionDirector * animDirector=nil;
    static AnimationBlock (^animBlockForValue)(float,UIGestureRecognizer*);
    static void (^updateBlockForValue)(APTransitionDirector*,float,UIGestureRecognizer*);
    static APTransactionRule * rule=nil;
    static float complPercent=0.5;
    static id<APTransitionProtocol> transitionProtocol;
    if (!rule) {
        firstTouch=[sender locationInView:self.view];
        enum APGestureType type=typeFromGesture(sender);
        NSDictionary * inDict=[gestureDict valueForKey:self.description][@(type)];
        animBlockForValue=[inDict valueForKey:@"anim"];
        updateBlockForValue=[inDict valueForKey:@"update"];
        rule=[inDict valueForKey:@"rule"];
        
        transitionProtocol=[inDict valueForKey:@"prot"];
    }
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case  UIGestureRecognizerStateChanged:
        {
            rule.valueCallBlock(sender,firstTouch,^(float value,float maxValue){
                BOOL isInitial=sender.state == UIGestureRecognizerStateBegan?YES :NO;
                ActionBlock  ab=rule.actionBlockForValue(value,isInitial);
                if (ab) {
                    [animDirector fastCancel];
                    animDirector=[[APTransitionDirector alloc] init];
                    animDirector.interactive=YES;
                    animDirector.animBlock=animBlockForValue(value,sender);
                    animDirector.animDuration=rule.duration;
                    complPercent=rule.percentToComplite;
                    if ([self isKindOfClass:[UITabBarController class]]) {
                        UITabBarController * tb=(UITabBarController*)self;
                        [tb setDelegate:animDirector];
                    }
                    ab();
                    if ([self isKindOfClass:[UITabBarController class]]) {
                        
                        UITabBarController * tb=(UITabBarController*)self;
                        [tb setDelegate:nil];
                    }
                }
                if (!isInitial) {
                       [animDirector setPercent:MIN(0.99, fabsf(value)/maxValue)];
                            animDirector.interactiveUpdateBlock=^(APTransitionDirector * director){
                                if (updateBlockForValue) {
                                        updateBlockForValue(director,value,sender);
                                }
                            };
                }
             
            });
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            BOOL canceled=YES;
            if (animDirector.percent > complPercent && sender.state==UIGestureRecognizerStateEnded) {
                canceled=NO;
            }
            [animDirector endInteractiveTranscation:canceled complition:^{
            }];
            rule=nil;
            animDirector=nil;
            break;
        }
        default: {
            break;
            
        }
    }
}

@end
#pragma mark -
#pragma mark - APnteractiveTransitions Categorys
@implementation UIViewController (APInteractiveTransitions)

-(APTransactionRule*)registerDissmisInteractiveTrasactionWithGesture:(enum APGestureType)gesture{
    

     APTransactionRule * rule = [[APTransactionRule ruleWithGesture:gesture] actionBlockForValue:^ActionBlock(float value, BOOL initial) {
        
        
        if (initial) {
            ActionBlock ab=^{
                
              [self dismissViewControllerAnimated:YES completion:^{
                  
              }];
            };
            
            return ab;
        }
        
        return nil;
        
    }];
    
    
    [self registerInteractiveTransactionWithRule:rule withAnimationBlockForValueAndGesture:nil];
    
    
    return rule;

}


@end
#pragma mark -


#pragma mark - AAPTransitionDirector
@interface APTransitionDirector(){
    
     id<UIViewControllerContextTransitioning> _context;
     CADisplayLink *_displayLink;
}
@end
@implementation APTransitionDirector



-(instancetype)init{
    if (self=[super init]) {
        _animDuration=0.5;
        _interactive=NO;
        _interactiveState=NO;
    }
    return self;
}

#pragma mark - time offset
- (void)setTimeOffset:(NSTimeInterval)timeOffset {
    [self setPercent:timeOffset/self.animDuration];
}
#pragma mark - update percent
-(void)setPercent:(float)percent{
    _percent=percent;
    [self updateInteractiveTransition:percent];
    _timeOffset=_percent*self.animDuration;
    if (self.interactiveUpdateBlock) {
        self.interactiveUpdateBlock(self);
    }
}


#pragma mark - interactiveTransaction ending
-(void)fastCancel{
    
  //

    [[_context containerView].layer removeAllAnimations];
    for (CALayer *l in [_context containerView].layer.sublayers)
    {
        [l removeAllAnimations];
    }
    [[self fromView] setFrame:[_context initialFrameForViewController:[self fromViewController]]];
    [_context cancelInteractiveTransition];
    [_context completeTransition:NO];

}
-(void)endInteractiveTranscation:(BOOL)cancelled complition:(void (^)())complitBlock {
    if (complitBlock) {
       self.interactiveComplitionBlock=complitBlock;
    }
    if (cancelled) {
     
            _interactiveState=APDirectorInteractiveStateCanceling;
      
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCancelAnimation)];
      //  [self cancelInteractiveTransition];

    } else {
        
        _interactiveState=APDirectorInteractiveStateFinishing;
       _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFinishAnimation)];
       // [self finishInteractiveTransition];
    }
       [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


-(void)_transactionFinishFinishing{
    [_displayLink invalidate];
    _percent=1.0;
    if (self.interactiveUpdateBlock) {
        self.interactiveUpdateBlock(self);
    }
    [self finishInteractiveTransition];
    [_context completeTransition:YES];
        [_context containerView].layer.speed=1;
    if (self.interactiveComplitionBlock) {
        
        self.interactiveComplitionBlock();
    }
}



- (void)_transitionFinishedCanceling {
    [_displayLink invalidate];
      _percent=0.0;
    if (self.interactiveUpdateBlock) {
            self.interactiveUpdateBlock(self);
    }

    [self cancelInteractiveTransition];
    [_context completeTransition:NO];
    [_context containerView].layer.speed=1;
    if (self.interactiveComplitionBlock) {
        self.interactiveComplitionBlock();
    }
}
- (void)updateCancelAnimation {
    NSTimeInterval timeOffset = [self timeOffset]-[_displayLink duration];
    if (timeOffset<= 0) {
           //  [self setTimeOffset:0];
        [self _transitionFinishedCanceling];
    } else {
   
        [self setTimeOffset:timeOffset];
    }
}

- (void)updateFinishAnimation {
    NSTimeInterval timeOffset = [self timeOffset]+[_displayLink duration];
    if (timeOffset >=self.animDuration) {
        //[self setTimeOffset:self.animDuration];
        [self _transactionFinishFinishing];
    } else {
        [self setTimeOffset:timeOffset];
    }
} 
-(void)animationEnded:(BOOL)transitionCompleted{
    
    

}
#pragma mark - transaction delegate
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
//    if (_context) {
//        ;
//  
//     UIViewController * vc1=   [_context viewControllerForKey:UITransitionContextToViewControllerKey];
//        UIViewController * vc2=    [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//        [vc2.view removeFromSuperview];
//        [[_context containerView].layer removeAllAnimations];
//        for (CALayer *l in [_context containerView].layer.sublayers)
//        {
//            [l removeAllAnimations];
//        }
//  
//       // [_context cancelInteractiveTransition];
//        
//       //[_context completeTransition:NO];
//    }
//
    _context=transitionContext;
    BOOL failed=YES;
    
    if (self.isInteractive) {
        _interactiveState=APDirectorInteractiveStateInProgress;
    }
    if (self.animBlock) {
        failed=NO;
        self.animBlock(self,^{
           
            
            if (!self.isInteractive) {
                    [transitionContext completeTransition:YES];
            }
       
        });
    }
    if (self.delegate) {
        failed=NO;
        [self.delegate animationTransition:self andComplitionBlock:^{
            [transitionContext finishInteractiveTransition];
            [transitionContext completeTransition:YES];
        }];
    }
    if (failed) {
        [transitionContext finishInteractiveTransition];
        [transitionContext completeTransition:YES];
    }
}
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if ([self.delegate respondsToSelector:@selector(animationDurationFor:)]) {
       _animDuration = [self.delegate animationDurationFor:self];
    }
    return _animDuration;
}
#pragma mark - navigation controller delegate
-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    _navigationOperation=operation;
    return self;
}


-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.isInteractive?self:nil;
}
#pragma mark - uitabbarController transaction

- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                              toViewController:(UIViewController *)toVC {
    return self;
}

-(id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
   return self.isInteractive?self:nil;
}

#pragma mark - uiviewcontroller transactioning delegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return self.isInteractive?self:nil;
}
- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
         return self.isInteractive?self:nil;
}
#pragma mark - fastAccess
-(UIView *)containerView{
    return [_context containerView];
}

-(UIView *)fromView{
    return [_context viewForKey:UITransitionContextFromViewKey];
}

-(UIView *)toView{
    return [_context viewForKey:UITransitionContextToViewKey];
}

-(UIViewController *)fromViewController{
    return [_context viewControllerForKey:UITransitionContextFromViewControllerKey];
}

-(UIViewController *)toViewController{
    return [_context viewControllerForKey:UITransitionContextToViewControllerKey];
}

#pragma mark - dealloc
-(void)dealloc{
    NSLog(@"DEALLOC: %@",self.description);
}



@end

