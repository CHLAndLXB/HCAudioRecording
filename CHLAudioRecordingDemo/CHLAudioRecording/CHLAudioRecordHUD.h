//
//  CHLAudioRecordHUD.h
//  CHLAudioRecordingDemo
//
//  Created by DAYOU on 2017/3/24.
//  Copyright © 2017年 DaYou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLAudioRecordHUD : UIView

- (instancetype)initWithView:(UIView *)superView ;

- (void)showDB:(CGFloat)db;

- (void)showHUD;

- (void)showCancelImageView;

- (void)showNormalImage;

- (void)dismiss;

@end
