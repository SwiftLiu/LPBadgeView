//
//  LPBadgeView.m
//  Demo
//
//  Created by FineexMac on 16/2/26.
//  Copyright © 2016年 iOS_LiuLiuLiu. All rights reserved.
//
//  作者GitHub主页 https://github.com/SwiftLiu
//  作者邮箱 1062014109@qq.com
//  下载链接 https://github.com/SwiftLiu/LPBadgeView.git

#import "LPBadgeView.h"

///徽标半径
const CGFloat BadgeR = 10;
///可回弹的最大半径
const CGFloat ElsticMaxR = 55;
///增加的边距
const CGFloat Margin = 5;

typedef NS_ENUM(NSInteger, BState) {
    ///静止状态（初始默认状态）
    BStateStatic,
    ///抖动状态（长按抖动）
    BStateShake,
    ///拉伸状态（橡皮筋拉伸，徽标随触摸点移动）
    BStateTensile,
    ///回弹状态（橡皮筋回弹）
    BStateBack,
    ///断裂状态（橡皮筋断裂，徽标随触摸点移动）
    BStateBreak,
    ///消失状态（徽标破裂消失）
    BStateHidden
};

@interface LPBadgeView ()
{
    BOOL canSet;
    int shakeCount;
    int backCount;
    
    CGPoint centerAtWindow;
    
    BState state;
}

///徽标
@property (strong, nonatomic) UILabel *badgeLabel;
///橡皮筋图层
@property (strong, nonatomic) CALayer *elasticLayer;

@end

@implementation LPBadgeView

#pragma mark - 属性值
- (void)setValue:(NSInteger)value
{
    if (_value != value) {
        _value = value;
        
        _badgeLabel.hidden = !value;
        _elasticLayer.hidden = !value;
        self.userInteractionEnabled = value;
        
        CGFloat wide = 2 * BadgeR;
        if (value >= 100) {
            _badgeLabel.text = @"99+";
            [self setBadgeSize:CGSizeMake(wide * 1.6, wide)];
        }else if (value >= 10) {
            _badgeLabel.text = [NSString stringWithFormat:@"%ld", value];
            [self setBadgeSize:CGSizeMake(wide * 1.3, wide)];
        }else if (value >= 1) {
            _badgeLabel.text = [NSString stringWithFormat:@"%ld", value];
            [self setBadgeSize:CGSizeMake(wide, wide)];
        }
    }
}


#pragma mark - 便利初始化
+ (LPBadgeView *)badgeWithColor:(UIColor *)color
{
    LPBadgeView *badge = [LPBadgeView new];
    badge.badgeLabel.backgroundColor = color?:[UIColor redColor];
    return badge;
}

//初始化
- (void)initWithColor:(UIColor *)color
{
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    
    //徽标标签
    _badgeLabel = [UILabel new];
    _badgeLabel.userInteractionEnabled = NO;
    _badgeLabel.backgroundColor = color;
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
    _badgeLabel.font = [UIFont systemFontOfSize:BadgeR*1.2];
    _badgeLabel.layer.cornerRadius = BadgeR;
    _badgeLabel.layer.masksToBounds = YES;
    [self addSubview:_badgeLabel];
    
    [self setBadgeSize:CGSizeMake(BadgeR*2, BadgeR*2)];
    
    //橡皮筋图层
    _elasticLayer = [CALayer layer];
    CGFloat layerWide = (ElsticMaxR + BadgeR) * 2;
    _elasticLayer.bounds = CGRectMake(0, 0, layerWide, layerWide);
    _elasticLayer.fillMode = kCAFillRuleNonZero;
    _elasticLayer.masksToBounds = NO;
}

#pragma mark - 重写
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initWithColor:[UIColor redColor]];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initWithColor:self.backgroundColor];
    self.value = _value;
}

- (void)setFrame:(CGRect)frame
{
    if (canSet) {
        [super setFrame:frame];
    }else{
        CGRect rect;
        rect.size = self.frame.size;
        rect.origin = frame.origin;
        [super setFrame:rect];
        //self在window中位置
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        CGPoint p = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        centerAtWindow = [self convertPoint:p toView:window];
    }
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    //self在window中位置
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    CGPoint p = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    centerAtWindow = [self convertPoint:p toView:window];
}

- (void)setBounds:(CGRect)bounds
{
    if (canSet) {
        [super setBounds:bounds];
    }else{
        CGRect rect;
        rect.size = self.frame.size;
        rect.origin = bounds.origin;
        [super setBounds:rect];
    }
}


