//
//  ViewController.m
//  YKModalPopup
//
//  Created by zhangyuanke on 16/8/14.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "ViewController.h"
#import "YKModalPopupView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)popupViewTest:(id)sender {
    YKModalPopupView *tempView = [[YKModalPopupView alloc] init];
    [tempView show];
}

@end
