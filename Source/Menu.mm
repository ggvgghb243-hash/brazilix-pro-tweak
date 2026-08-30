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

// Colors exactly matching the screenshots
#define UI_COLOR_MAIN_BG     [UIColor colorWithRed:11.0/255.0 green:14.0/255.0 blue:23.0/255.0 alpha:0.98]
#define UI_COLOR_SIDEBAR_BG  [UIColor colorWithRed:7.0/255.0 green:9.0/255.0 blue:15.0/255.0 alpha:1.0]
#define UI_COLOR_TAB_ACTIVE  [UIColor colorWithRed:16.0/255.0 green:22.0/255.0 blue:36.0/255.0 alpha:1.0]
#define UI_COLOR_ACCENT      [UIColor colorWithRed:24.0/255.0 green:82.0/255.0 blue:255.0/255.0 alpha:1.0] // Vibrant Royal Blue
#define UI_COLOR_ACCENT_TEXT [UIColor colorWithRed:32.0/255.0 green:96.0/255.0 blue:255.0/255.0 alpha:1.0]
#define UI_COLOR_TEXT_MAIN   [UIColor colorWithRed:235.0/255.0 green:240.0/255.0 blue:250.0/255.0 alpha:1.0]
#define UI_COLOR_TEXT_MUTED  [UIColor colorWithRed:130.0/255.0 green:142.0/255.0 blue:165.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BG      [UIColor colorWithRed:17.0/255.0 green:22.0/255.0 blue:36.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BORDER  [UIColor colorWithRed:30.0/255.0 green:40.0/255.0 blue:62.0/255.0 alpha:1.0]
#define UI_COLOR_HEADER_BG   [UIColor colorWithRed:14.0/255.0 green:18.0/255.0 blue:30.0/255.0 alpha:1.0]
#define UI_COLOR_HEADER_BORDER [UIColor colorWithRed:24.0/255.0 green:32.0/255.0 blue:52.0/255.0 alpha:1.0]

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
        
        _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, 20, 20)];
        _boxView.layer.cornerRadius = 5.0f;
        _boxView.layer.borderWidth = 1.2f;
        _boxView.userInteractionEnabled = NO;
        [self addSubview:_boxView];
        
        _checkLabel = [[UILabel alloc] initWithFrame:_boxView.bounds];
        _checkLabel.text = @"✓";
        _checkLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        _checkLabel.textColor = [UIColor whiteColor];
        _checkLabel.textAlignment = NSTextAlignmentCenter;
        _checkLabel.userInteractionEnabled = NO;
        [_boxView addSubview:_checkLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 240, 26)];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
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
@property (nonatomic, strong) UIView *headerPillView;
@property (nonatomic, strong) UILabel *headerIconLabel;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UILabel *headerDividerLabel;
@property (nonatomic, strong) UILabel *headerSubLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabActiveBgs;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabIndicators;
@property (nonatomic, strong) NSArray<UIScrollView *> *tabViews;
@property (nonatomic, assign) NSInteger currentTabIndex;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGPoint lastPoint;

