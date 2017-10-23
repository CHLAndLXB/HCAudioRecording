//
//  CHLAudioRecordHUD.m
//  CHLAudioRecordingDemo
//
//  Created by DAYOU on 2017/3/24.
//  Copyright © 2017年 DaYou. All rights reserved.
//

#import "CHLAudioRecordHUD.h"


@interface CHLAudioHUDView : UIView

-(void)showDB:(CGFloat)db;

-(void)showText;

-(void)showCancelImageView;

-(void)showNormalImage;

@end


@implementation CHLAudioHUDView
{
    UILabel * _label;
    UIImageView * _imageView;
    UIImageView * _yinjieImageView;
    CGFloat _db;
    NSLayoutConstraint *_maskH;
    UIView * _maskView;
    UIImageView * _cancelImageView;
}


-(void)showText{
    
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    _label = [UILabel new];
    _label.text = @"手指上滑,取消发送";
    _label.textColor = [UIColor whiteColor];
    _label.numberOfLines = 0;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont fontWithName:@"SimHei" size:11];
    [self addSubview:_label];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150]];
    
    
    _imageView = [[UIImageView alloc]init];
    _imageView.image = [UIImage imageNamed:@"jiayuan_video"];
    _imageView.translatesAutoresizingMaskIntoConstraints =  NO;
    [self addSubview:_imageView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_imageView.image.size.width]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_imageView.image.size.height]];
    
    
    UIImage * image = [UIImage imageNamed:@"jiayuan_t7"];
    
    _maskView = [[UIView alloc]init];
    _maskView.translatesAutoresizingMaskIntoConstraints = NO;
    _maskView.layer.masksToBounds = YES;
    [self addSubview:_maskView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_maskView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:30]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_maskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_maskView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:image.size.width]];
    _maskH = [NSLayoutConstraint constraintWithItem:_maskView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:image.size.height];
    [self addConstraint:_maskH];
    
    
    _yinjieImageView = [[UIImageView alloc]init];
    _yinjieImageView.image = image;
    _yinjieImageView.translatesAutoresizingMaskIntoConstraints =  NO;
    [_maskView addSubview:_yinjieImageView];
    
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_maskView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_maskView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_yinjieImageView.image.size.width]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_yinjieImageView.image.size.height]];
    
    
    _cancelImageView = [[UIImageView alloc]init];
    _cancelImageView.image = [UIImage imageNamed:@"jiayuan_video_bcak"];
    _cancelImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelImageView.hidden = YES;
    [self addSubview:_cancelImageView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cancelImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cancelImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cancelImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_cancelImageView.image.size.width]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_cancelImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_cancelImageView.image.size.height]];
    
    
}
-(void)showDB:(CGFloat)db{
    
    NSLog(@"%lf",db);
    
    _db = db;
    //改变高度
//    _maskH.constant = _yinjieImageView.image.size.height * db/100;
    
    
    [_yinjieImageView removeFromSuperview];
    [_yinjieImageView removeConstraints:_yinjieImageView.constraints];
    
    
   
    
    if ((int)_db/(100/7)<=7) {
        _yinjieImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"jiayuan_t%d",(int)_db/(100/7)]];
    }else{
        _yinjieImageView.image = [UIImage imageNamed:@"jiayuan_t7"];
    }
    
    [_maskView addSubview:_yinjieImageView];

    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_maskView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_maskView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_yinjieImageView.image.size.width]];
    [_maskView addConstraint:[NSLayoutConstraint constraintWithItem:_yinjieImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_yinjieImageView.image.size.height]];

}

-(void)showCancelImageView{
    
    _label.text = @"松开手指,取消发送";
    _cancelImageView.hidden = NO;
    _yinjieImageView.hidden = YES;
    _imageView.hidden = YES;
    _maskView.hidden = YES;
    
}

-(void)showNormalImage{
    
    _label.text = @"手指上滑,取消发送";
    _cancelImageView.hidden = YES;
    _yinjieImageView.hidden = NO;
    _imageView.hidden = NO;
    _maskView.hidden = NO;
}


@end



@implementation CHLAudioRecordHUD
{
	 __weak UIView * _superView;
    CHLAudioHUDView * _contentView;
}

- (instancetype)initWithView:(UIView *)superView {
    if (self = [super init]) {
        _superView = superView;
        self.translatesAutoresizingMaskIntoConstraints = NO;
       
    }
    return self;
}



-(void)showHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
		
        self.alpha = 0;
        [_superView addSubview: self];
        
        [_superView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_superView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_superView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_superView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [_superView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_superView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_superView addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_superView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        _contentView = [CHLAudioHUDView new];
        _contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.layer.cornerRadius = 10;
        _contentView.layer.masksToBounds = YES;
        [self addSubview:_contentView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:190]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:190]];
        
        [_contentView showText];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1.0;
        }];
		
    });
}

- (void)showDB:(CGFloat)db {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_contentView) {
            [_contentView showDB:db];
        }
    });
}

-(void)showCancelImageView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_contentView) {
            [_contentView showCancelImageView];
        }
    });
}

-(void)showNormalImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_contentView) {
            [_contentView showNormalImage];
        }
    });
}

- (void)dismiss {
    
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });
}


@end


