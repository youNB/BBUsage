//
//  BBUsage.m
//  BBUsage
//
//  Created by 程肖斌 on 2019/1/24.
//  Copyright © 2019年 ICE. All rights reserved.
//

#import "BBUsage.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>

@interface BBUsage()
@property(nonatomic, strong) CADisplayLink *display_link;
@property(nonatomic, assign) CFTimeInterval inteval;
@property(nonatomic, assign) NSInteger      key_frame;
@property(nonatomic, assign) NSInteger      frame_count;
@end

@implementation BBUsage

//单例
+ (BBUsage *)sharedManager{
    static BBUsage *manager       = nil;
    static dispatch_once_t once_t = 0;
    dispatch_once(&once_t, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

//开启帧率监测
- (void)startMonitor{
    if(self.display_link){self.display_link.paused = NO;}
    
    self.frame_count = 0;
    self.inteval     = CACurrentMediaTime();
    self.display_link = [CADisplayLink displayLinkWithTarget:self
                                                    selector:@selector(timeCount)];
    BOOL state = NSThread.currentThread.isMainThread;
    if(state){
        [self.display_link addToRunLoop:NSRunLoop.currentRunLoop
                                forMode:NSRunLoopCommonModes];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.display_link addToRunLoop:NSRunLoop.currentRunLoop
                                    forMode:NSRunLoopCommonModes];
        });
    }
}

- (void)timeCount{
    self.frame_count ++;
    CFTimeInterval time = CACurrentMediaTime()-self.inteval;
    if(time < 0.5){return;}
    self.key_frame = (NSInteger)(self.frame_count / time);
    self.inteval = CACurrentMediaTime();
    self.frame_count = 0;
}

//暂停帧率监测
- (void)pauseMonitor{
    self.display_link.paused = YES;
}

//停止帧率监测
- (void)stopMonitor{
    [self.display_link invalidate];
    self.display_link = nil;
}

//获取帧率
- (NSInteger)keyFrame{
    return self.key_frame;
}

//获取内存使用(M)
- (double)memoryUsage{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS){return 0;}
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

//获取内存可用(M)
- (double)memoryUseful{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS){return 0;}
    return vm_page_size * vmStats.free_count / 1024.0 / 1024.0;
}

//获取CPU使用率
- (double)cpuUsage{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {return -1;}
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;
    
    basic_info = (task_basic_info_t)tinfo;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {return -1;}
    if (thread_count > 0){stat_thread += thread_count;}
    
    long tot_sec  = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < (int)thread_count; j++){
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {return -1;}
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th -> user_time.seconds + basic_info_th -> system_time.seconds;
            tot_usec = tot_usec + basic_info_th -> user_time.microseconds + basic_info_th -> system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th -> cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return roundf(tot_cpu);
}

@end
