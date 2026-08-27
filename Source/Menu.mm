#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// Project headers
#import "Includes/Vector3.h"
#import "Includes/Vector2.h"
#import "Includes/Quaternion.h"
#import "Includes/UnityTypes.h"
#import "Includes/MemoryUtils.h"
#import "Includes/ESP.h"
#import "Includes/Encryption.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

// Minimalist Colors
#define COLOR_BG [UIColor colorWithWhite:0.05 alpha:0.92]
#define COLOR_ACCENT [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] // Red Accent
#define COLOR_TEXT [UIColor whiteColor]
#define COLOR_BTN_OFF [UIColor colorWithWhite:0.15 alpha:1.0]

@interface BrazilixMenu : NSObject
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *enableCheatsButton;
@property (nonatomic, strong) UIButton *boxESPButton;
@property (nonatomic, strong) UIButton *linesESPButton;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *distanceButton;
@property (nonatomic, strong) UIButton *skeletonButton;
@property (nonatomic, strong) UIButton *countButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGPoint lastPoint;
@end

@implementation BrazilixMenu

static BrazilixMenu *extraInfo;
static BOOL MenDeal = NO;
UIWindow *mainWindow;
game_sdk_t *game_sdk = new game_sdk_t();

+ (void)load {
    // Wait until game UI and UnityFramework are loaded
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self waitForUnityFramework];
    });
}

+ (void)waitForUnityFramework {
    static int retries = 0;
    if (getAbsoluteAddress("UnityFramework", 0) != 0 || retries > 30) {
        mainWindow = [UIApplication sharedApplication].keyWindow;
        if (!mainWindow) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            if (windows.count > 0) mainWindow = windows.firstObject;
        }
        
        extraInfo = [BrazilixMenu new];
        game_sdk->init();
        [extraInfo setupDisplayLink];
        [extraInfo initTapGes];
    } else {
        retries++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self waitForUnityFramework];
        });
    }
}

- (void)setupDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMenu)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setupMenu {
    if (!mainWindow) {
        mainWindow = [UIApplication sharedApplication].keyWindow;
        if (!mainWindow) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            if (windows.count > 0) mainWindow = windows.firstObject;
        }
    }
    
    CGFloat menuWidth = 220;
    CGFloat menuHeight = 280;
    CGFloat x = (kWidth - menuWidth) * 0.5f;
    CGFloat y = (kHeight - menuHeight) * 0.5f;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    _menuView.backgroundColor = COLOR_BG;
    _menuView.layer.cornerRadius = 12.0f;
    _menuView.layer.borderWidth = 0.5f;
    _menuView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    _menuView.clipsToBounds = YES;
    _menuView.hidden = YES;
    _menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_menuView addGestureRecognizer:panGesture];
    
    if (mainWindow) [mainWindow addSubview:_menuView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, menuWidth, 25)];
    _titleLabel.text = @"BRAZILIX PRO";
    _titleLabel.textColor = COLOR_TEXT;
    _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_menuView addSubview:_titleLabel];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, menuWidth, menuHeight - 45)];
    _scrollView.showsVerticalScrollIndicator = NO;
    [_menuView addSubview:_scrollView];
    
    CGFloat btnY = 0;
    CGFloat btnH = 32;
    CGFloat btnGap = 6;
    CGFloat btnX = 12;
    CGFloat btnW = menuWidth - 24;
    
    _enableCheatsButton = [self createButtonWithTitle:@"ESP Master Switch" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_enableCheatsButton addTarget:self action:@selector(toggleEnable) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_enableCheatsButton];
    btnY += btnH + btnGap;
    
    _boxESPButton = [self createButtonWithTitle:@"2D Box" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_boxESPButton addTarget:self action:@selector(toggleBox) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_boxESPButton];
    btnY += btnH + btnGap;
    
    _linesESPButton = [self createButtonWithTitle:@"Snaplines" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_linesESPButton addTarget:self action:@selector(toggleLines) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_linesESPButton];
    btnY += btnH + btnGap;
    
    _nameButton = [self createButtonWithTitle:@"Player Names" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_nameButton addTarget:self action:@selector(toggleName) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_nameButton];
    btnY += btnH + btnGap;
    
    _distanceButton = [self createButtonWithTitle:@"Distance" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_distanceButton addTarget:self action:@selector(toggleDistance) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_distanceButton];
    btnY += btnH + btnGap;
    
    _skeletonButton = [self createButtonWithTitle:@"Skeleton" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_skeletonButton addTarget:self action:@selector(toggleSkeleton) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_skeletonButton];
    btnY += btnH + btnGap;
    
    _countButton = [self createButtonWithTitle:@"Enemy Count" frame:CGRectMake(btnX, btnY, btnW, btnH)];
    [_countButton addTarget:self action:@selector(toggleCount) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_countButton];
    btnY += btnH + btnGap;
    
    _scrollView.contentSize = CGSizeMake(menuWidth, btnY + 10);
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (!mainWindow) return;
    CGPoint translation = [pan translationInView:mainWindow];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _lastPoint = _menuView.center;
    }
    _menuView.center = CGPointMake(_lastPoint.x + translation.x, _lastPoint.y + translation.y);
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = COLOR_BTN_OFF;
    button.layer.cornerRadius = 6.0f;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    return button;
}

