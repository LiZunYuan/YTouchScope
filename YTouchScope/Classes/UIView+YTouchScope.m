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

- (void)y_touchScopeSize:(CGSize)scopeSize
{
    [self y_handleWillMoveToSuperview];
    
    if (self.superview) {
        [self.superview y_addTouchScopeViews:self scopeSize:CGSizeMake(75, 75)];
        [self.superview y_handleHitTest];
    }
}

- (void)y_handleWillMoveToSuperview
{
    [self aspect_hookSelector:@selector(willMoveToSuperview:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, UIView *superView){
        UIView *view = [aspectInfo instance];
        if (view.superview) {
            [[view.superview y_aspectToken] remove];
        }
        
        [superView y_addTouchScopeViews:view scopeSize:CGSizeMake(75, 75)];
        [superView y_handleHitTest];
        
    } error:NULL];
}

- (void)y_handleHitTest
{
    [self aspect_hookSelector:@selector(hitTest:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, CGPoint point){
        void * r;
        __block NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        [invocation getReturnValue:&r];
        UIView *oriHitTestResult = (__bridge UIView *)(r);
        
        if (oriHitTestResult != [aspectInfo instance]) {
            return;
        }
        
        __block NSMutableArray<NSDictionary *> *touchScopeViews = [[aspectInfo instance] y_touchScopeViwes];
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
}

#pragma set get
static char YTouchScopeViewsKey;
- (NSMutableArray<NSDictionary *> *)y_touchScopeViwes
{
    __block NSMutableArray<NSDictionary *> *touchScopeViews = objc_getAssociatedObject(self, &YTouchScopeViewsKey);
    if (touchScopeViews == nil) {
        touchScopeViews = [NSMutableArray array];
    }
    return touchScopeViews;
}

- (void)y_addTouchScopeViews:(UIView *)view scopeSize:(CGSize)scopeSize;
{
    NSMutableArray<NSDictionary *> *touchScopeViews = [self y_touchScopeViwes];
    [touchScopeViews addObject:@{@"view":view,@"scopeSize":[NSValue valueWithCGSize:scopeSize]}];
    
    objc_setAssociatedObject(self, &YTouchScopeViewsKey, touchScopeViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)y_removeTouchScopeViews:(UIView *)view;
{
    __block UIView *wantRemoveObj;
    [[self y_touchScopeViwes] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj[@"view"] == view) {
            wantRemoveObj = obj;
            *stop = YES;
        }
    }];
    [[self y_touchScopeViwes] removeObject:wantRemoveObj];
}


static char YTouchScopeAspectTokenKey;
- (void)y_setAspectToken:(id<AspectToken>)aspectToekn
{
    objc_setAssociatedObject(self, &YTouchScopeAspectTokenKey, aspectToekn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AspectToken>)y_aspectToken
{
    return objc_getAssociatedObject(self, &YTouchScopeAspectTokenKey);
}

@end
