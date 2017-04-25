//
//  YViewController.m
//  YTouchScope
//
//  Created by LiZunYuan on 04/24/2017.
//  Copyright (c) 2017 LiZunYuan. All rights reserved.
//

#import "YViewController.h"
#import "UIView+YTouchScope.h"

@interface YViewController ()

@end

@implementation YViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(25, 25, 50, 50)];
    [btn y_touchScopeSize:CGSizeMake(75, 75)];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor grayColor]];
    [btn addTarget:self action:@selector(print123) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *bbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bbtn setFrame:CGRectMake(100, 25, 50, 50)];
    [bbtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:bbtn];
    [bbtn y_touchScopeSize:CGSizeMake(75, 75);
    [bbtn addTarget:self action:@selector(print456) forControlEvents:UIControlEventTouchUpInside];
    
 
    
    
    UIImageView *iv = [UIImageView new];
    [iv setBackgroundColor:[UIColor whiteColor]];
    [btn addSubview:iv];
    [iv setFrame:CGRectMake(0, 0, 40, 40)];
    [iv setUserInteractionEnabled:YES];
    
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [b2 y_touchScopeSize:CGSizeMake(40, 40)];
    [b2 setBackgroundColor:[UIColor redColor]];
    [b2 setFrame:CGRectMake(0, 0, 20, 20)];
    [iv addSubview:b2];
    [b2 addTarget:self action:@selector(printb2) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)print123
{
    NSLog(@"123");
}

- (void)print456
{
    NSLog(@"456");
}

- (void)printb2
{
    NSLog(@"b2");
}
@end
