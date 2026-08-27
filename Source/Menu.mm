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

// Colors matching screenshot
#define UI_COLOR_MAIN_BG     [UIColor colorWithRed:12.0/255.0 green:15.0/255.0 blue:23.0/255.0 alpha:0.96]
#define UI_COLOR_SIDEBAR_BG  [UIColor colorWithRed:9.0/255.0 green:11.0/255.0 blue:18.0/255.0 alpha:1.0]
#define UI_COLOR_ACCENT      [UIColor colorWithRed:255.0/255.0 green:77.0/255.0 blue:21.0/255.0 alpha:1.0] // Bright Orange
#define UI_COLOR_TEXT_MAIN   [UIColor colorWithRed:238.0/255.0 green:240.0/255.0 blue:244.0/255.0 alpha:1.0]
#define UI_COLOR_TEXT_MUTED  [UIColor colorWithRed:130.0/255.0 green:140.0/255.0 blue:160.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BG      [UIColor colorWithRed:20.0/255.0 green:25.0/255.0 blue:36.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BORDER  [UIColor colorWithRed:35.0/255.0 green:42.0/255.0 blue:60.0/255.0 alpha:1.0]

// ===== CUSTOM CHECKBOX CONTROL =====
@interface CustomCheckbox : UIControl
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) UILabel *checkLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) void (^onToggle)(BOOL checked);
- (instancetype)initWithTitle:(NSString *)title checked:(BOOL)checked;
@end

@implementation CustomCheckbox
- (instancetype)initWithTitle:(NSString *)title checked:(BOOL)checked {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _isChecked = checked;
        
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 16, 16)];
        _boxView.layer.cornerRadius = 4.0f;
        _boxView.layer.borderWidth = 1.0f;
        _boxView.userInteractionEnabled = NO;
        [self addSubview:_boxView];
        
        _checkLabel = [[UILabel alloc] initWithFrame:_boxView.bounds];
        _checkLabel.text = @"✓";
        _checkLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        _checkLabel.textColor = [UIColor whiteColor];
        _checkLabel.textAlignment = NSTextAlignmentCenter;
        _checkLabel.userInteractionEnabled = NO;
        [_boxView addSubview:_checkLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 180, 22)];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _titleLabel.textColor = UI_COLOR_TEXT_MAIN;
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
        
        [self updateStyle];
        [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)updateStyle {
    if (_isChecked) {
        _boxView.backgroundColor = UI_COLOR_ACCENT;
        _boxView.layer.borderColor = UI_COLOR_ACCENT.CGColor;
        _checkLabel.hidden = NO;
    } else {
        _boxView.backgroundColor = UI_COLOR_BOX_BG;
        _boxView.layer.borderColor = UI_COLOR_BOX_BORDER.CGColor;
        _checkLabel.hidden = YES;
    }
}

- (void)tapped {
    _isChecked = !_isChecked;
    [self updateStyle];
    if (_onToggle) _onToggle(_isChecked);
}
@end

// ===== MAIN BRAZILIX MENU =====
@interface BrazilixMenu : NSObject
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *sidebarView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UILabel *headerIconLabel;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UILabel *headerSubLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabIndicators;
@property (nonatomic, strong) NSArray<UIScrollView *> *tabViews;
@property (nonatomic, assign) NSInteger currentTabIndex;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGPoint lastPoint;

// Live synced checkboxes
@property (nonatomic, strong) CustomCheckbox *espMainCheck;
@property (nonatomic, strong) CustomCheckbox *boxCheck;
@property (nonatomic, strong) CustomCheckbox *lineCheck;
@property (nonatomic, strong) CustomCheckbox *nameCheck;
@property (nonatomic, strong) CustomCheckbox *distCheck;
@property (nonatomic, strong) CustomCheckbox *skelCheck;
@property (nonatomic, strong) CustomCheckbox *countCheck;
@property (nonatomic, strong) CustomCheckbox *fogCheck;
@end

@implementation BrazilixMenu

static BrazilixMenu *extraInfo;
static BOOL MenDeal = NO;
UIWindow *mainWindow;
game_sdk_t *game_sdk = new game_sdk_t();

extern "C" void initAntiCheatBypass();