// Live synced checkboxes
@property (nonatomic, strong) CustomCheckbox *espMainCheck;
@property (nonatomic, strong) CustomCheckbox *boxCheck;
@property (nonatomic, strong) CustomCheckbox *lineCheck;
@property (nonatomic, strong) CustomCheckbox *healthCheck;
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
    
    // Enlarged menu dimensions for clearer, comfortable UI
    CGFloat menuWidth = 470.0f;
    CGFloat menuHeight = 350.0f;
    CGFloat x = (kWidth - menuWidth) * 0.5f;
    CGFloat y = (kHeight - menuHeight) * 0.5f;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    _menuView.backgroundColor = UI_COLOR_MAIN_BG;
    _menuView.layer.cornerRadius = 12.0f;
    _menuView.layer.borderWidth = 1.0f;
    _menuView.layer.borderColor = [UIColor colorWithRed:28.0/255.0 green:36.0/255.0 blue:56.0/255.0 alpha:0.9].CGColor;
    _menuView.clipsToBounds = YES;
    _menuView.hidden = YES;
    _menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_menuView addGestureRecognizer:panGesture];
    
    if (mainWindow) [mainWindow addSubview:_menuView];
    
    // --- 1. Left Sidebar ---
    CGFloat sidebarWidth = 88.0f;
    _sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, menuHeight)];
    _sidebarView.backgroundColor = UI_COLOR_SIDEBAR_BG;
    [_menuView addSubview:_sidebarView];
    
    _tabButtons = [NSMutableArray new];
    _tabActiveBgs = [NSMutableArray new];
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
        
        // Active rounded item background
        UIView *activeBg = [[UIView alloc] initWithFrame:CGRectMake(6, 6, sidebarWidth - 12, tabH - 12)];
        activeBg.backgroundColor = UI_COLOR_TAB_ACTIVE;
        activeBg.layer.cornerRadius = 8.0f;
        activeBg.hidden = (i != 0);
        activeBg.userInteractionEnabled = NO;
        [tabBtn addSubview:activeBg];
        [_tabActiveBgs addObject:activeBg];
        
        UILabel *iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, sidebarWidth, 24)];
        iconLabel.text = tabs[i][@"icon"];
        iconLabel.font = [UIFont systemFontOfSize:18];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.tag = 101;
        iconLabel.userInteractionEnabled = NO;
        [tabBtn addSubview:iconLabel];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, sidebarWidth, 20)];
        nameLabel.text = tabs[i][@"name"];
        nameLabel.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium];
        nameLabel.textColor = (i == 0) ? [UIColor whiteColor] : UI_COLOR_TEXT_MUTED;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.tag = 102;
        nameLabel.userInteractionEnabled = NO;
        [tabBtn addSubview:nameLabel];
        
        // Right vertical blue indicator bar
        UIView *ind = [[UIView alloc] initWithFrame:CGRectMake(sidebarWidth - 4, 18, 4, tabH - 36)];
        ind.backgroundColor = UI_COLOR_ACCENT;
        ind.layer.cornerRadius = 2.0f;
        ind.hidden = (i != 0); // Default to Aimbot
        ind.userInteractionEnabled = NO;
        [tabBtn addSubview:ind];
        
        [_sidebarView addSubview:tabBtn];
        [_tabButtons addObject:tabBtn];
        [_tabIndicators addObject:ind];
    }
    
    // --- 2. Right Content Header Pill ---
    CGFloat contentX = sidebarWidth;
    CGFloat contentW = menuWidth - sidebarWidth;
    CGFloat headerMargin = 14.0f;
    CGFloat headerW = contentW - (headerMargin * 2);
    CGFloat headerH = 38.0f;
    
    _headerPillView = [[UIView alloc] initWithFrame:CGRectMake(contentX + headerMargin, 12, headerW, headerH)];
    _headerPillView.backgroundColor = UI_COLOR_HEADER_BG;
    _headerPillView.layer.cornerRadius = 6.0f;
    _headerPillView.layer.borderWidth = 1.0f;
    _headerPillView.layer.borderColor = UI_COLOR_HEADER_BORDER.CGColor;
    [_menuView addSubview:_headerPillView];
    
    _headerIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 9, 20, 20)];
    _headerIconLabel.font = [UIFont systemFontOfSize:14];
    [_headerPillView addSubview:_headerIconLabel];
    
    _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 9, 82, 20)];
    _headerTitleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightBold];
    _headerTitleLabel.textColor = UI_COLOR_ACCENT;
    [_headerPillView addSubview:_headerTitleLabel];
    
    _headerDividerLabel = [[UILabel alloc] initWithFrame:CGRectMake(118, 9, 10, 20)];
    _headerDividerLabel.text = @"|";
    _headerDividerLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
    _headerDividerLabel.textColor = [UIColor colorWithRed:45.0/255.0 green:55.0/255.0 blue:80.0/255.0 alpha:1.0];
    [_headerPillView addSubview:_headerDividerLabel];
    
    _headerSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(132, 9, headerW - 140, 20)];
    _headerSubLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _headerSubLabel.textColor = UI_COLOR_TEXT_MAIN;
    _headerSubLabel.adjustsFontSizeToFitWidth = YES;
    _headerSubLabel.minimumScaleFactor = 0.8f;
    [_headerPillView addSubview:_headerSubLabel];
    
    // --- 3. Content Tabs Container ---
    CGFloat contentTop = 56.0f;
    CGFloat contentH = menuHeight - contentTop;
    _contentContainer = [[UIView alloc] initWithFrame:CGRectMake(contentX, contentTop, contentW, contentH)];
    [_menuView addSubview:_contentContainer];
    
    // Build 4 scrollviews for the 4 tabs
    UIScrollView *aimbotView = [self buildAimbotViewWithWidth:contentW height:contentH];
    UIScrollView *visualsView = [self buildVisualsViewWithWidth:contentW height:contentH];
    UIScrollView *miscView = [self buildMiscViewWithWidth:contentW height:contentH];
    UIScrollView *settingsView = [self buildSettingsViewWithWidth:contentW height:contentH];
    
    _tabViews = @[aimbotView, visualsView, miscView, settingsView];
    for (UIView *v in _tabViews) {
        [_contentContainer addSubview:v];
    }
    
    // Select Aimbot by default matching first screenshot
    [self selectTab:0];
}

