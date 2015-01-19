//
//  APTransitionDirector.h
//  APTransitionDirector
//
//  Created by Alex Padalko on 01/10/15.
//  Copyright (c) 2014 Alex Padalko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class APTransitionDirector;
typedef void(^UpdateBlock)(APTransitionDirector * transactionDirector);
typedef void(^AnimationBlock)(APTransitionDirector * transactionDirector,void (^complitBlock)());
typedef void(^InteractiveComplitionBlock)(APTransitionDirector * transactionDirector);
enum APGestureType {
    APGestureTypeNone,
    APGestureTypePan,
    APGestureTypeEdgePan,
    APGestureTypePinch,
    APGestureTypeRotation
    
};
Class gestureClassForType(enum APGestureType type);
enum APGestureType typeFromGesture(UIGestureRecognizer*gesture);

@interface APTransitionRule : NSObject
//blocks define
typedef void (^ActionBlock)();
typedef ActionBlock (^ActionBlockForValue)(float value,BOOL initial);

//typedef void (^SetupBlock)(float duration,float percentToComplite);
//typedef void (^SetupCallBlock)(SetupBlock setupBlock);

typedef void (^ValueBlock)(float value,float maxValue);
typedef void (^ValueCallBlock)(UIGestureRecognizer * gesture,CGPoint firstTouch,ValueBlock valueBlock);


@property (nonatomic,readonly)enum APGestureType gestureType;
@property (nonatomic)float duration;
@property (nonatomic)float percentToComplite;
//blocks prop
@property (copy) ActionBlockForValue actionBlockForValue;
@property (copy) void (^setupGestureBlock) (UIGestureRecognizer * gesture);
@property (copy) BOOL (^gestureShouldBeginBlock)(UIGestureRecognizer * gesture);
@property (copy)  ValueCallBlock  valueCallBlock;
//@property (copy) SetupCallBlock setupCallBlock;

+(instancetype)ruleWithGesture:(enum APGestureType)gestureType;

-(instancetype)setDuration:(float)duration andComplitPercent:(float)percentToComplite;
//block methods
-(instancetype)setupGesture:(void(^)(UIGestureRecognizer*gesture))setupGestureBlock;
//-(instancetype)setupBlock:(SetupCallBlock)setupBlock;
-(instancetype)valueCalculationBlock:( ValueCallBlock )valueCalculationBlock;
-(instancetype)actionBlockForValue:( ActionBlockForValue )valueBlock;
-(instancetype)gestureShouldBeginBlock:( BOOL (^)(UIGestureRecognizer *gesture) )gestureShouldBegin;

@end







#pragma mark - APTransitionProtocol
//You will need this protocol in case that u will use APTransitions categories or just using delegate as for controll
@protocol  APTransitionProtocol <NSObject>
@required

/**
 * animation block.Use AAPTransitionDirector (APFastAcces) to get all needed views. NOTE: if you use it for animation without interactive !!YOU MUST RUN!! complitBlock at end.
 *
 */
-(void)animationTransition:(APTransitionDirector*) transitionDirector andComplitionBlock:(void(^)())complitBlock;
@optional
-(void)animationInteractiveTransition:(APTransitionDirector*) transitionDirector  withPercentComplite:(float)percentComplite;
-(CGFloat)percentToCompliteInteractiveTransitionFor:(APTransitionDirector*)transitionDirector; // if not implemented return 0.5;
/**
 * NOTE! IMPlementation of this method would be the main value for duration
 *
 */
-(CGFloat)animationDurationFor:(APTransitionDirector*)transitionDirector;

@end
#pragma mark - APTransitions Categorys

#pragma mark  UIViewController
@interface UIViewController(APTransitions)
/**
 * simple dismiss, sender(UIViewController) will be asked for conform APTransitionProtocol
 *
 */
-(void)APTransactionPresentViewController:(UIViewController*)viewController;
-(void)APTransactionPresentViewController:(UIViewController*)viewController withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol;
/**
 * simple dismiss, sender(UIViewController) will be asked for conform APTransitionProtocol
 *
 */