+ (void)load {
    initAntiCheatBypass();
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

// ===== MENU VIEW BUILDER =====
- (void)setupMenu {
    if (!mainWindow) {
        mainWindow = [UIApplication sharedApplication].keyWindow;
        if (!mainWindow) {
            NSArray *windows = [UIApplication sharedApplication].windows;
            if (windows.count > 0) mainWindow = windows.firstObject;
        }
    }
    
    CGFloat menuWidth = 340.0f;
    CGFloat menuHeight = 240.0f;
    CGFloat x = (kWidth - menuWidth) * 0.5f;
    CGFloat y = (kHeight - menuHeight) * 0.5f;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    _menuView.backgroundColor = UI_COLOR_MAIN_BG;
    _menuView.layer.cornerRadius = 8.0f;
    _menuView.layer.borderWidth = 1.0f;
    _menuView.layer.borderColor = [UIColor colorWithRed:30.0/255.0 green:36.0/255.0 blue:50.0/255.0 alpha:0.9].CGColor;
    _menuView.clipsToBounds = YES;
    _menuView.hidden = YES;
    _menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_menuView addGestureRecognizer:panGesture];
    
    if (mainWindow) [mainWindow addSubview:_menuView];
    
    // --- 1. Left Sidebar ---
    CGFloat sidebarWidth = 72.0f;
    _sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, menuHeight)];
    _sidebarView.backgroundColor = UI_COLOR_SIDEBAR_BG;
    [_menuView addSubview:_sidebarView];
    
    _tabButtons = [NSMutableArray new];
    _tabIndicators = [NSMutableArray new];
    
    NSArray *tabs = @[
        @{@"icon": @"🎯", @"name": @"Aimbot"},
        @{@"icon": @"👁", @"name": @"Visuals"},
        @{@"icon": @"📦", @"name": @"Misc"},
        @{@"icon": @"⚙", @"name": @"Settings"}
    ];
    
    CGFloat tabH = menuHeight / 4.0f;
    for (int i = 0; i < tabs.count; i++) {
        UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tabBtn.frame = CGRectMake(0, i * tabH, sidebarWidth, tabH);
        tabBtn.tag = i;
        [tabBtn addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, sidebarWidth, 20)];
        iconLabel.text = tabs[i][@"icon"];
        iconLabel.font = [UIFont systemFontOfSize:14];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.tag = 101;
        [tabBtn addSubview:iconLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, sidebarWidth, 18)];
        nameLabel.text = tabs[i][@"name"];
        nameLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        nameLabel.textColor = UI_COLOR_TEXT_MUTED;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.tag = 102;
        [tabBtn addSubview:nameLabel];
        
        // Right orange selection indicator bar
        UIView *ind = [[UIView alloc] initWithFrame:CGRectMake(sidebarWidth - 3, 10, 3, tabH - 20)];
        ind.backgroundColor = UI_COLOR_ACCENT;
        ind.layer.cornerRadius = 1.5f;
        ind.hidden = (i != 1); // Default to Visuals tab
        [tabBtn addSubview:ind];
        
        [_sidebarView addSubview:tabBtn];
        [_tabButtons addObject:tabBtn];
        [_tabIndicators addObject:ind];
    }
    
    // --- 2. Right Content Header ---
    CGFloat contentX = sidebarWidth;
    CGFloat contentW = menuWidth - sidebarWidth;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(contentX, 0, contentW, 36)];
    headerView.backgroundColor = [UIColor clearColor];
    [_menuView addSubview:headerView];
    
    _headerIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 16, 18)];
    _headerIconLabel.font = [UIFont systemFontOfSize:12];
    [headerView addSubview:_headerIconLabel];
    
    _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 10, 75, 18)];
    _headerTitleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    _headerTitleLabel.textColor = UI_COLOR_ACCENT;
    [headerView addSubview:_headerTitleLabel];
    
    _headerSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 10, 150, 18)];
    _headerSubLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
    _headerSubLabel.textColor = UI_COLOR_TEXT_MUTED;
    [headerView addSubview:_headerSubLabel];
    
    // --- 3. Content Tabs Container ---
    _contentContainer = [[UIView alloc] initWithFrame:CGRectMake(contentX, 36, contentW, menuHeight - 36)];
    [_menuView addSubview:_contentContainer];
    
    // Build 4 scrollviews for the 4 tabs
    UIScrollView *aimbotView = [self buildAimbotViewWithWidth:contentW height:menuHeight - 36];
    UIScrollView *visualsView = [self buildVisualsViewWithWidth:contentW height:menuHeight - 36];
    UIScrollView *miscView = [self buildMiscViewWithWidth:contentW height:menuHeight - 36];
    UIScrollView *settingsView = [self buildSettingsViewWithWidth:contentW height:menuHeight - 36];
    
    _tabViews = @[aimbotView, visualsView, miscView, settingsView];
    for (UIView *v in _tabViews) {
        [_contentContainer addSubview:v];
    }
    
    // Select Visuals by default
    [self selectTab:1];
}

