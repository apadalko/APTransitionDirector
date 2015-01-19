//
//  BURootViewController.m
//  BasicUsage(APTransactionProtocol)-NavigationController
//
//  Created by Alex Padalko on 1/19/15.
//  Copyright (c) 2015 Alex Padalko. All rights reserved.
//
#import "APTransitionDirector.h"
#import "BURootViewController.h"
#import "BUViewController.h"
@interface BURootViewController ()<APTransitionProtocol>
{
    APTransitionDirector * director;
    
}
@end

@implementation BURootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        [self.view setBackgroundColor:[UIColor purpleColor]];
    
    UIButton * butPush=[UIButton buttonWithType:UIButtonTypeSystem];
    
    [butPush setBackgroundColor:[UIColor whiteColor]];
    
    [butPush setFrame:CGRectMake(0, 0, 120, 44)];
    [butPush addTarget:self action:@selector(pushVC) forControlEvents:UIControlEventTouchUpInside];
    [butPush setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [butPush setTitle:@"push" forState:UIControlStateNormal];
    [self.view addSubview:butPush];
    
    
    
    UIScreenEdgePanGestureRecognizer * panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(screenPan:)];
    panGesture.edges=UIRectEdgeLeft;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController.view addGestureRecognizer:panGesture];
    
    
    director=[[APTransitionDirector alloc] init];
    [director setDelegate:self];
    [self.navigationController setDelegate:director];
    
    // Do any additional setup after loading the view.
}
-(void)animationTransition:(APTransitionDirector *)transitionDirector andComplitionBlock:(void (^)())complitBlock{
    
    UIView* toView = [transitionDirector toView];
    UIView* fromView= [transitionDirector fromView];
    UIView *  containerView=  [transitionDirector containerView];

    toView.transform=CGAffineTransformMakeScale(1.0, 1.0);
    [toView setFrame:containerView.bounds];
    
    fromView.transform=CGAffineTransformMakeScale(1.0, 1.0);
    [fromView setFrame:containerView.bounds];
    
    if (transitionDirector.transitionOperation==APDirectorOperationPop) {
        [containerView insertSubview:toView belowSubview:fromView];
           toView.transform=CGAffineTransformMakeScale(0.9, 0.9);
        if (!director.interactive) {
            [UIView animateWithDuration:transitionDirector.animDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 [fromView setFrame:CGRectMake(fromView.frame.size.width, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height)];
                                 toView.transform=CGAffineTransformMakeScale(1.0, 1.0);
                             } completion:^(BOOL finished) {
                                   complitBlock();
                             }];
        }else{
        [ UIView animateWithDuration:transitionDirector.animDuration
                          animations:^{
                              
                              [fromView setFrame:CGRectMake(fromView.frame.size.width, fromView.frame.origin.y, fromView.frame.size.width, fromView.frame.size.height)];
                              toView.transform=CGAffineTransformMakeScale(1.0, 1.0);
                              
                          }completion:^(BOOL finished) {
                             complitBlock();
                              
                          }];
        }
        
    }else{
        
        
        [containerView insertSubview:toView aboveSubview:fromView];
                [toView setFrame:CGRectMake(containerView.frame.size.width, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height)];
     
        [UIView animateWithDuration:transitionDirector.animDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [toView setCenter:CGPointMake(containerView.frame.size.width/2, toView.center.y)];
                             fromView.transform=CGAffineTransformMakeScale(0.9, 0.9);
                         } completion:^(BOOL finished) {
                             fromView.transform=CGAffineTransformMakeScale(1.0, 1.0);
                             [fromView setFrame:containerView.bounds];
                             //dont forget to call the complition block
                             complitBlock();
                         }];
      

    }
    
    
}
-(void)pushVC{
    [self.navigationController pushViewController:[[BUViewController alloc] init] animated:YES];
    
}
- (void)screenPan:(UIGestureRecognizer*)pan {
    CGPoint location = [pan locationInView:self.view];
    static float fullDistance=0;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            
            fullDistance=self.navigationController.view.frame.size.width;
            director.interactive=YES;
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        case  UIGestureRecognizerStateChanged:
            {
                __weak typeof(self) selfRef=self;
                director.interactiveUpdateBlock=^(APTransitionDirector*animDirector){
                    UIView* fromView= [animDirector fromView];
                    [selfRef addMaskToView:fromView withPosition:location];
                };
                //update percent for every step
                [director setPercent:location.x/fullDistance];
                break;
            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
         
            BOOL didComplete=NO;
            if (pan.state==UIGestureRecognizerStateEnded){
                didComplete = (location.x/fullDistance)>0.5?YES:NO;
            }
            
            //and end interactive transition at state ended or canceled
            [director endInteractiveTranscation:didComplete complition:^(APTransitionDirector*animDirector){
               [director fromView].layer.mask=nil;
                   director.interactive=NO;
                
            }];
            break;
        }
        default: {
            
            break;
        }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    -(void)addMaskToView:(UIView*)view withPosition:(CGPoint)maskPosition{
        CAShapeLayer * maskLayer;
        if (!view.layer.mask) {
            maskLayer=[CAShapeLayer layer];
            view.layer.mask=maskLayer;
            maskLayer.fillRule=kCAFillRuleEvenOdd;
        }else{
            maskLayer=(CAShapeLayer*)view.layer.mask;
        }
        CGMutablePathRef path=CGPathCreateMutable();
        CGPathAddRect(path, nil, view.bounds);
        CGPathAddEllipseInRect(path, nil, CGRectMake(-28, maskPosition.y, 44, 44));
        maskLayer.path=path;
        CGPathRelease(path);
    }
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