#pragma mark - 计算
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [self Location:touches];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (state == BStateStatic) {
            [self beShakeAt:p];
        }
    });
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [self Location:touches];
    CGFloat len = Distance(CGPointZero, p);
    
    //必须为静止或则抖动状态，则开始进入拉伸状态
    if ((state==BStateStatic || state==BStateShake) && len > BadgeR) {
        [self beTensileAt:p];
    }
    //若拉伸超过最大半径，则进入断裂状态
    if (len > ElsticMaxR) {
        state = BStateBreak;
        _elasticLayer.contents = nil;
    }
    
    
    //①拉伸状态，绘制橡皮筋
    if (state == BStateTensile) {
        [self drawRubberWithPoint:p];
    }
    //②拉伸或则断裂状态，徽标移动
    if (state == BStateTensile || state == BStateBreak) {
        _badgeLabel.center = CGPointMake(centerAtWindow.x + p.x, centerAtWindow.y + p.y);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [self Location:touches];
    
    if (state==BStateStatic) {
        [self beHidden];
    }
    else if (state == BStateTensile) {
        [self beBackAt:p];
    }
    else if (Distance(CGPointZero, p)>ElsticMaxR) {
        [self beHidden];
    }
    else{
        [self beStatic];
    }
}

#pragma mark - 动画
//静止动画
- (void)beStatic
{
    state = BStateStatic;
    self.userInteractionEnabled = YES;
    //徽标移动至self上
    [_badgeLabel removeFromSuperview];
    [self addSubview:_badgeLabel];
    _badgeLabel.center = CenterAt(self);
    //橡皮筋图层从window上移除
    _elasticLayer.contents = nil;
    [_elasticLayer removeFromSuperlayer];
}

//抖动动画
- (void)beShakeAt:(CGPoint)p
{
    state = BStateShake;
    self.userInteractionEnabled = NO;
    _elasticLayer.contents = nil;
    //计算每次移动的目标位置
    CGFloat range = 5;
    CGPoint point = _badgeLabel.center;
    if (shakeCount==0 || shakeCount==2) {
        point.x = CGRectGetMidX(self.bounds) - range;
    }else if (shakeCount==1 || shakeCount==3) {
        point.x = CGRectGetMidX(self.bounds) + range;
    }else{
        point.x = CGRectGetMidX(self.bounds);
    }
    //移动
    NSTimeInterval duration = 0.05;
    if (shakeCount>0&&shakeCount<4) duration = duration * 2;
    [UIView animateWithDuration:0.07 animations:^{
        _badgeLabel.center = point;
    } completion:^(BOOL finished) {
        shakeCount++;
        if (shakeCount<7) {
            if (state == BStateShake) [self beShakeAt:p];//循环调用，继续执行动画
        }else{
            shakeCount = 0;
            //进入拉伸状态
            state = BStateTensile;
            [self beTensileAt:p];
            [self drawRubberWithPoint:p];
        }
    }];
}

//拉伸动画
- (void)beTensileAt:(CGPoint)p
{
    state = BStateTensile;
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    //①添加橡皮筋图层到window上
    CGRect rect = _elasticLayer.bounds;
    rect.origin = CGPointMake(centerAtWindow.x-rect.size.width/2.l, centerAtWindow.y-rect.size.height/2.l);
    _elasticLayer.frame = rect;
    [window.layer addSublayer:_elasticLayer];
    
    //②移动徽标到window上
    [_badgeLabel removeFromSuperview];
    [window addSubview:_badgeLabel];
    _badgeLabel.center = CGPointMake(centerAtWindow.x + p.x, centerAtWindow.y + p.y);
}

//回弹动画(p：以self的中心为左边原点的位置)
- (void)beBackAt:(CGPoint)p
{
    state = BStateBack;
    self.userInteractionEnabled = NO;
    _elasticLayer.contents = nil;
    CGFloat m = 0.3; //回弹力消弱系数
    
    //新的目标地址
    p.x = - p.x * m;
    p.y = - p.y * m;
    CGPoint newP = CGPointMake(centerAtWindow.x + p.x, centerAtWindow.y + p.y);
    
    //动画
    [UIView animateWithDuration:0.1 animations:^{
        _badgeLabel.center = newP;
    } completion:^(BOOL finished) {
        backCount++;
        if (backCount < 4) {
            [self beBackAt:p];//循环调用，继续执行动画
        }else{
            [self beStatic];
            backCount = 0;
        }
    }];
}