- (void)updateMenu {
    if (_menuView) _menuView.hidden = !MenDeal;
    
    if (game_sdk && game_sdk->isReady && Vars.Enable) {
        get_players();
    } else {
        [[ESPRenderer sharedInstance] clearDrawings];
    }

    if (!MenDeal || !_menuView) return;

    [self updateButton:_enableCheatsButton forState:Vars.Enable];
    
    NSArray *buttons = @[_boxESPButton, _linesESPButton, _nameButton, _distanceButton, _skeletonButton, _countButton];
    NSArray *states = @[@(Vars.Box), @(Vars.lines), @(Vars.Name), @(Vars.Distance), @(Vars.skeleton), @(Vars.counts)];
    
    for (int i = 0; i < buttons.count; i++) {
        UIButton *btn = buttons[i];
        if (!btn) continue;
        BOOL state = [states[i] boolValue];
        btn.alpha = Vars.Enable ? 1.0f : 0.4f;
        btn.userInteractionEnabled = Vars.Enable;
        [self updateButton:btn forState:state];
    }
}

- (void)updateButton:(UIButton *)button forState:(BOOL)state {
    if (!button) return;
    if (state) {
        button.backgroundColor = [COLOR_ACCENT colorWithAlphaComponent:0.3];
        [button setTitleColor:COLOR_ACCENT forState:UIControlStateNormal];
    } else {
        button.backgroundColor = COLOR_BTN_OFF;
        [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    }
}

#pragma mark - Toggle Actions
- (void)toggleEnable { Vars.Enable = !Vars.Enable; }
- (void)toggleBox { Vars.Box = !Vars.Box; }
- (void)toggleLines { Vars.lines = !Vars.lines; }
- (void)toggleName { Vars.Name = !Vars.Name; }
- (void)toggleDistance { Vars.Distance = !Vars.Distance; }
- (void)toggleSkeleton { Vars.skeleton = !Vars.skeleton; }
- (void)toggleCount { Vars.counts = !Vars.counts; }

- (void)closeMenu {
    MenDeal = NO;
    if (_menuView) _menuView.hidden = YES;
}

- (void)initTapGes {
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    tap2.numberOfTouchesRequired = 2;
    if (mainWindow) [mainWindow addGestureRecognizer:tap2];
}

- (void)openMenu {
    if (!_menuView) [self setupMenu];
    MenDeal = !MenDeal;
    if (_menuView) _menuView.hidden = !MenDeal;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!MenDeal || !_menuView) return;
    UITouch *touch = [touches anyObject];
    if (mainWindow && !CGRectContainsPoint(_menuView.frame, [touch locationInView:mainWindow])) {
        [self closeMenu];
    }
}

@end

// ===== UPDATED OFFSETS FROM DUMP (1).CS =====
void game_sdk_t::init()
{
    uintptr_t base = getAbsoluteAddress("UnityFramework", 0);
    if (base == 0) {
        this->isReady = false;
        return;
    }

    // UnityEngine Offsets (from dump (1).cs)
    this->get_camera = (void *(*)())getRealOffset(0x918E4D0);             // Camera.get_main
    this->WorldToScreenPoint = (Vector3(*)(void *, Vector3))getRealOffset(0x918DDDC); // Camera.WorldToScreenPoint
    this->Component_GetTransform = (void *(*)(void *))getRealOffset(0x91E7DD0); // Component.get_transform
    this->get_position = (Vector3(*)(void *))getRealOffset(0x91FA058);   // Transform.get_position
    this->GetForward = (Vector3(*)(void *))getRealOffset(0x91FAA50);     // Transform.get_forward

    // Player Methods (from dump (1).cs: Player.LPMLOHBLCCG)
    this->name = (monoString *(*)(void *))getRealOffset(0x53EC2B8);       // Player.get_NickName
    this->get_IsDieing = (bool (*)(void *))getRealOffset(0x53D6C7C);     // Player.get_IsDieing
    this->get_isLocalTeam = (bool (*)(void *))getRealOffset(0x54101A8);  // Player.IsLocalTeammate

    // Skeleton Bone Transforms (from dump (1).cs: Player.LPMLOHBLCCG)
    this->GetHeadTF = (void *(*)(void *))getRealOffset(0x54828CC);       // Player.GetHeadTF
    this->GetHipTF = (void *(*)(void *))getRealOffset(0x5482A7C);        // Player.GetHipTF
    this->GetLeftAnkleTF = (void *(*)(void *))getRealOffset(0x5482ECC);  // Player.GetLeftAnkleTF
    this->GetRightAnkleTF = (void *(*)(void *))getRealOffset(0x5482FD8); // Player.GetRightAnkleTF
    this->GetLeftToeTF = (void *(*)(void *))getRealOffset(0x54830E4);    // Player.GetLeftToeTF
    this->GetRightToeTF = (void *(*)(void *))getRealOffset(0x54831F0);   // Player.GetRightToeTF

    // Match / Player List (from dump (1).cs: EMKJHAJNPDH.KKDAICOONPI)
    this->GetPlayerList = (monoList<void **>*(*)())getRealOffset(0x5669EE8); // GetPlayerList
    this->GetLocalPlayer = (void *(*)())getRealOffset(0x563B718);            // GetLocalPlayer

    this->isReady = true;
}
