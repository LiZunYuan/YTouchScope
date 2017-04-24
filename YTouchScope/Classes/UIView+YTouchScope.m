//
//  UIView+TouchScope.m
//  Pods
//
//  Created by 李遵源 on 16/8/24.
//
//

#import "UIView+YTouchScope.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@implementation UIView (YTouchScope)

static char YTouchScopeViewsKey;
- (void)y_touchScopeSize:(CGSize)scopeSize
{
    if (!self.superview) {
        NSAssert(self.superview, @"需要将当前view添加到父view上");
        return;
    }
    
    __block NSMutableArray<NSDictionary *> *touchScopeViews = objc_getAssociatedObject(self.superview, &YTouchScopeViewsKey);
    if (touchScopeViews.count > 0) {
        [touchScopeViews addObject:@{@"view":self,@"scopeSize":[NSValue valueWithCGSize:scopeSize]}];
        return;
    }
    touchScopeViews = [NSMutableArray array];
    [touchScopeViews addObject:@{@"view":self,@"scopeSize":[NSValue valueWithCGSize:scopeSize]}];
    
    [self.superview aspect_hookSelector:@selector(hitTest:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, CGPoint point){
        void * r;
        __block NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        [invocation getReturnValue:&r];
        
        UIView *oriHitTestResult = (__bridge UIView *)(r);
        
        if (oriHitTestResult != [aspectInfo instance]) {
            return;
        }
        
        __block BOOL hasViewContain = NO;
        [touchScopeViews enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *view = dict[@"view"];
            if (view.hidden == YES ||view.userInteractionEnabled == NO) {
                return;
            }
            CGSize scopeSize = [dict[@"scopeSize"] CGSizeValue];
            BOOL contain = CGRectContainsPoint(CGRectMake(view.frame.origin.x - (scopeSize.width-view.frame.size.width)/2.0, view.frame.origin.y - (scopeSize.height-view.frame.size.height)/2.0, scopeSize.width, scopeSize.height), point);
            
            if (contain) {
                [invocation setReturnValue:&view];
                hasViewContain = YES;
                *stop = YES;
            }
        }];
    } error:NULL];
    
    objc_setAssociatedObject(self.superview, &YTouchScopeViewsKey, touchScopeViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