// ===== TAB 0: AIMBOT VIEW =====
- (UIScrollView *)buildAimbotViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 4;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // Aimbot Checkbox
    CustomCheckbox *aimCheck = [[CustomCheckbox alloc] initWithTitle:@"Aimbot" checked:YES];
    aimCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:aimCheck];
    py += 26;
    
    // Aiming method
    [sv addSubview:[self makeLabel:@"Aiming method" frame:CGRectMake(px, py, pw, 16)]];
    py += 18;
    [sv addSubview:[self makeDropdown:@"Silent aimbot" frame:CGRectMake(px, py, pw, 24)]];
    py += 28;
    
    // Show FOV circle
    CustomCheckbox *fovCheck = [[CustomCheckbox alloc] initWithTitle:@"Show FOV circle" checked:YES];
    fovCheck.frame = CGRectMake(px, py, pw - 30, 22);
    [sv addSubview:fovCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 20, py + 3, 16, 16)]];
    py += 26;
    
    CustomCheckbox *invisCheck = [[CustomCheckbox alloc] initWithTitle:@"Ignore invisible targets" checked:YES];
    invisCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:invisCheck];
    py += 24;
    
    CustomCheckbox *knockCheck = [[CustomCheckbox alloc] initWithTitle:@"Ignore knocked targets" checked:YES];
    knockCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:knockCheck];
    py += 24;
    
    CustomCheckbox *spreadCheck = [[CustomCheckbox alloc] initWithTitle:@"Apply spread" checked:YES];
    spreadCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:spreadCheck];
    py += 24;
    
    CustomCheckbox *forceLockCheck = [[CustomCheckbox alloc] initWithTitle:@"Force lock" checked:NO];
    forceLockCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:forceLockCheck];
    py += 26;
    
    // Hitbox
    [sv addSubview:[self makeLabel:@"Hitbox" frame:CGRectMake(px, py, pw, 16)]];
    py += 18;
    [sv addSubview:[self makeDropdown:@"Nearest" frame:CGRectMake(px, py, pw, 24)]];
    py += 28;
    
    // Target priority
    [sv addSubview:[self makeLabel:@"Target priority" frame:CGRectMake(px, py, pw, 16)]];
    py += 18;
    [sv addSubview:[self makeDropdown:@"Closest to crosshair" frame:CGRectMake(px, py, pw, 24)]];
    py += 30;
    
    // Sliders
    [sv addSubview:[self makeSliderRow:@"FOV" value:@"50.0°" defaultVal:0.5f y:&py width:pw x:px]];
    [sv addSubview:[self makeSliderRow:@"Max distance" value:@"100.0m" defaultVal:0.33f y:&py width:pw x:px]];
    [sv addSubview:[self makeSliderRow:@"Lock-on speed" value:@"0.0" defaultVal:0.0f y:&py width:pw x:px]];
    
    sv.contentSize = CGSizeMake(w, py + 10);
    return sv;
}