// ===== TAB 0: AIMBOT VIEW =====
- (UIScrollView *)buildAimbotViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 6;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // Master switch
    CustomCheckbox *masterCheck = [[CustomCheckbox alloc] initWithTitle:@"Master switch" checked:YES];
    masterCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:masterCheck];
    py += 32;
    
    // Aiming method
    [sv addSubview:[self makeLabel:@"Aiming method" frame:CGRectMake(px, py, pw, 18)]];
    py += 22;
    [sv addSubview:[self makeDropdown:@"Silent aimbot" frame:CGRectMake(px, py, pw, 32)]];
    py += 38;
    
    // Show FOV circle with right color swatch
    CustomCheckbox *fovCheck = [[CustomCheckbox alloc] initWithTitle:@"Show FOV circle" checked:YES];
    fovCheck.frame = CGRectMake(px, py, pw - 36, 26);
    [sv addSubview:fovCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 24, py + 4, 24, 18)]];
    py += 32;
    
    // Ignore types
    [sv addSubview:[self makeLabel:@"Ignore types" frame:CGRectMake(px, py, pw, 18)]];
    py += 22;
    [sv addSubview:[self makeDropdown:@"Invisible, Knocked" frame:CGRectMake(px, py, pw, 32)]];
    py += 38;
    
    // Hitbox
    [sv addSubview:[self makeLabel:@"Hitbox" frame:CGRectMake(px, py, pw, 18)]];
    py += 22;
    [sv addSubview:[self makeDropdown:@"Head" frame:CGRectMake(px, py, pw, 32)]];
    py += 38;
    
    // Target priority
    [sv addSubview:[self makeLabel:@"Target priority" frame:CGRectMake(px, py, pw, 18)]];
    py += 22;
    [sv addSubview:[self makeDropdown:@"Closest to crosshair" frame:CGRectMake(px, py, pw, 32)]];
    py += 42;
    
    sv.contentSize = CGSizeMake(w, py + 15);
    return sv;
}

