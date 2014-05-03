//
//  ZxingController.h
//  tabbarDemo
//
//  Created by WebosterBob on 4/27/14.
//  Copyright (c) 2014 WebosterBob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZxingController : UIViewController <ZXCaptureDelegate>

@property (nonatomic,strong) UIImageView *lineView;//扫描线
@property (nonatomic,assign) BOOL willUp;//扫描移动方向
@property (nonatomic,strong) NSTimer *timer;//扫描线定时器

@end


/*
 class 朱小伟 
 {
 public:
    enum advantage {null,nil,NUL};
    enum disadvantage {色狼，变态，猥琐，傻×，SB}；
 private:
    inline char* fanOfWho()     //把谁当做偶像
    {
        return YBQ;             //岳不群，缩写YBQ
    }
    inline void dailyAction()
    {
        return；                //行尸走肉
    }
 
 }
 
 
 class 夏傻：private 朱小伟       //傻×私有继承傻×
 {
    }
 
 */