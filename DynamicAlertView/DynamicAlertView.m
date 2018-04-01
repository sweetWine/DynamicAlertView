//
//  DynamicAlertView.m
//  MagicalWish
//
//  Created by sweetwine on 2017/6/28.
//  Copyright © 2017年 sweetwine. All rights reserved.
//

#import "DynamicAlertView.h"

#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height
#define frameScale              kScreenWidth/375.0
#define BaseTag                 170628

// !!!: 设置alertView的宽和高
#define alertViewWidth          300.0*frameScale
#define alertViewHeight         185.0*frameScale
#define btnItemHeight           40

@interface DynamicAlertView ()
{
    UIView *_clickView;
    UIControl *_bgCoverMaskView;
}
@property (nonatomic, copy)void(^selectBlock)(NSInteger);
@property (nonatomic, strong)UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation DynamicAlertView

- (void)dealloc
{
    NSLog(@"DynamicAlertView did dealloc");
}

// !!!: 初始化
static DynamicAlertView *alertView = nil;
+ (instancetype)instanceAlertView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        alertView = [[DynamicAlertView alloc] init];
#pragma clang diagnostic pop
    });
    return alertView;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake((kScreenWidth - alertViewWidth)/2, -alertViewHeight, alertViewWidth, alertViewHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        // 切圆角
        if (self.layer.cornerRadius != 8) {
            self.layer.cornerRadius = 8.0f;
            self.layer.masksToBounds = YES;
            self.layer.borderColor = [UIColor grayColor].CGColor;
            self.layer.borderWidth = .5f;
        }
    }
    return self;
}

/**
 通过此实例方法设置布局以及显示alertView

 @param description  alertView的提示
 @param blcok        点击按钮后的block回调
 @param title        按钮的标题，注意末尾需添加nil
 */
- (void)showAlertViewWithDescription:(NSString *)description withAction:(void(^)(NSInteger))blcok WithTitles:(NSString *)title, ...
{
    // 收集titles
    va_list args;
    va_start(args, title);
    NSMutableArray *titlesArray = [NSMutableArray array];

    for (NSString *str = title; str != nil; str = va_arg(args,NSString*)) {
        [titlesArray addObject:str];
    }
    
    // 根据title的个数确定UI样式
    [self configureUIWithDescription:description withTitles:titlesArray];
    
    // 将点击按钮的index传出去
    self.selectBlock = blcok;
    
    // 显示alertView
    [self showAlertView];
}

/**
 !!!: UI样式以及点击事件处理
 
 根据title的个数确定UI的样式

 @param description  alertView的提示
 @param titles       按钮的标题
 */
- (void)configureUIWithDescription:(NSString *)description withTitles:(NSArray *)titles
{
    [self addSubview:self.titleLabel];
    self.titleLabel.text = description;
    [self addSubview:[self creatClickViewWithTitles:titles]];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10*frameScale, 10*frameScale, alertViewWidth - 20*frameScale, alertViewHeight - (20 + btnItemHeight)*frameScale)];
        _titleLabel.font = [UIFont systemFontOfSize:17.0*frameScale];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)creatClickViewWithTitles:(NSArray *)titles
{
    if (!_clickView) {
        _clickView = [[UIView alloc] init];
    }else {
        NSMutableArray *btnTitles = [NSMutableArray array];
        for (UIView *subView in _clickView.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)subView;
                [btnTitles addObject:btn.titleLabel.text];
            }
        }
        if (![btnTitles isEqualToArray:titles]) {
            _clickView = [[UIView alloc] init];
        }else {
            return _clickView;
        }
    }
    
    if (titles.count == 2) {
        _clickView.frame = CGRectMake(0, alertViewHeight - btnItemHeight*frameScale, alertViewWidth, btnItemHeight*frameScale);
        for (int i = 0; i < 2; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(alertViewWidth / 2 * i, 0, alertViewWidth / 2, btnItemHeight*frameScale);
            btn.tag = BaseTag + i;
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14 * frameScale];
            [btn addTarget:self action:@selector(selectIndexButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_clickView addSubview:btn];
            btn.layer.borderColor = [UIColor grayColor].CGColor;
            btn.layer.borderWidth = .5f;
        }
    } else {
        _clickView.frame = CGRectMake(0, alertViewHeight - btnItemHeight*frameScale, alertViewWidth, btnItemHeight*titles.count*frameScale);
        CGRect rect = self.frame;
        rect.size.height = alertViewHeight + _clickView.frame.size.height - btnItemHeight*frameScale;
        self.frame = rect;
        for (int i = 0; i < titles.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, btnItemHeight*i*frameScale, alertViewWidth, btnItemHeight*frameScale);
            btn.tag = BaseTag + i;
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14 * frameScale];
            [btn addTarget:self action:@selector(selectIndexButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_clickView addSubview:btn];
            btn.layer.borderColor = [UIColor grayColor].CGColor;
            btn.layer.borderWidth = .5f;
        }
    }
    return _clickView;
}

