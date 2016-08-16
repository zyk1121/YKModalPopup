//
//  YKModalPopup.h
//  YKModalPopup
//
//  Created by zhangyuanke on 16/8/14.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  模态对话框代理
 */
@protocol YKModalPopupDelegate <NSObject>

@optional
/**
 *  模态对话框背景被点击后的代理回调
 */
- (void)modalPopupBackgroundBeTouched;

@end

/**
 *  模态对话框
 */
@interface YKModalPopup : NSObject
/**
 *  当前实例
 */
+ (instancetype)sharedInstance;

/**
 *  在模态对话框上显示自定义的view
 *
 *  @param customView 自定义View，要实现doLayout方法，在方法中指定customView的frame（相对于整个屏幕的frame）
 *  @param delegate   模态对话框代理
 */
+ (void)showWithCustomView:(UIView *)customView delegate:(id<YKModalPopupDelegate>)delegate;
/**
 *  在模态对话框上显示自定义的view
 *
 *  @param customView 自定义View，要实现doLayout方法，在方法中指定customView的frame（相对于整个屏幕的frame）
 *  @param delegate   模态对话框代理
 *  @param forced     是否强制显示当前customView，默认情况下只显示一个模态对话框
 */
+ (void)showWithCustomView:(UIView *)customView delegate:(id<YKModalPopupDelegate>)delegate forced:(BOOL)forced;

/**
 *  销毁当前模态对话框
 */
+ (void)dismiss;

@end