// ===== TAB 1: VISUALS VIEW (CONNECTED TO ENGINE) =====
- (UIScrollView *)buildVisualsViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 4;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // Enemy ESP (Master Switch)
    _espMainCheck = [[CustomCheckbox alloc] initWithTitle:@"Enemy ESP" checked:Vars.Enable];
    _espMainCheck.frame = CGRectMake(px, py, pw, 22);
    _espMainCheck.onToggle = ^(BOOL checked) {
        Vars.Enable = checked;
    };
    [sv addSubview:_espMainCheck];
    py += 26;
    
    // Line (Snaplines)
    _lineCheck = [[CustomCheckbox alloc] initWithTitle:@"Line" checked:Vars.lines];
    _lineCheck.frame = CGRectMake(px, py, pw - 30, 22);
    _lineCheck.onToggle = ^(BOOL checked) {
        Vars.lines = checked;
    };
    [sv addSubview:_lineCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 20, py + 3, 16, 16)]];
    py += 26;
    
    // Box ESP
    _boxCheck = [[CustomCheckbox alloc] initWithTitle:@"Box" checked:Vars.Box];
    _boxCheck.frame = CGRectMake(px, py, pw - 50, 22);
    _boxCheck.onToggle = ^(BOOL checked) {
        Vars.Box = checked;
    };
    [sv addSubview:_boxCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor redColor] frame:CGRectMake(px + pw - 40, py + 3, 16, 16)]];
    [sv addSubview:[self makeColorSwatch:[UIColor greenColor] frame:CGRectMake(px + pw - 20, py + 3, 16, 16)]];
    py += 26;
    
    // Health
    _healthCheck = [[CustomCheckbox alloc] initWithTitle:@"Health" checked:Vars.Health];
    _healthCheck.frame = CGRectMake(px, py, pw, 22);
    _healthCheck.onToggle = ^(BOOL checked) {
        Vars.Health = checked;
    };
    [sv addSubview:_healthCheck];
    py += 24;
    
    // Nickname
    _nameCheck = [[CustomCheckbox alloc] initWithTitle:@"Nickname" checked:Vars.Name];
    _nameCheck.frame = CGRectMake(px, py, pw, 22);
    _nameCheck.onToggle = ^(BOOL checked) {
        Vars.Name = checked;
    };
    [sv addSubview:_nameCheck];
    py += 24;
    
    // Distance
    _distCheck = [[CustomCheckbox alloc] initWithTitle:@"Distance" checked:Vars.Distance];
    _distCheck.frame = CGRectMake(px, py, pw, 22);
    _distCheck.onToggle = ^(BOOL checked) {
        Vars.Distance = checked;
    };
    [sv addSubview:_distCheck];
    py += 24;
    
    // Skeleton
    _skelCheck = [[CustomCheckbox alloc] initWithTitle:@"Skeleton" checked:Vars.skeleton];
    _skelCheck.frame = CGRectMake(px, py, pw - 50, 22);
    _skelCheck.onToggle = ^(BOOL checked) {
        Vars.skeleton = checked;
    };
    [sv addSubview:_skelCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor redColor] frame:CGRectMake(px + pw - 40, py + 3, 16, 16)]];
    [sv addSubview:[self makeColorSwatch:[UIColor greenColor] frame:CGRectMake(px + pw - 20, py + 3, 16, 16)]];
    py += 28;
    
    // Skeleton bone thickness slider
    [sv addSubview:[self makeSliderRow:@"Skeleton bone thickness" value:@"1.2" defaultVal:0.2f y:&py width:pw x:px]];
    
    // Nearby enemies count
    _countCheck = [[CustomCheckbox alloc] initWithTitle:@"Nearby enemies count" checked:Vars.counts];
    _countCheck.frame = CGRectMake(px, py, pw, 22);
    _countCheck.onToggle = ^(BOOL checked) {
        Vars.counts = checked;
    };
    [sv addSubview:_countCheck];
    py += 26;
    
    // Counter text color
    [sv addSubview:[self makeLabel:@"Counter text color" frame:CGRectMake(px, py, pw - 30, 20)]];
    [sv addSubview:[self makeColorSwatch:[UIColor redColor] frame:CGRectMake(px + pw - 20, py + 2, 16, 16)]];
    py += 26;
    
    sv.contentSize = CGSizeMake(w, py + 10);
    return sv;
}

// ===== TAB 2: MISC VIEW =====
- (UIScrollView *)buildMiscViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 4;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    _fogCheck = [[CustomCheckbox alloc] initWithTitle:@"No Fog" checked:Vars.NoFog];
    _fogCheck.frame = CGRectMake(px, py, pw, 22);
    _fogCheck.onToggle = ^(BOOL checked) {
        Vars.NoFog = checked;
    };
    [sv addSubview:_fogCheck];
    py += 24;
    
    CustomCheckbox *speedCheck = [[CustomCheckbox alloc] initWithTitle:@"Fast Reload" checked:NO];
    speedCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:speedCheck];
    py += 24;
    
    CustomCheckbox *shakeCheck = [[CustomCheckbox alloc] initWithTitle:@"Anti Shake" checked:YES];
    shakeCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:shakeCheck];
    py += 24;
    
    CustomCheckbox *nightCheck = [[CustomCheckbox alloc] initWithTitle:@"Night Mode" checked:NO];
    nightCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:nightCheck];
    py += 24;
    
    sv.contentSize = CGSizeMake(w, py + 10);
    return sv;
}

