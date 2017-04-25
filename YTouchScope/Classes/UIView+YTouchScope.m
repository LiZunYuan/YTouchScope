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

- (void)y_touchScopeSize:(CGSize)size
{
    [self y_touchScopeSize:size showDebugView:NO];
}

static char YTouchScopeViewsKey;
- (void)y_touchScopeSize:(CGSize)scopeSize showDebugView:(BOOL)showDebugView
{
    if (showDebugView) {
        [self aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo){
            static char YTouchScopeViewDebugViewKey;
            
            UIView *beforeView = objc_getAssociatedObject(self, &YTouchScopeViewDebugViewKey);
            [beforeView removeFromSuperview];
            
            UIView *nowView = [aspectInfo instance];
            UIView *v = [UIView new];
            [v setFrame:CGRectMake(-(scopeSize.width-self.frame.size.width)/2.0, -(scopeSize.height-self.frame.size.height)/2.0, scopeSize.width, scopeSize.height)];
            [v setUserInteractionEnabled:NO];
            
            [nowView.superview setClipsToBounds:YES];
            
            [nowView addSubview:v];
            [nowView setClipsToBounds:NO];
            
            
            [v setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
            
            objc_setAssociatedObject(self, &YTouchScopeViewDebugViewKey, v, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
        } error:NULL];
    }
    
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