//消失动画
- (void)beHidden
{
    state = BStateHidden;
    if (_hiddenBlock) _hiddenBlock(_value);//回调
    
    //动画容器
    UIImageView *imgView = [UIImageView new];
    imgView.frame = _badgeLabel.frame;
    [_badgeLabel.superview addSubview:imgView];
    imgView.contentMode = UIViewContentModeCenter;
    imgView.animationDuration = .25;
    imgView.animationRepeatCount = 1;
    NSMutableArray *images = [NSMutableArray array];
    for (int i=1; i<=5; i++) {
        NSString *imgName = [NSString stringWithFormat:@"LPBadgeView.bundle/LPBadgeBomb_%d", i];
        UIImage *img = [UIImage imageNamed:imgName];
        if (img) [images addObject:img];
    }
    imgView.animationImages = images;
    [imgView startAnimating];
    
    _badgeLabel.hidden = YES;
    
    //动画结束后处理
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(imgView.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imgView stopAnimating];
        [imgView removeFromSuperview];
        [self beStatic];
        self.value = 0;
    });
}


#pragma mark - 绘制橡皮筋
- (void)drawRubberWithPoint:(CGPoint)p
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = _elasticLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, _badgeLabel.backgroundColor.CGColor);
    CGContextTranslateCTM(ctx, size.width/2.l, size.height/2.l);//将坐标系移至画布中心
    
    
    //小圆弧半径
    CGFloat r = BadgeR - (BadgeR/2.5l) * (Distance(CGPointZero, p)/ElsticMaxR) - 2;
    //角度，逆时针绘制
    double angle = Angle(CGPointZero, p);
    double fixAngle = M_PI_2 * 0.7l;
    double angle1 = angle + fixAngle;
    double angle2 = angle - fixAngle;
    //小圆弧与两条曲线交点
    CGPoint a1 = CGPointMake(r*cos(angle1), r*sin(angle1));
//    CGPoint b1 = CGPointMake(r*cos(angle2), -r*sin(angle2));
    //曲线的另一个端点
    CGFloat x = BadgeR * sin(angle);
    CGFloat y = BadgeR * cos(angle);
    CGPoint a2 = CGPointMake(p.x-x, p.y+y);
    CGPoint b2 = CGPointMake(p.x+x, p.y-y);
    //两曲线圆心，即二阶贝塞尔曲线控制点
    CGPoint ac = CGPointMake(p.x/2.l, p.y/2.l);
    CGPoint bc = CGPointMake(p.x/2.l, p.y/2.l);
    //绘制曲线
    CGContextMoveToPoint(ctx, a1.x, a1.y);
    CGContextAddArc(ctx, 0, 0, r, angle1, angle2, NO);
    CGContextAddQuadCurveToPoint(ctx, bc.x, bc.y, b2.x, b2.y);
    CGContextAddLineToPoint(ctx, a2.x, a2.y);
    CGContextAddQuadCurveToPoint(ctx, ac.x, ac.y, a1.x, a1.y);
    
    
    CGContextDrawPath(ctx, kCGPathEOFill);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(ctx);
    CGContextRelease(ctx);
    UIGraphicsEndImageContext();
    _elasticLayer.contents = (__bridge id _Nullable)(img.CGImage);
}


#pragma mark - 辅助方法
//计算两点间直线与水平线的夹角,逆时针
double Angle(CGPoint p1, CGPoint p2) {
    CGFloat angle = atan((p2.y-p1.y)/(p2.x-p1.x));
    if (p2.x < p1.x) {
        angle += M_PI;
    }else if (p2.x == p1.x) {
        if (p2.y > p1.y) angle = M_PI_2;
        else angle = M_PI_2 + M_PI;
    }
    return angle;
}

//计算两点间距离
double Distance(CGPoint p1, CGPoint p2) {
    return sqrt(pow(p2.x-p1.x, 2) + pow(p2.y-p1.y, 2));
}

//中心位置
CGPoint CenterAt(UIView *view) {
    return CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
}

//设置大小
- (void)setBadgeSize:(CGSize)size
{
    //self大小
    CGPoint center = self.center;
    canSet = YES;
    self.bounds = CGRectMake(0, 0, size.width + Margin, size.height + Margin);
    canSet = NO;
    self.center = center;
    
    //修改徽标大小
    if (_badgeLabel.superview == self) {
        _badgeLabel.bounds = CGRectMake(0, 0, size.width, size.height);
        _badgeLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }else{
        CGPoint badgeCenter = _badgeLabel.center;
        _badgeLabel.bounds = CGRectMake(0, 0, size.width, size.height);
        _badgeLabel.center = badgeCenter;
    }
}

//相对位置
- (CGPoint)Location:(NSSet<UITouch *> *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint l = [touch locationInView:self];
    CGPoint c = CenterAt(self);
    return CGPointMake(l.x - c.x, l.y - c.y);
}

@end
