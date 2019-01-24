//
//  ViewController.m
//  BBUsage
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "ViewController.h"
#import "BBUsage.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *frame_des;
@property (weak, nonatomic) IBOutlet UILabel *memoryUse_des;
@property (weak, nonatomic) IBOutlet UILabel *memoryUseful_des;
@property (weak, nonatomic) IBOutlet UILabel *cpu_des;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [BBUsage.sharedManager startMonitor];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(show)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)show{
    self.frame_des.text = @(BBUsage.sharedManager.keyFrame).description;
    self.memoryUse_des.text = [NSString stringWithFormat:@"%.2lfM",BBUsage.sharedManager.memoryUsage];
    self.memoryUseful_des.text = [NSString stringWithFormat:@"%.2lfM",BBUsage.sharedManager.memoryUseful];
    self.cpu_des.text = [NSString stringWithFormat:@"%.1lf%%",BBUsage.sharedManager.cpuUsage];
}

@end
