//
//  ViewController.m
//  CHLAudioRecordingDemo
//
//  Created by DAYOU on 2017/3/24.
//  Copyright © 2017年 DaYou. All rights reserved.
//

#import "ViewController.h"
#import "CHLAudioRecordView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    CHLAudioRecordView * recordView = [[CHLAudioRecordView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    recordView.userInteractionEnabled = YES;
    [self.view addSubview:recordView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
