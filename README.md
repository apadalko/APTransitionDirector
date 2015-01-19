# APTransitionDirector
APTransitionDirector

# Example Usage
You could use director in one of this ways

* Basical Usage (for interactive and staic trasitions)
* category (APTransitions) & APTransitionProtocol (for static transitions)
* category (APTransitions) & blocks (for static transitions) - not implemented yet
* category (APRuleInteractiveTransitions) & APTransitionRule (for interactive transitions)
* category (APInteractiveTransitions) (for interactive transitions, the same as pervious but faster to implement) - not inplemented yet
 and more...


## Basical Usage

The main class is APTransitionDirector - its responds of all trasition protocols that iOS have:
``` objective-c
<UIViewControllerAnimatedTransitioning,UINavigationControllerDelegate,UIViewControllerInteractiveTransitioning,UITabBarControllerDelegate,UIViewControllerTransitioningDelegate>
```
its super fast to create u own transition, even with basical usage(see the category usage below):
``` objective-c
APTransitionDirector * director=[[APTransitionDirector alloc]init];
director.animBlock=^(APTransitionDirector * director ,void(^comlitBlock)() ){

};
self.navigationController.delegate=director;
[self.navigationController pushViewController:viewController animated:YES]
self.navigationController.delegate=nil;
```
Now you have the animation block ,where u could use any animations that u want,to get all needed view use the
APFastAcces category of APTransitionDirector.Lets Add Some Cool Animations:

``` objective-c
APTransitionDirector * director=[[APTransitionDirector alloc]init];
director.animBlock=^(APTransitionDirector * director ,void(^comlitBlock)() ){
    //getting all needed views
    UIView* toView = [director toView];
    UIView* fromView= [director fromView];
    UIView *  containerView=  [director containerView];
   //presetup
    [containerView insertSubview:toView aboveSubview:fromView];
    [toView setFrame:CGRectMake(containerView.frame.size.width, toView.frame.origin.y, toView.frame.size.width, toView.frame.size.height)];
    fromView.transform=CGAffineTransformMakeScale(1.0, 1.0);
    //animation block
    [UIView animateWithDuration:director.animDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn
    animations:^{
        [toView setCenter:CGPointMake(containerView.frame.size.width/2, toView.center.y)];
        fromView.transform=CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            fromView.transform=CGAffineTransformMakeScale(1.0, 1.0);
  //dont forget to call the complition block
            comlitBlock();
    }];

};
self.navigationController.delegate=director;
[self.navigationController pushViewController:viewController animated:YES]
self.navigationController.delegate=nil;
```
Pls note: When u use non interactive animations dont forget to call the complitBlock
