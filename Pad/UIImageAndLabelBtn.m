//
//  UIImageAndLabelBtn.m
//  Pad
//
//  Created by mac on 2018/10/26.
//  Copyright © 2018年 xianjunwang. All rights reserved.
//

#import "UIImageAndLabelBtn.h"

@interface UIImageAndLabelBtn ()

@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * titleLabel;

@end

@implementation UIImageAndLabelBtn

#pragma mark  ----  生命周期函数
-(instancetype)initWithFrame:(CGRect)frame andImageViewFrame:(CGRect)imageFrame andLabelFrame:(CGRect)labelFrame andImageName:(NSString *)imageName andHeightImageName:(NSString *)heightImageName andTitle:(NSString *)title{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView.frame = imageFrame;
        self.imageView.image = [UIImage imageNamed:imageName];
        self.imageView.highlightedImage = [UIImage imageNamed:heightImageName];
        self.titleLabel.frame = labelFrame;
        self.titleLabel.text = title;
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
    }
    return self;
}

#pragma mark  ----  SET

-(void)setHighlighted:(BOOL)highlighted{
    
    super.highlighted = highlighted;
    self.imageView.highlighted = super.highlighted;
}


#pragma mark  ----  懒加载
-(UIImageView *)imageView{
    
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

-(UILabel *)titleLabel{
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
