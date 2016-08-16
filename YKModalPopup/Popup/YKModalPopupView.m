//
//  YKModalPopupView.m
//  YKModalPopup
//
//  Created by zhangyuanke on 16/8/14.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "YKModalPopupView.h"
#import "YKModalPopup.h"

#define kYKModalPopupViewWidth 280.0f
#define kYKCommonColor [UIColor colorWithRed:250.0 / 255.0 green:103.0 / 255.0 blue:103.0 / 255.0 alpha:1];

@interface YKModalPopupView ()<UITextFieldDelegate, YKModalPopupDelegate>

@property (nonatomic, strong) UILabel       *userNameLabel;
@property (nonatomic, strong) UILabel       *passwordLabel;

@property (nonatomic, strong) UITextField   *userNameTextField;
@property (nonatomic, strong) UITextField   *passwordTextField;

@property (nonatomic, assign) CGFloat       frameHeight;
@property (nonatomic, assign) UIEdgeInsets  contentInsets;

@end

@implementation YKModalPopupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _contentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    _frameHeight = _contentInsets.top;
    _userNameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"用户名:";
        label.textColor = kYKCommonColor;
        label.frame = CGRectMake(_contentInsets.left, _frameHeight, 60, 44);
        label;
    });
    [self addSubview:_userNameLabel];
    
    _userNameTextField = ({
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @"请输入邮箱";
        textField.tintColor = kYKCommonColor;
        textField.frame = CGRectMake(80, _frameHeight, kYKModalPopupViewWidth - _contentInsets.right - 80, 44);
        textField;
    });
    [self addSubview:_userNameTextField];
    _frameHeight += 44;
    
    _passwordLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"密    码:";
        label.textColor = kYKCommonColor;
        label.frame = CGRectMake(_contentInsets.left, _frameHeight, 60, 44);
        label;
    });
    [self addSubview:_passwordLabel];
    
    _passwordTextField = ({
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @"请输入密码";
        textField.tintColor = kYKCommonColor;
        textField.frame = CGRectMake(80, _frameHeight, kYKModalPopupViewWidth - _contentInsets.right - 80, 44);
        textField;
    });
    [self addSubview:_passwordTextField];
    _frameHeight += 44;
    _frameHeight += _contentInsets.bottom;
    
    self.layer.cornerRadius = 6.0;
    self.clipsToBounds = YES;
}

/**
 *  显示当前对话框
 */
- (void)show
{
    [YKModalPopup showWithCustomView:self delegate:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self doLayout];
}

/**
 *  自定义View要实现的方法
 */
- (void)doLayout
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect winFrame = window.bounds;
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake((winFrame.size.width - kYKModalPopupViewWidth) / 2.0, (winFrame.size.height - _frameHeight) / 2.0, kYKModalPopupViewWidth, _frameHeight);
}

#pragma mark - YKModalPopupDelegate
/**
 *  模态对话框背景被点击后的代理回调
 */
- (void)modalPopupBackgroundBeTouched
{
//    [YKModalPopup dismiss];
}

#pragma mark - UITextFieldDelegate

@end
