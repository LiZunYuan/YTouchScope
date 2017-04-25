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
    [self y_removeAspectToken];
    
    id<AspectToken> aspectToken = [self aspect_hookSelector:@selector(pointInside:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, CGPoint point){
        UIView *view = [aspectInfo instance];
        BOOL contain = CGRectContainsPoint(CGRectMake(-(scopeSize.width-view.frame.size.width)/2.0, -(scopeSize.height-view.frame.size.height)/2.0, scopeSize.width, scopeSize.height), point);
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation setReturnValue:&contain];
    } error:NULL];
    
    [self y_setAspectToken:aspectToken];
}

static char YTouchScopeAspectTokenKey;
- (void)y_setAspectToken:(id<AspectToken>)aspectToekn
{
    objc_setAssociatedObject(self, &YTouchScopeAspectTokenKey, aspectToekn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)y_removeAspectToken
{
    id<AspectToken> aspectToken = objc_getAssociatedObject(self, &YTouchScopeAspectTokenKey);
    if (aspectToken) {
        [aspectToken remove];
    }
}

@end