-(void)APTransactionDismissViewController;
-(void)APTransactionDismissViewControllerWithTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol;
@end

#pragma mark  UINavigationController
@interface UINavigationController(APTransitions)
/**
 * simple push, sender(UINavigationController) will be asked for conform APTransitionProtocol
 *
 */
-(void)APTransactionPushViewController:(UIViewController*)viewController;
-(void)APTransactionPushViewController:(UIViewController*)viewController withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol;
/**
 * simple pop, sender(UINavigationController) will be asked for conform APTransitionProtocol
 *
 */
-(UIViewController*)APTransactionPopViewController;
-(UIViewController*)APTransactionPopViewControllerWithTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol;
@end

#pragma mark  UITabBarController

@interface UITabBarController (APTransitions)
/**
 * simple switch to index, sender(UITabBarController) will be asked for conform APTransitionProtocol
 *
 */
-(void)APTransactionSelectIndex:(NSUInteger)idx;
-(void)APTransactionSelectIndex:(NSUInteger)idx withTransitionProtocol:(id<APTransitionProtocol>)transitionProtocol;

@end

#pragma mark -
#pragma mark - APRuleInteractiveTransitions Categorys
@interface UIViewController (APRuleInteractiveTransitions)
-(void)registerInteractiveTransactionWithRule:(APTransitionRule*)rule withAnimationBlockForValueAndGesture:(AnimationBlock (^)(float value,UIGestureRecognizer*gesture))animationBlockForValue;

-(void)registerInteractiveTransactionWithRule:(APTransitionRule*)rule withAnimationBlockForValueAndGesture:(AnimationBlock (^)(float value,UIGestureRecognizer*gesture))animationBlockForValue andUpdateBlockForValueAndGesture:(void (^)(APTransitionDirector * director, float value,UIGestureRecognizer * gesture))updateBlockForValue;
@end
#pragma mark -

#pragma mark - APInteractiveTransitions Categorys
@interface UIViewController (APInteractiveTransitions)
#warning not ready yet
-(APTransitionRule*)registerDissmisInteractiveTrasactionWithGesture:(enum APGestureType)gesture;


@end
#pragma mark -

#pragma mark - AAPTransitionDirector


enum APDirectorInteractiveState{
    
    APDirectorInteractiveStateNone,
    APDirectorInteractiveStateInProgress,
    APDirectorInteractiveStateCanceling,
    APDirectorInteractiveStateFinishing
    
};


@interface APTransitionDirector : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning,UINavigationControllerDelegate,UIViewControllerInteractiveTransitioning,UITabBarControllerDelegate,UIViewControllerTransitioningDelegate>

@property (assign,nonatomic)id<APTransitionProtocol> delegate;
/**
 * animation block.Use AAPTransitionDirector (APFastAcces) to get all needed views. NOTE: if you use it for animation without interactive !!YOU MUST RUN!! complitBlock at end.
 *
 */
@property (copy)AnimationBlock animBlock;

/**
 * interactive update block.Use transactionContext to get all needed views.updating after percent changing
 *
 */
@property (copy)UpdateBlock interactiveUpdateBlock;
@property (copy)InteractiveComplitionBlock interactiveComplitionBlock;
@property (nonatomic)float animDuration;
/**
 * only for navigation controller;
 *
 */
@property (nonatomic,readonly)UINavigationControllerOperation navigationOperation ;
/**
 * used to detect if the transition is interactive, default = NO
 *
 */
@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
/**
 * used to detect the interactive state from enum APDirectorInteractiveState
 *
 */
@property (nonatomic,readonly)enum APDirectorInteractiveState interactiveState;

-(void)fastCancel;
/**
 * run to end interactive transaction
 *
 */
-(void)endInteractiveTranscation:(BOOL)didComplete complition:(void (^)(APTransitionDirector * director))complitBlock ;

@property (nonatomic)CFTimeInterval timeOffset;


@property (nonatomic)float percent;
@end


@interface APTransitionDirector (APFastAcces)
-(UIView*)fromView;
-(UIView*)toView;
-(UIViewController*)fromViewController;
-(UIViewController*)toViewController;
-(UIView*)containerView;
@end


