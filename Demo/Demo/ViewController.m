//
//  ViewController.m
//  Demo
//
//  Created by FineexMac on 16/2/26.
//  Copyright © 2016年 iOS_LiuLiuLiu. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPBadgeView.git

#import "ViewController.h"
#import "LPBadgeView.h"

@interface ViewController ()
{
    
    __weak IBOutlet LPBadgeView *badge;
    __weak IBOutlet UITextField *valueTextField;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //xib初始化
    badge.value = 13;
    [badge setHiddenBlock:^(NSInteger value) {
        NSLog(@"消失：%ld", value);
    }];
    
    //纯代码初始化
    LPBadgeView *view = [LPBadgeView badgeWithColor:[UIColor orangeColor]];
    view.frame = CGRectMake(150, 400, 50, 50);
    view.value = 222;
    [self.view addSubview:view];
}

- (IBAction)setValue:(id)sender {
    badge.value = valueTextField.text.integerValue;
}

@end