// ===== TAB 3: SETTINGS VIEW =====
- (UIScrollView *)buildSettingsViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 4;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    UILabel *verLabel = [self makeLabel:@"OB52 1.1 (1a14215f97f0ff2a) (12368 | 7ffffffbbfffffff)\n(16|2|3|3|2|1|1)" frame:CGRectMake(px, py, pw, 28)];
    verLabel.numberOfLines = 2;
    verLabel.font = [UIFont systemFontOfSize:9];
    verLabel.textColor = UI_COLOR_TEXT_MAIN;
    [sv addSubview:verLabel];
    py += 32;
    
    // Accent color row
    [sv addSubview:[self makeLabel:@"Accent color" frame:CGRectMake(px, py, pw - 30, 20)]];
    [sv addSubview:[self makeColorSwatch:UI_COLOR_ACCENT frame:CGRectMake(px + pw - 20, py + 2, 16, 16)]];
    py += 26;
    
    // Subscription text
    UILabel *subLabel = [self makeLabel:@"Subscription time left: 30 days, 23 hours, 11 minutes, 9 seconds" frame:CGRectMake(px, py, pw, 16)];
    subLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightMedium];
    subLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:110.0/255.0 blue:60.0/255.0 alpha:1.0];
    [sv addSubview:subLabel];
    py += 18;
    
    UILabel *buildLabel = [self makeLabel:@"Build at Jan 20 2026 22:05:22 - 1.7.1 for game version 1.120.X" frame:CGRectMake(px, py, pw, 16)];
    buildLabel.font = [UIFont systemFontOfSize:9];
    buildLabel.textColor = UI_COLOR_TEXT_MUTED;
    [sv addSubview:buildLabel];
    py += 22;
    
    // Streamproof
    CustomCheckbox *streamCheck = [[CustomCheckbox alloc] initWithTitle:@"Streamproof" checked:NO];
    streamCheck.frame = CGRectMake(px, py, pw, 22);
    [sv addSubview:streamCheck];
    py += 26;
    
    // Language
    [sv addSubview:[self makeLabel:@"Language" frame:CGRectMake(px, py, pw, 16)]];
    py += 18;
    [sv addSubview:[self makeDropdown:@"English" frame:CGRectMake(px, py, pw, 24)]];
    py += 32;
    
    // Orange Action Buttons
    [sv addSubview:[self makeBigOrangeButton:@"Enable silent mode" frame:CGRectMake(px, py, pw, 28)]];
    py += 34;
    [sv addSubview:[self makeBigOrangeButton:@"Save settings" frame:CGRectMake(px, py, pw, 28)]];
    py += 34;
    [sv addSubview:[self makeBigOrangeButton:@"Load settings" frame:CGRectMake(px, py, pw, 28)]];
    py += 34;
    
    sv.contentSize = CGSizeMake(w, py + 10);
    return sv;
}

// ===== UI HELPER WIDGETS =====
- (UILabel *)makeLabel:(NSString *)text frame:(CGRect)frame {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.text = text;
    l.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    l.textColor = UI_COLOR_TEXT_MAIN;
    return l;
}

- (UIView *)makeDropdown:(NSString *)title frame:(CGRect)frame {
    UIView *box = [[UIView alloc] initWithFrame:frame];
    box.backgroundColor = UI_COLOR_BOX_BG;
    box.layer.cornerRadius = 4.0f;
    box.layer.borderWidth = 0.8f;
    box.layer.borderColor = UI_COLOR_BOX_BORDER.CGColor;
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 28, frame.size.height)];
    l.text = title;
    l.font = [UIFont systemFontOfSize:11];
    l.textColor = UI_COLOR_TEXT_MAIN;
    [box addSubview:l];
    
    UILabel *arr = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 20, 0, 16, frame.size.height)];
    arr.text = @"\u2304";
    arr.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    arr.textColor = UI_COLOR_TEXT_MUTED;
    [box addSubview:arr];
    
    return box;
}