// ===== TAB 1: VISUALS VIEW (CONNECTED TO ENGINE) =====
- (UIScrollView *)buildVisualsViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 6;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // Enemy ESP (Master Switch)
    _espMainCheck = [[CustomCheckbox alloc] initWithTitle:@"Enemy ESP" checked:Vars.Enable];
    _espMainCheck.frame = CGRectMake(px, py, pw, 26);
    _espMainCheck.onToggle = ^(BOOL checked) {
        Vars.Enable = checked;
    };
    [sv addSubview:_espMainCheck];
    py += 32;
    
    // Line (Snaplines) + White Swatch
    _lineCheck = [[CustomCheckbox alloc] initWithTitle:@"Line" checked:Vars.lines];
    _lineCheck.frame = CGRectMake(px, py, pw - 36, 26);
    _lineCheck.onToggle = ^(BOOL checked) {
        Vars.lines = checked;
    };
    [sv addSubview:_lineCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 24, py + 4, 24, 18)]];
    py += 32;
    
    // Line fire material (Unchecked)
    CustomCheckbox *fireMatCheck = [[CustomCheckbox alloc] initWithTitle:@"Line fire material" checked:NO];
    fireMatCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:fireMatCheck];
    py += 32;
    
    // Box ESP + Red & Green Swatches
    _boxCheck = [[CustomCheckbox alloc] initWithTitle:@"Box" checked:Vars.Box];
    _boxCheck.frame = CGRectMake(px, py, pw - 60, 26);
    _boxCheck.onToggle = ^(BOOL checked) {
        Vars.Box = checked;
    };
    [sv addSubview:_boxCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:255.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 52, py + 4, 22, 18)]];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:30.0/255.0 green:225.0/255.0 blue:60.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 24, py + 4, 22, 18)]];
    py += 32;
    
    // Health
    _healthCheck = [[CustomCheckbox alloc] initWithTitle:@"Health" checked:Vars.Health];
    _healthCheck.frame = CGRectMake(px, py, pw, 26);
    _healthCheck.onToggle = ^(BOOL checked) {
        Vars.Health = checked;
    };
    [sv addSubview:_healthCheck];
    py += 30;
    
    // Nickname
    _nameCheck = [[CustomCheckbox alloc] initWithTitle:@"Nickname" checked:Vars.Name];
    _nameCheck.frame = CGRectMake(px, py, pw, 26);
    _nameCheck.onToggle = ^(BOOL checked) {
        Vars.Name = checked;
    };
    [sv addSubview:_nameCheck];
    py += 30;
    
    // Distance
    _distCheck = [[CustomCheckbox alloc] initWithTitle:@"Distance" checked:Vars.Distance];
    _distCheck.frame = CGRectMake(px, py, pw, 26);
    _distCheck.onToggle = ^(BOOL checked) {
        Vars.Distance = checked;
    };
    [sv addSubview:_distCheck];
    py += 30;
    
    // Skeleton + Blue & Green Swatches
    _skelCheck = [[CustomCheckbox alloc] initWithTitle:@"Skeleton" checked:Vars.skeleton];
    _skelCheck.frame = CGRectMake(px, py, pw - 60, 26);
    _skelCheck.onToggle = ^(BOOL checked) {
        Vars.skeleton = checked;
    };
    [sv addSubview:_skelCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:30.0/255.0 green:60.0/255.0 blue:255.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 52, py + 4, 22, 18)]];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:30.0/255.0 green:225.0/255.0 blue:60.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 24, py + 4, 22, 18)]];
    py += 34;
    
    // Skeleton bone thickness slider (2.0)
    [sv addSubview:[self makeSliderRow:@"Skeleton bone thickness" value:@"2.0" defaultVal:0.4f y:&py width:pw x:px]];
    
    // Nearby enemies count
    _countCheck = [[CustomCheckbox alloc] initWithTitle:@"Nearby enemies count" checked:Vars.counts];
    _countCheck.frame = CGRectMake(px, py, pw, 26);
    _countCheck.onToggle = ^(BOOL checked) {
        Vars.counts = checked;
    };
    [sv addSubview:_countCheck];
    py += 34;
    
    sv.contentSize = CGSizeMake(w, py + 15);
    return sv;
}

// ===== TAB 2: MISC VIEW =====
- (UIScrollView *)buildMiscViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 6;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // Disclaimer lines
    UILabel *warn1 = [self makeLabel:@"These features are only for fun and may be unsafe." frame:CGRectMake(px, py, pw, 20)];
    warn1.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    warn1.textColor = UI_COLOR_TEXT_MAIN;
    [sv addSubview:warn1];
    py += 24;
    
    UILabel *warn2 = [self makeLabel:@"Use them at your own risk!" frame:CGRectMake(px, py, pw, 20)];
    warn2.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    warn2.textColor = UI_COLOR_TEXT_MAIN;
    [sv addSubview:warn2];
    py += 32;
    
    // Checkboxes
    _fogCheck = [[CustomCheckbox alloc] initWithTitle:@"No fog" checked:Vars.NoFog];
    _fogCheck.frame = CGRectMake(px, py, pw, 26);
    _fogCheck.onToggle = ^(BOOL checked) {
        Vars.NoFog = checked;
    };
    [sv addSubview:_fogCheck];
    py += 30;
    
    CustomCheckbox *spreadCheck = [[CustomCheckbox alloc] initWithTitle:@"No weapon spread" checked:NO];
    spreadCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:spreadCheck];
    py += 30;
    
    CustomCheckbox *lootCheck = [[CustomCheckbox alloc] initWithTitle:@"Instant loot" checked:NO];
    lootCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:lootCheck];
    py += 30;
    
    CustomCheckbox *iceWallCheck = [[CustomCheckbox alloc] initWithTitle:@"Inverted IceWall rotation" checked:NO];
    iceWallCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:iceWallCheck];
    py += 30;
    
    CustomCheckbox *aspectCheck = [[CustomCheckbox alloc] initWithTitle:@"Aspect ratio" checked:NO];
    aspectCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:aspectCheck];
    py += 30;
    
    CustomCheckbox *autoFireCheck = [[CustomCheckbox alloc] initWithTitle:@"Auto-fire" checked:NO];
    autoFireCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:autoFireCheck];
    py += 34;
    
    sv.contentSize = CGSizeMake(w, py + 15);
    return sv;
}

