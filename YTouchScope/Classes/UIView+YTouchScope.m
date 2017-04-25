//
//  UIView+TouchScope.m
//  Pods
//
//  Created by 李遵源 on 16/8/24.
//
//

#import "UIView+YTouchScope.h"
#import <Aspects/Aspects.h>

@implementation UIView (YTouchScope)

static char YTouchScopeViewsKey;
- (void)y_touchScopeSize:(CGSize)scopeSize
{
    [self aspect_hookSelector:@selector(pointInside:withEvent:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, CGPoint point){
        UIView *view = [aspectInfo instance];
        BOOL contain = CGRectContainsPoint(CGRectMake(-(scopeSize.width-view.frame.size.width)/2.0, -(scopeSize.height-view.frame.size.height)/2.0, scopeSize.width, scopeSize.height), point);
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation setReturnValue:&contain];
    } error:NULL];
}

@end
