//
//  YKModalPopup.m
//  YKModalPopup
//
//  Created by zhangyuanke on 16/8/14.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "YKModalPopup.h"

static YKModalPopup                     *kYKModelPopupInstance;             // 当前模态对话框的实例
static UITapGestureRecognizer           *kYKBackgroundSingleTapGesture;     // 模态对话框背景点击手势
static UIView                           *kYKCustomBackgroundView;           // 自定义模态对话框的背景View
static UIView                           *kYKCustomView;                     // 用户要显示的自定义View

/**
 *  模态对话框
 */
@interface YKModalPopup ()
{
    NSMutableDictionary *_kbHeightDic;
}
@property (nonatomic, weak) id<YKModalPopupDelegate>    delegate;

@end

@implementation YKModalPopup

/**
 *  当前实例
 */
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

/**
 *  在模态对话框上显示自定义的view
 *
 *  @param customView 自定义View，要实现doLayout方法，在方法中指定customView的frame（相对于整个屏幕的frame）
 *  @param delegate   模态对话框代理
 */
+ (void)showWithCustomView:(UIView *)customView delegate:(id<YKModalPopupDelegate>)delegate
{
    [self showWithCustomView:customView delegate:delegate forced:NO];
}

/**
 *  在模态对话框上显示自定义的view
 *
 *  @param customView 自定义View，要实现doLayout方法，在方法中指定customView的frame（相对于整个屏幕的frame）
 *  @param delegate   模态对话框代理
 *  @param forced     是否强制显示当前customView，默认情况下只显示一个模态对话框
 */
+ (void)showWithCustomView:(UIView *)customView delegate:(id<YKModalPopupDelegate>)delegate forced:(BOOL)forced
{
    if (!customView || ![customView isKindOfClass:[UIView class]]) {
        return;
    }
    if (!forced && kYKModelPopupInstance) {
        return;
    }
    if (forced && kYKModelPopupInstance) {
        if (kYKModelPopupInstance) {
            [YKModalPopup removed];
        }
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    kYKModelPopupInstance = [[YKModalPopup alloc] init];
    kYKModelPopupInstance.delegate = delegate;
    kYKCustomBackgroundView = [[UIView alloc] initWithFrame:window.bounds];
    kYKCustomBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    kYKBackgroundSingleTapGesture = [[UITapGestureRecognizer alloc]
                                     initWithTarget:kYKModelPopupInstance
                                     action:@selector(handleCustomBackgroundTouched:)];
    [kYKCustomBackgroundView addGestureRecognizer:kYKBackgroundSingleTapGesture];
    kYKCustomView = customView;
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([kYKCustomView respondsToSelector:@selector(doLayout)]) {
        [kYKCustomView performSelector:@selector(doLayout)];
    }
    #pragma clang diagnostic pop
    
    [window addSubview:kYKCustomBackgroundView];
    [window addSubview:kYKCustomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:kYKModelPopupInstance
                                             selector:@selector(_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:kYKModelPopupInstance
                                             selector:@selector(_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:kYKModelPopupInstance
                                             selector:@selector(_deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

/**
 *  销毁当前模态对话框
 */
+ (void)dismiss
{
    [self removed];
}

#pragma mark - private method

- (instancetype)init
{
    self = [super init];
    if (self) {
        _kbHeightDic = [NSMutableDictionary dictionary];
    }
    return self;
}

// 移除当前自定义模态对话框
+ (void)removed
{
    if (kYKCustomBackgroundView && kYKBackgroundSingleTapGesture) {
        [kYKCustomBackgroundView removeGestureRecognizer:kYKBackgroundSingleTapGesture];
        kYKBackgroundSingleTapGesture = nil;
    }
    if (kYKCustomBackgroundView) {
        [kYKCustomBackgroundView removeFromSuperview];
        kYKCustomBackgroundView = nil;
    }
    if (kYKCustomView) {
        [kYKCustomView removeFromSuperview];
        kYKCustomView = nil;
    }
    if (kYKModelPopupInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:kYKModelPopupInstance
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:kYKModelPopupInstance
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:kYKModelPopupInstance
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
        kYKModelPopupInstance = nil;
    }
}

#pragma mark - keyboard

- (void)_keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (kbSize.height > 0) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        NSString *kbSizeString = [NSString stringWithFormat:@"%.0lf", kbSize.height];
        // 解决调用两次_keyboardWillShow问题
        if ([_kbHeightDic objectForKey:kbSizeString]) {
            NSString *tempString = [_kbHeightDic objectForKey:kbSizeString];
            CGFloat winHeightTemp = tempString.floatValue;
            if (fabs(winHeightTemp - window.bounds.size.height) > 0.01) {
                return;
            }
        }
        [_kbHeightDic setObject:[NSString stringWithFormat:@"%.0lf", window.bounds.size.height] forKey:kbSizeString];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([kYKCustomView respondsToSelector:@selector(doLayout)]) {
            [kYKCustomView performSelector:@selector(doLayout)];
        }
#pragma clang diagnostic pop
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect fr = kYKCustomView.frame;
        fr.origin.y = kYKCustomView.frame.origin.y - kbSize.height / 2.0;
        if (fr.origin.y < 0) {
            fr.origin.y = 0;
        }
        kYKCustomView.frame = fr;
        [UIView commitAnimations];
    }
}

- (void)_keyboardWillHide:(NSNotification *)notification
{
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([kYKCustomView respondsToSelector:@selector(doLayout)]) {
                [kYKCustomView performSelector:@selector(doLayout)];
            }
#pragma clang diagnostic pop
        }];
}

- (void)_deviceOrientationDidChange:(NSNotification *)notification
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.25 animations:^{
        kYKCustomBackgroundView.frame = window.bounds;
    }];
}

#pragma mark - YKModalPopupDelegate

- (void)handleCustomBackgroundTouched:(UIGestureRecognizer *)gesture
{
    // 点击模态对话框背景view退出键盘，回调代理方法
    [kYKCustomView endEditing:YES];
    if (kYKModelPopupInstance && kYKModelPopupInstance.delegate && [kYKModelPopupInstance.delegate respondsToSelector:@selector(modalPopupBackgroundBeTouched)]) {
        [kYKModelPopupInstance.delegate modalPopupBackgroundBeTouched];
    }
}

@end
