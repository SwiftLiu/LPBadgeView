# LPBadgeView
仿QQ新消息数的小红圈徽标Badge，橡皮筋效果

下载地址：https://github.com/SwiftLiu/LPBadgeView.git

#### 1.便利初始化

    ///默认color(主题颜色)为红色
    + (LPBadgeView *)badgeWithColor:(UIColor *)color;

#### 2.直接使用xib/storyboard初始化
拖入主件UIView，修改类为LPBadgeView即可，默认颜色为拖入的UIView主件的背景色。

#### 3.属性
仅一个属性，即数字值:

    @property (assign, nonatomic) NSInteger value;

