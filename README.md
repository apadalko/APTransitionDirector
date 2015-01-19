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