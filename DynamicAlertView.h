//
//  DynamicAlertView.h
//  MagicalWish
//
//  Created by sweetwine on 2017/6/28.
//  Copyright © 2017年 sweetwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DynamicAlertViewShowStyle) {
    DynamicAlertViewShowStyleAppear,
    DynamicAlertViewShowStyleSnap,
};

@interface DynamicAlertView : UIView

// 容错处理，提醒开发人员不适用此初始化方法
- (instancetype)init  DEPRECATED_MSG_ATTRIBUTE("请使用单例方法 instanceAlertView");
- (instancetype)initWithFrame:(CGRect)frame  DEPRECATED_MSG_ATTRIBUTE("请使用单例方法 instanceAlertView");

/**
 * 显示方式
 */
@property (nonatomic, assign)DynamicAlertViewShowStyle showStyle;

/**
 * 初始化方法
 */
+ (instancetype)instanceAlertView;

/**
 通过此实例方法设置布局以及显示alertView
 @param description   alertView的提示
 @param blcok         点击按钮后的block回调
 @param title         按钮的标题，注意末尾需添加nil
 */
- (void)showAlertViewWithDescription:(NSString *)description withAction:(void(^)(NSInteger))blcok WithTitles:(NSString *)title, ...NS_REQUIRES_NIL_TERMINATION;

- (void)hiddenAlertView;

@end
