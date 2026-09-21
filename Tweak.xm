#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <dlfcn.h>

// Конфигурационные переменные
typedef struct {
    struct {
        BOOL watermark;
    } menu;
} g_cfg;

typedef struct {
    NSString *username;
} g_ctx;

// Глобальные переменные
g_cfg config;
g_ctx context;

// Таймер для обновления времени
NSTimer *watermarkTimer;

static void LoadEmpireXitsDylib(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *paths = @[
            @"/var/jb/Library/Application Support/destroying/empirexits.dylib",
            @"/Library/Application Support/destroying/empirexits.dylib"
        ];
        for (NSString *path in paths) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) continue;
            void *handle = dlopen(path.UTF8String, RTLD_LAZY | RTLD_GLOBAL);
            if (handle != NULL) {
                NSLog(@"[destroying] empirexits.dylib carregada: %@", path);
            } else {
                const char *error = dlerror();
                NSLog(@"[destroying] falha ao carregar empirexits.dylib: %s", error ?: "erro desconhecido");
            }
            break;
        }
    });
}

@interface WatermarkView : UIView
@property (nonatomic, strong) NSString *watermarkText;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) CAShapeLayer *pulseLayer;
@property (nonatomic, strong) NSMutableArray *circleLayers;
@end

@implementation WatermarkView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        self.circleLayers = [NSMutableArray array];
        
        // Закругленные углы
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        [self setupPulseAnimation];


    }
    return self;
}

- (void)setupPulseAnimation {
    // Слой для пульсации
    self.pulseLayer = [CAShapeLayer layer];
    self.pulseLayer.frame = self.bounds;
    self.pulseLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12].CGPath;
    self.pulseLayer.fillColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    self.pulseLayer.opacity = 0.0;
    
    [self.layer addSublayer:self.pulseLayer];
    
    // Анимация пульсации
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 2.0;
    pulseAnimation.fromValue = @1.0;
    pulseAnimation.toValue = @1.02;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = HUGE_VALF;
    
    [self.layer addAnimation:pulseAnimation forKey:@"pulse"];
}



- (void)animateCircle:(CAShapeLayer *)circleLayer {
    CGFloat radius = 25 + arc4random_uniform(15);
    CGFloat angle = arc4random_uniform(360) * M_PI / 180.0;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint circleCenter = CGPointMake(center.x + radius * cos(angle), center.y + radius * sin(angle));
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circleCenter
                                                              radius:3
                                                          startAngle:0
                                                            endAngle:2 * M_PI
                                                           clockwise:YES];
    circleLayer.path = circlePath.CGPath;
    
    // Групповая анимация
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 2.0;
    animationGroup.repeatCount = HUGE_VALF;
    animationGroup.removedOnCompletion = NO;
    
    // Анимация появления/исчезновения
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0.0, @1.0, @0.0];
    opacityAnimation.keyTimes = @[@0.0, @0.3, @1.0];
    
    // Анимация масштаба
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[@0.5, @1.2, @0.8];
    scaleAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    
    // Анимация цвета
    CAKeyframeAnimation *colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    colorAnimation.values = @[
        (id)[UIColor colorWithRed:0.0 green:0.4 blue:0.8 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.0 green:0.3 blue:0.6 alpha:0.5].CGColor
    ];
    colorAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    
    animationGroup.animations = @[opacityAnimation, scaleAnimation, colorAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [circleLayer addAnimation:animationGroup forKey:@"circleAnimation"];
}

- (void)drawRect:(CGRect)rect {
    // Черный фон с закруглением
    UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12];
[[UIColor colorWithWhite:0.0 alpha:1.0] setFill];
    [backgroundPath fill];
    
  
    
    // Текст ватермарка
    NSDictionary *attributes = @{
        NSFontAttributeName: self.font,
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0],
        NSShadowAttributeName: [self textShadow]
    };
    
    CGSize textSize = [self.watermarkText sizeWithAttributes:attributes];
    CGRect textRect = CGRectMake((rect.size.width - textSize.width) / 2,
                               (rect.size.height - textSize.height) / 2,
                               textSize.width, textSize.height);
    
    [self.watermarkText drawInRect:textRect withAttributes:attributes];
}

- (NSShadow *)textShadow {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.4 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowBlurRadius = 2;
    return shadow;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.pulseLayer.frame = self.bounds;
    self.pulseLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:12].CGPath;
}

@end

// Функция для получения текущего времени в формате HH:mm:ss
NSString* getCurrentTime() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}

// Функция для обновления текста ватермарка
NSString* getWatermarkText() {
    NSString *currentTime = getCurrentTime();
    return [NSString stringWithFormat:@"destroying_pub | %@", currentTime];
}

// Функция для обновления ватермарка
void updateWatermark() {
    static WatermarkView *watermarkView = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;
        
        watermarkView = [[WatermarkView alloc] initWithFrame:CGRectZero];
        [keyWindow addSubview:watermarkView];
        [keyWindow bringSubviewToFront:watermarkView];
    });
    
    if (!config.menu.watermark) {
        watermarkView.hidden = YES;
        return;
    }
    
    watermarkView.hidden = NO;
    
    NSString *watermark = getWatermarkText();
    UIFont *font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize textSize = [watermark sizeWithAttributes:attributes];
    
    // Размеры блока
    CGFloat boxWidth = textSize.width + 40;
    CGFloat boxHeight = 38;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat x = screenBounds.size.width - boxWidth - 20;
    CGFloat y = 60;
    
    watermarkView.frame = CGRectMake(x, y, boxWidth, boxHeight);
    watermarkView.watermarkText = watermark;
    watermarkView.font = font;
    
    [watermarkView setNeedsDisplay];
}

// Таймер для обновления времени
void startWatermarkTimer() {
    watermarkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     repeats:YES
                                                       block:^(NSTimer * _Nonnull timer) {
        updateWatermark();
    }];
}

void open_destroying_pub_telegram() {
    NSString *telegramURL = @"tg://resolve?domain=destroying_pub";
    NSURL *url = [NSURL URLWithString:telegramURL];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        NSString *webURL = @"https://t.me/destroying_pub";
        NSURL *webUrl = [NSURL URLWithString:webURL];
        [[UIApplication sharedApplication] openURL:webUrl options:@{} completionHandler:nil];
    }
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    // Инициализация конфига
    config.menu.watermark = NO;
    context.username = @"";

    // Carrega a segunda dylib depois que o processo estabiliza.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LoadEmpireXitsDylib();
    });
    
    
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), 
                                    NULL, 
                                    &didFinishLaunching, 
                                    (CFStringRef)UIApplicationDidFinishLaunchingNotification, 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}
