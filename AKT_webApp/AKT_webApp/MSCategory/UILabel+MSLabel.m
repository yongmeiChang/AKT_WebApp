//
//  UILabel+MSLabel.m
//  MisaBaseDemo
//
//  Created by stone on 2018/10/23.
//  Copyright © 2018年 Misa. All rights reserved.
//

#import "UILabel+MSLabel.h"
#import <objc/runtime.h>

/// 获取UIEdgeInsets在水平方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets) {
    return insets.left + insets.right;
}

/// 获取UIEdgeInsets在垂直方向上的值
CG_INLINE CGFloat
UIEdgeInsetsGetVerticalValue(UIEdgeInsets insets) {
    return insets.top + insets.bottom;
}

CG_INLINE void
ReplaceMethod(Class _class, SEL _originSelector, SEL _newSelector) {
    Method oriMethod = class_getInstanceMethod(_class, _originSelector);
    Method newMethod = class_getInstanceMethod(_class, _newSelector);
    BOOL isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

@implementation UILabel (MSLabel)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(drawTextInRect:), @selector(MS_drawTextInRect:));
        ReplaceMethod([self class], @selector(sizeThatFits:), @selector(MS_sizeThatFits:));
    });
}

- (void)MS_drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = self.MS_contentInsets;
    [self MS_drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (CGSize)MS_sizeThatFits:(CGSize)size {
    UIEdgeInsets insets = self.MS_contentInsets;
    size = [self MS_sizeThatFits:CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(insets), size.height-UIEdgeInsetsGetVerticalValue(insets))];
    size.width += UIEdgeInsetsGetHorizontalValue(insets);
    size.height += UIEdgeInsetsGetVerticalValue(insets);
    return size;
}

const void *kAssociatedMS_contentInsets;
- (void)setMS_contentInsets:(UIEdgeInsets)MS_contentInsets {
    objc_setAssociatedObject(self, &kAssociatedMS_contentInsets, [NSValue valueWithUIEdgeInsets:MS_contentInsets] , OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)MS_contentInsets {
    return [objc_getAssociatedObject(self, &kAssociatedMS_contentInsets) UIEdgeInsetsValue];
}


@end
