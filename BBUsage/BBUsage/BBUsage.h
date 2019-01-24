//
//  BBUsage.h
//  BBUsage
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBUsage : NSObject

/*
    单例，注意！模拟器上的数值指的是电脑的占用
*/
+ (BBUsage *)sharedManager;

//开启帧率监测
- (void)startMonitor;

//暂停帧率监测
- (void)pauseMonitor;

//停止帧率监测
- (void)stopMonitor;

//获取帧率
- (NSInteger)keyFrame;

//获取内存使用(M)
- (double)memoryUsage;

//获取内存可用(M)
- (double)memoryUseful;

//获取CPU使用率
- (double)cpuUsage;

@end