// ===== TAB 3: SETTINGS VIEW =====
- (UIScrollView *)buildSettingsViewWithWidth:(CGFloat)w height:(CGFloat)h {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    sv.showsVerticalScrollIndicator = YES;
    sv.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    CGFloat py = 6;
    CGFloat px = 14;
    CGFloat pw = w - 28;
    
    // OB52 text
    UILabel *verLabel = [self makeLabel:@"OB52 1.11 (14affab80a9c35e0) (null | 7ffffffffffffff)\n(0|0|0|0|0|0)" frame:CGRectMake(px, py, pw, 36)];
    verLabel.numberOfLines = 2;
    verLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    verLabel.textColor = UI_COLOR_TEXT_MAIN;
    [sv addSubview:verLabel];
    py += 42;
    
    // Accent color row
    [sv addSubview:[self makeLabel:@"Accent color" frame:CGRectMake(px, py, pw - 40, 22)]];
    [sv addSubview:[self makeColorSwatch:UI_COLOR_ACCENT frame:CGRectMake(px + pw - 24, py + 2, 24, 18)]];
    py += 32;
    
    // Subscription text with blue timer
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, py, pw, 20)];
    NSMutableAttributedString *subStr = [[NSMutableAttributedString alloc] initWithString:@"Subscription time left: " attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_TEXT_MAIN,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }];
    [subStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"16 days, 23 hours, 52 minutes, 26 seconds" attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_ACCENT_TEXT,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }]];
    subLabel.attributedText = subStr;
    subLabel.adjustsFontSizeToFitWidth = YES;
    [sv addSubview:subLabel];
    py += 24;
    
    // Build text with blue version tags
    UILabel *buildLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, py, pw, 20)];
    NSMutableAttributedString *bldStr = [[NSMutableAttributedString alloc] initWithString:@"Build at " attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_TEXT_MAIN,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }];
    [bldStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"Jan 20 2026 22:05:22 - 1.7.1" attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_ACCENT_TEXT,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }]];
    [bldStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" for game version " attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_TEXT_MAIN,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }]];
    [bldStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"1.120.X" attributes:@{
        NSForegroundColorAttributeName: UI_COLOR_ACCENT_TEXT,
        NSFontAttributeName: [UIFont systemFontOfSize:11.5f weight:UIFontWeightMedium]
    }]];
    buildLabel.attributedText = bldStr;
    buildLabel.adjustsFontSizeToFitWidth = YES;
    [sv addSubview:buildLabel];
    py += 30;
    
    // Streamproof
    CustomCheckbox *streamCheck = [[CustomCheckbox alloc] initWithTitle:@"Streamproof" checked:NO];
    streamCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:streamCheck];
    py += 32;
    
    // Language
    [sv addSubview:[self makeLabel:@"Language" frame:CGRectMake(px, py, pw, 18)]];
    py += 22;
    [sv addSubview:[self makeDropdown:@"English" frame:CGRectMake(px, py, pw, 32)]];
    py += 42;
    
    // Royal Blue Action Buttons
    [sv addSubview:[self makeBigBlueButton:@"Enable silent mode" frame:CGRectMake(px, py, pw, 36)]];
    py += 44;
    [sv addSubview:[self makeBigBlueButton:@"Save settings" frame:CGRectMake(px, py, pw, 36)]];
    py += 44;
    [sv addSubview:[self makeBigBlueButton:@"Load settings" frame:CGRectMake(px, py, pw, 36)]];
    py += 44;
    
    sv.contentSize = CGSizeMake(w, py + 15);
    return sv;
}