// 按钮点击事件
- (void)selectIndexButtonAction:(UIButton *)btn
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.selectBlock(btn.tag - BaseTag);
    });
    [self hiddenAlertView];
}

// !!!: 显示 & 关闭 alertView
- (void)showAlertView
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (!_bgCoverMaskView) {
        _bgCoverMaskView = [[UIControl alloc] initWithFrame:window.bounds];
        _bgCoverMaskView.backgroundColor = [UIColor colorWithWhite:.3 alpha:.5];
        [_bgCoverMaskView addTarget:self action:@selector(coverMaskViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [window addSubview:_bgCoverMaskView];
    [window addSubview:self];
    
    switch (self.showStyle) {
        case DynamicAlertViewShowStyleSnap:
            {
                if (!_dynamicAnimator) {
                    self.center = CGPointMake(kScreenWidth/2, -alertViewHeight);
                    self.alpha = 1;
                    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:window];
                    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:self snapToPoint:window.center];
                    snapBehavior.damping = 0.5;
                    [_dynamicAnimator addBehavior:snapBehavior];
                }
            }
            break;
        case DynamicAlertViewShowStyleAppear:
            {
                self.center = window.center;
                self.transform = CGAffineTransformMakeScale(0.7, 0.7);
                self.alpha = 0;
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:.35 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.5 options:0 animations:^{
                    weakSelf.alpha = 1;
                    weakSelf.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    if (finished) {
                        
                    }
                }];
            }
            break;
            
        default:
            break;
    }
}

- (void)coverMaskViewAction
{
    [self hiddenAlertView];
}

- (void)hiddenAlertView
{
    [self endEditing:YES];
    
    switch (self.showStyle) {
        case DynamicAlertViewShowStyleSnap:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UISnapBehavior *snapBehavior = _dynamicAnimator.behaviors.lastObject;
                snapBehavior.snapPoint = CGPointMake(kScreenWidth/2, kScreenHeight + alertViewHeight);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    __strong typeof(self) strongSelf = weakSelf;
                    [strongSelf->_dynamicAnimator removeAllBehaviors];
                    strongSelf->_dynamicAnimator = nil;
                    [strongSelf->_bgCoverMaskView removeFromSuperview];
                    strongSelf->_bgCoverMaskView = nil;
                    weakSelf.center = CGPointMake(kScreenWidth/2, -alertViewHeight);
                    [weakSelf removeFromSuperview];
                });
            });
        }
            break;
        case DynamicAlertViewShowStyleAppear:
        {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.35 animations:^{
                    weakSelf.alpha = 0;
                    weakSelf.transform = CGAffineTransformMakeScale(.7, .7);
                } completion:^(BOOL finished) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if (finished) {
                        [strongSelf->_bgCoverMaskView removeFromSuperview];
                        strongSelf->_bgCoverMaskView = nil;
                        weakSelf.transform = CGAffineTransformIdentity;
                        [weakSelf removeFromSuperview];
                    }
                }];
            });
        }
            break;
            
        default:
            break;
    }
}


@end