- (UIView *)makeColorSwatch:(UIColor *)color frame:(CGRect)frame {
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = color;
    v.layer.cornerRadius = 3.0f;
    v.layer.borderWidth = 0.5f;
    v.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
    return v;
}

- (UIView *)makeSliderRow:(NSString *)name value:(NSString *)val defaultVal:(float)defVal y:(CGFloat *)py width:(CGFloat)pw x:(CGFloat)px {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(px, *py, pw, 38)];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pw - 60, 16)];
    titleL.text = name;
    titleL.font = [UIFont systemFontOfSize:11];
    titleL.textColor = UI_COLOR_TEXT_MAIN;
    [container addSubview:titleL];
    
    UILabel *valL = [[UILabel alloc] initWithFrame:CGRectMake(pw - 55, 0, 55, 16)];
    valL.text = val;
    valL.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    valL.textColor = UI_COLOR_ACCENT;
    valL.textAlignment = NSTextAlignmentRight;
    [container addSubview:valL];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 18, pw, 18)];
    slider.minimumTrackTintColor = UI_COLOR_ACCENT;
    slider.maximumTrackTintColor = UI_COLOR_BOX_BG;
    slider.thumbTintColor = UI_COLOR_ACCENT;
    slider.value = defVal;
    [container addSubview:slider];
    
    *py += 42;
    return container;
}

- (UIButton *)makeBigOrangeButton:(NSString *)title frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = UI_COLOR_ACCENT;
    btn.layer.cornerRadius = 6.0f;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    return btn;
}

// ===== TAB SELECTION LOGIC =====
- (void)tabClicked:(UIButton *)sender {
    [self selectTab:sender.tag];
}

- (void)selectTab:(NSInteger)index {
    _currentTabIndex = index;
    
    NSArray *headers = @[
        @{@"icon": @"🎯", @"title": @"AIMBOT", @"sub": @"Automatically aim at enemies."},
        @{@"icon": @"👁", @"title": @"VISUALS", @"sub": @"Visual improvements."},
        @{@"icon": @"📦", @"title": @"MISC", @"sub": @"Miscellaneous options."},
        @{@"icon": @"⚙", @"title": @"SETTINGS", @"sub": @"Configure options."}
    ];
    
    _headerIconLabel.text = headers[index][@"icon"];
    _headerTitleLabel.text = headers[index][@"title"];
    _headerSubLabel.text = headers[index][@"sub"];
    
    for (int i = 0; i < _tabButtons.count; i++) {
        UIButton *btn = _tabButtons[i];
        UIView *ind = _tabIndicators[i];
        UILabel *nameL = [btn viewWithTag:102];
        
        if (i == index) {
            ind.hidden = NO;
            nameL.textColor = [UIColor whiteColor];
            btn.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:25.0/255.0 blue:36.0/255.0 alpha:0.6];
        } else {
            ind.hidden = YES;
            nameL.textColor = UI_COLOR_TEXT_MUTED;
            btn.backgroundColor = [UIColor clearColor];
        }
    }
    
    for (int i = 0; i < _tabViews.count; i++) {
        _tabViews[i].hidden = (i != index);
    }
}

// ===== DRAG & REFRESH =====
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    if (!mainWindow) return;
    CGPoint translation = [pan translationInView:mainWindow];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _lastPoint = _menuView.center;
    }
    _menuView.center = CGPointMake(_lastPoint.x + translation.x, _lastPoint.y + translation.y);
}

- (void)updateMenu {
    if (_menuView) _menuView.hidden = !MenDeal;
    
    if (game_sdk && game_sdk->isReady && Vars.Enable) {
        get_players();
    } else {
        [[ESPRenderer sharedInstance] clearDrawings];
    }
}

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

@end

// ===== GAME SDK INITIALIZATION (from dump (1).cs) =====
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

    // Match / Player List (from dump (1).cs)
    this->GetCurrentMatch = (void *(*)())getRealOffset(0x55F1F84);                   // GameFacade.CurrentMatch() [STATIC]
    this->GetPlayerList = (monoList<void **>*(*)(void *))getRealOffset(0x5669EE8);    // EMKJHAJNPDH.GEPFGOHGOJI() [INSTANCE]
    this->GetLocalPlayer = (void *(*)(void *))getRealOffset(0x563B718);              // EMKJHAJNPDH.MBEDKMKBFIE() [INSTANCE]

    this->isReady = true;
}