// ===== UI HELPER WIDGETS =====
- (UILabel *)makeLabel:(NSString *)text frame:(CGRect)frame {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.text = text;
    l.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    l.textColor = UI_COLOR_TEXT_MAIN;
    return l;
}

- (UIView *)makeDropdown:(NSString *)title frame:(CGRect)frame {
    UIView *box = [[UIView alloc] initWithFrame:frame];
    box.backgroundColor = UI_COLOR_BOX_BG;
    box.layer.cornerRadius = 6.0f;
    box.layer.borderWidth = 1.0f;
    box.layer.borderColor = UI_COLOR_BOX_BORDER.CGColor;
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, frame.size.width - 36, frame.size.height)];
    l.text = title;
    l.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    l.textColor = UI_COLOR_TEXT_MAIN;
    [box addSubview:l];
    
    UILabel *arr = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 24, 0, 18, frame.size.height)];
    arr.text = @"\u2304";
    arr.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    arr.textColor = UI_COLOR_TEXT_MUTED;
    [box addSubview:arr];
    
    return box;
}

- (UIView *)makeColorSwatch:(UIColor *)color frame:(CGRect)frame {
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = color;
    v.layer.cornerRadius = 4.5f;
    v.layer.borderWidth = 0.8f;
    v.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    return v;
}

- (UIView *)makeSliderRow:(NSString *)name value:(NSString *)val defaultVal:(float)defVal y:(CGFloat *)py width:(CGFloat)pw x:(CGFloat)px {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(px, *py, pw, 46)];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pw - 70, 18)];
    titleL.text = name;
    titleL.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightMedium];
    titleL.textColor = UI_COLOR_TEXT_MAIN;
    [container addSubview:titleL];
    
    UILabel *valL = [[UILabel alloc] initWithFrame:CGRectMake(pw - 65, 0, 65, 18)];
    valL.text = val;
    valL.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightBold];
    valL.textColor = UI_COLOR_ACCENT;
    valL.textAlignment = NSTextAlignmentRight;
    [container addSubview:valL];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 22, pw, 20)];
    slider.minimumTrackTintColor = UI_COLOR_ACCENT;
    slider.maximumTrackTintColor = UI_COLOR_BOX_BG;
    slider.thumbTintColor = UI_COLOR_ACCENT;
    slider.value = defVal;
    [container addSubview:slider];
    
    *py += 52;
    return container;
}

- (UIButton *)makeBigBlueButton:(NSString *)title frame:(CGRect)frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = UI_COLOR_ACCENT;
    btn.layer.cornerRadius = 8.0f;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
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
        @{@"icon": @"📦", @"title": @"MISC", @"sub": @"Game enhancements."},
        @{@"icon": @"⚙", @"title": @"SETTINGS", @"sub": @"Configure options."}
    ];
    
    _headerIconLabel.text = headers[index][@"icon"];
    _headerTitleLabel.text = headers[index][@"title"];
    _headerSubLabel.text = headers[index][@"sub"];
    
    // Auto adjust header title width based on text
    CGFloat titleW = (index == 3) ? 75.0f : ((index == 1) ? 68.0f : ((index == 0) ? 65.0f : 45.0f));
    _headerTitleLabel.frame = CGRectMake(36, 9, titleW, 20);
    _headerDividerLabel.frame = CGRectMake(36 + titleW + 6, 9, 10, 20);
    CGFloat subX = 36 + titleW + 20;
    _headerSubLabel.frame = CGRectMake(subX, 9, _headerPillView.bounds.size.width - subX - 8, 20);
    
    for (int i = 0; i < _tabButtons.count; i++) {
        UIButton *btn = _tabButtons[i];
        UIView *bg = _tabActiveBgs[i];
        UIView *ind = _tabIndicators[i];
        UILabel *nameL = [btn viewWithTag:102];
        
        if (i == index) {
            bg.hidden = NO;
            ind.hidden = NO;
            nameL.textColor = [UIColor whiteColor];
        } else {
            bg.hidden = YES;
            ind.hidden = YES;
            nameL.textColor = UI_COLOR_TEXT_MUTED;
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
