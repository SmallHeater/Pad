//
//  UIImageAndLabelBtn.h
//  Pad
//
//  Created by mac on 2018/10/26.
//  Copyright © 2018年 xianjunwang. All rights reserved.
//  图片，label按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageAndLabelBtn : UIControl

-(instancetype)initWithFrame:(CGRect)frame andImageViewFrame:(CGRect)imageFrame andLabelFrame:(CGRect)labelFrame andImageName:(NSString *)imageName andHeightImageName:(NSString *)heightImageName andTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
