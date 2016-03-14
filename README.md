# LPBadgeView
仿QQ新消息数的小红圈徽标Badge，橡皮筋效果
####1.Demo演示
![演示](https://github.com/SwiftLiu/LPBadgeView/blob/master/movie_LPBadgeView.gif?raw=true)

####2.使用说明

[下载Demo](https://github.com/SwiftLiu/LPBadgeView.git)，将文件夹LPBadgeView直接导入工程即可使用。

####3.代码

##### 初始化
1.代码初始化
```objc
///默认color(主题颜色)为红色
+ (LPBadgeView *)badgeWithColor:(UIColor *)color;
```
2.直接使用xib/storyboard初始化
拖入主件UIView，修改类为LPBadgeView即可，默认颜色为拖入的UIView主件的背景色。

##### 属性
1.Badge值:
```objc
@property (assign, nonatomic) NSInteger value;
```
2.Badge消失回调
```objc
@property (strong, nonatomic) void (^hiddenBlock)(NSInteger value);
```
