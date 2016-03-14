//
//  LPBadgeView.h
//  Demo
//
//  Created by FineexMac on 16/2/26.
//  Copyright © 2016年 iOS_LiuLiuLiu. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPBadgeView.git

#import <UIKit/UIKit.h>

@interface LPBadgeView : UIView

///值
@property (assign, nonatomic) NSInteger value;
///结束回调
@property (strong, nonatomic) void (^hiddenBlock)(NSInteger value);

///便利初始化，默认color(主题颜色)为红色
+ (LPBadgeView *)badgeWithColor:(UIColor *)color;

@end
