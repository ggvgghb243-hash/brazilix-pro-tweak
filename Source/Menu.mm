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

// Colors exactly matching screenshots
#define UI_COLOR_MAIN_BG     [UIColor colorWithRed:10.0/255.0 green:13.0/255.0 blue:21.0/255.0 alpha:0.98]
#define UI_COLOR_SIDEBAR_BG  [UIColor colorWithRed:7.0/255.0 green:9.0/255.0 blue:15.0/255.0 alpha:1.0]
#define UI_COLOR_TAB_ACTIVE  [UIColor colorWithRed:15.0/255.0 green:20.0/255.0 blue:34.0/255.0 alpha:1.0]
#define UI_COLOR_ACCENT      [UIColor colorWithRed:24.0/255.0 green:82.0/255.0 blue:255.0/255.0 alpha:1.0] // Vibrant Royal Blue
#define UI_COLOR_ACCENT_TEXT [UIColor colorWithRed:32.0/255.0 green:96.0/255.0 blue:255.0/255.0 alpha:1.0]
#define UI_COLOR_TEXT_MAIN   [UIColor colorWithRed:235.0/255.0 green:240.0/255.0 blue:250.0/255.0 alpha:1.0]
#define UI_COLOR_TEXT_MUTED  [UIColor colorWithRed:125.0/255.0 green:138.0/255.0 blue:160.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BG      [UIColor colorWithRed:16.0/255.0 green:21.0/255.0 blue:34.0/255.0 alpha:1.0]
#define UI_COLOR_BOX_BORDER  [UIColor colorWithRed:28.0/255.0 green:38.0/255.0 blue:58.0/255.0 alpha:1.0]
#define UI_COLOR_HEADER_BG   [UIColor colorWithRed:13.0/255.0 green:17.0/255.0 blue:28.0/255.0 alpha:1.0]
#define UI_COLOR_HEADER_BORDER [UIColor colorWithRed:22.0/255.0 green:30.0/255.0 blue:48.0/255.0 alpha:1.0]

// Forward declaration
@class BrazilixMenu;

// ===== VECTOR ICON GENERATOR (NO EMOJIS) =====
@interface IconHelper : NSObject
+ (UIImage *)drawAimbotIconWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawVisualsIconWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawMiscIconWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)drawSettingsIconWithColor:(UIColor *)color size:(CGSize)size;
@end

@implementation IconHelper

+ (UIImage *)drawAimbotIconWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, 1.4f);
    
    CGFloat cx = size.width / 2.0f;
    CGFloat cy = size.height / 2.0f;
    CGFloat r = (MIN(size.width, size.height) / 2.0f) - 3.0f;
    
    // Outer circle
    CGContextStrokeEllipseInRect(ctx, CGRectMake(cx - r, cy - r, r * 2, r * 2));
    
    // 4 crosshair ticks
    CGFloat tick = 2.5f;
    CGContextMoveToPoint(ctx, cx, cy - r - tick);
    CGContextAddLineToPoint(ctx, cx, cy - r + 1.5f);
    
    CGContextMoveToPoint(ctx, cx, cy + r - 1.5f);
    CGContextAddLineToPoint(ctx, cx, cy + r + tick);
    
    CGContextMoveToPoint(ctx, cx - r - tick, cy);
    CGContextAddLineToPoint(ctx, cx - r + 1.5f, cy);
    
    CGContextMoveToPoint(ctx, cx + r - 1.5f, cy);
    CGContextAddLineToPoint(ctx, cx + r + tick, cy);
    CGContextStrokePath(ctx);
    
    // Center dot
    CGContextFillEllipseInRect(ctx, CGRectMake(cx - 1.5f, cy - 1.5f, 3.0f, 3.0f));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)drawVisualsIconWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    
    CGFloat cx = size.width / 2.0f;
    CGFloat cy = size.height / 2.0f;
    CGFloat w = size.width - 4.0f;
    CGFloat h = size.height - 7.0f;
    
    // Eye outline curve
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cx - w/2.0f, cy)];
    [path addQuadCurveToPoint:CGPointMake(cx + w/2.0f, cy) controlPoint:CGPointMake(cx, cy - h/1.2f)];
    [path addQuadCurveToPoint:CGPointMake(cx - w/2.0f, cy) controlPoint:CGPointMake(cx, cy + h/1.2f)];
    [path closePath];
    path.lineWidth = 1.4f;
    [color setStroke];
    [path stroke];
    
    // Center pupil
    CGContextFillEllipseInRect(ctx, CGRectMake(cx - 2.2f, cy - 2.2f, 4.4f, 4.4f));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)drawMiscIconWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, 1.4f);
    
    CGFloat cx = size.width / 2.0f;
    CGFloat cy = size.height / 2.0f;
    CGFloat w = size.width - 5.0f;
    CGFloat h = size.height - 5.0f;
    
    // Rounded box outline
    UIBezierPath *box = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(cx - w/2.0f, cy - h/2.0f, w, h) cornerRadius:2.5f];
    box.lineWidth = 1.4f;
    [color setStroke];
    [box stroke];
    
    // Horizontal divider
    CGFloat divY = cy - h/2.0f + h * 0.38f;
    CGContextMoveToPoint(ctx, cx - w/2.0f, divY);
    CGContextAddLineToPoint(ctx, cx + w/2.0f, divY);
    
    // Center handle slot
    CGContextMoveToPoint(ctx, cx - 2.5f, divY);
    CGContextAddLineToPoint(ctx, cx - 2.5f, divY + 3.0f);
    CGContextAddLineToPoint(ctx, cx + 2.5f, divY + 3.0f);
    CGContextAddLineToPoint(ctx, cx + 2.5f, divY);
    CGContextStrokePath(ctx);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)drawSettingsIconWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    
    CGFloat cx = size.width / 2.0f;
    CGFloat cy = size.height / 2.0f;
    CGFloat rOuter = (MIN(size.width, size.height) / 2.0f) - 2.0f;
    CGFloat rInner = rOuter - 2.2f;
    CGFloat rHole = 2.4f;
    
    int spokes = 6;
    UIBezierPath *gearPath = [UIBezierPath bezierPath];
    for (int i = 0; i < spokes; i++) {
        CGFloat angle1 = (i * 2 * M_PI / spokes) - 0.22f;
        CGFloat angle2 = (i * 2 * M_PI / spokes) + 0.22f;
        CGFloat angle3 = ((i + 1) * 2 * M_PI / spokes) - 0.22f;
        
        CGPoint p1 = CGPointMake(cx + rOuter * cos(angle1), cy + rOuter * sin(angle1));
        CGPoint p2 = CGPointMake(cx + rOuter * cos(angle2), cy + rOuter * sin(angle2));
        CGPoint p3 = CGPointMake(cx + rInner * cos(angle2 + 0.15f), cy + rInner * sin(angle2 + 0.15f));
        CGPoint p4 = CGPointMake(cx + rInner * cos(angle3 - 0.15f), cy + rInner * sin(angle3 - 0.15f));
        
        if (i == 0) [gearPath moveToPoint:p1];
        else [gearPath addLineToPoint:p1];
        [gearPath addLineToPoint:p2];
        [gearPath addLineToPoint:p3];
        [gearPath addLineToPoint:p4];
    }
    [gearPath closePath];
    gearPath.lineWidth = 1.3f;
    [color setStroke];
    [gearPath stroke];
    
    CGContextSetLineWidth(ctx, 1.2f);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(cx - rHole, cy - rHole, rHole * 2, rHole * 2));
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

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
        _boxView.layer.cornerRadius = 4.5f;
        _boxView.layer.borderWidth = 1.0f;
        _boxView.userInteractionEnabled = NO;
        [self addSubview:_boxView];
        
        _checkLabel = [[UILabel alloc] initWithFrame:_boxView.bounds];
        _checkLabel.text = @"✓";
        _checkLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
        _checkLabel.textColor = [UIColor whiteColor];
        _checkLabel.textAlignment = NSTextAlignmentCenter;
        _checkLabel.userInteractionEnabled = NO;
        [_boxView addSubview:_checkLabel];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 260, 26)];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
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

// ===== INTERACTIVE DROPDOWN CONTROL WITH SELECTION POPUP =====
@interface CustomDropdown : UIControl
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *arrowLabel;
@property (nonatomic, strong) NSArray<NSString *> *options;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *dropdownHeader;
@property (nonatomic, copy) void (^onSelectionChanged)(NSString *selected, NSInteger index);
@property (nonatomic, weak) BrazilixMenu *menuRef;
- (instancetype)initWithHeader:(NSString *)header options:(NSArray<NSString *> *)options defaultIndex:(NSInteger)index menu:(BrazilixMenu *)menu;
- (void)setSelectedIndex:(NSInteger)index;
@end

// ===== MAIN BRAZILIX MENU =====
@interface BrazilixMenu : NSObject
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *sidebarView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *headerPillView;
@property (nonatomic, strong) UIImageView *headerIconView;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UILabel *headerDividerLabel;
@property (nonatomic, strong) UILabel *headerSubLabel;

@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *tabIconViews;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabActiveBgs;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabIndicators;
@property (nonatomic, strong) NSArray<UIScrollView *> *tabViews;
@property (nonatomic, assign) NSInteger currentTabIndex;

// Floating dropdown picker modal
@property (nonatomic, strong) UIView *pickerOverlayView;
@property (nonatomic, strong) UIView *pickerCardView;
@property (nonatomic, strong) UILabel *pickerTitleLabel;
@property (nonatomic, strong) UIScrollView *pickerScrollView;
@property (nonatomic, strong) CustomDropdown *activeDropdown;

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

- (void)showDropdownPickerFor:(CustomDropdown *)dropdown;
- (void)hideDropdownPicker;
@end

@implementation CustomDropdown
- (instancetype)initWithHeader:(NSString *)header options:(NSArray<NSString *> *)options defaultIndex:(NSInteger)index menu:(BrazilixMenu *)menu {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _dropdownHeader = header;
        _options = options;
        _selectedIndex = (index >= 0 && index < options.count) ? index : 0;
        _menuRef = menu;
        
        self.backgroundColor = UI_COLOR_BOX_BG;
        self.layer.cornerRadius = 5.0f;
        self.layer.borderWidth = 0.8f;
        self.layer.borderColor = UI_COLOR_BOX_BORDER.CGColor;
        self.clipsToBounds = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _options[_selectedIndex];
        _titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightRegular];
        _titleLabel.textColor = UI_COLOR_TEXT_MAIN;
        _titleLabel.userInteractionEnabled = NO;
        [self addSubview:_titleLabel];
        
        _arrowLabel = [[UILabel alloc] init];
        _arrowLabel.text = @"\u2304";
        _arrowLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _arrowLabel.textColor = UI_COLOR_TEXT_MUTED;
        _arrowLabel.textAlignment = NSTextAlignmentCenter;
        _arrowLabel.userInteractionEnabled = NO;
        [self addSubview:_arrowLabel];
        
        [self addTarget:self action:@selector(dropdownTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(12, 0, self.bounds.size.width - 36, self.bounds.size.height);
    _arrowLabel.frame = CGRectMake(self.bounds.size.width - 24, 0, 18, self.bounds.size.height);
}

- (void)setSelectedIndex:(NSInteger)index {
    if (index >= 0 && index < _options.count) {
        _selectedIndex = index;
        _titleLabel.text = _options[index];
    }
}

- (void)dropdownTapped {
    if (_menuRef) {
        [_menuRef showDropdownPickerFor:self];
    }
}
@end

@implementation BrazilixMenu

static BrazilixMenu *extraInfo;
static BOOL MenDeal = NO;
UIWindow *mainWindow;
Vars_t Vars;
game_sdk_t *game_sdk = new game_sdk_t();

extern "C" void initAntiCheatBypass() __attribute__((weak));

+ (void)load {
    if (&initAntiCheatBypass != NULL) {
        initAntiCheatBypass();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initStandaloneUI];
    });
}

+ (void)initStandaloneUI {
    mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        if (windows.count > 0) mainWindow = windows.firstObject;
    }
    
    extraInfo = [BrazilixMenu new];
    if (game_sdk) game_sdk->init();
    [extraInfo setupDisplayLink];
    [extraInfo initTapGes];
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
    
    // Spacious, enlarged dimensions for comfort and full readability
    CGFloat menuWidth = 470.0f;
    CGFloat menuHeight = 340.0f;
    CGFloat x = (kWidth - menuWidth) * 0.5f;
    CGFloat y = (kHeight - menuHeight) * 0.5f;
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    _menuView.backgroundColor = UI_COLOR_MAIN_BG;
    _menuView.layer.cornerRadius = 12.0f;
    _menuView.layer.borderWidth = 1.0f;
    _menuView.layer.borderColor = [UIColor colorWithRed:25.0/255.0 green:33.0/255.0 blue:52.0/255.0 alpha:0.9].CGColor;
    _menuView.clipsToBounds = YES;
    _menuView.hidden = YES;
    _menuView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_menuView addGestureRecognizer:panGesture];
    
    if (mainWindow) [mainWindow addSubview:_menuView];
    
    // --- 1. Left Sidebar with Empty Space below Settings ---
    CGFloat sidebarWidth = 84.0f;
    _sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, menuHeight)];
    _sidebarView.backgroundColor = UI_COLOR_SIDEBAR_BG;
    [_menuView addSubview:_sidebarView];
    
    _tabButtons = [NSMutableArray new];
    _tabIconViews = [NSMutableArray new];
    _tabActiveBgs = [NSMutableArray new];
    _tabIndicators = [NSMutableArray new];
    
    NSArray *tabNames = @[@"Aimbot", @"Visuals", @"Misc", @"Settings"];
    
    CGFloat tabH = 56.0f; // Fixed height so the bottom is empty space!
    for (int i = 0; i < tabNames.count; i++) {
        UIButton *tabBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        tabBtn.frame = CGRectMake(0, i * tabH, sidebarWidth, tabH);
        tabBtn.tag = i;
        [tabBtn addTarget:self action:@selector(tabClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // Active rounded item background
        UIView *activeBg = [[UIView alloc] initWithFrame:CGRectMake(5, 5, sidebarWidth - 10, tabH - 10)];
        activeBg.backgroundColor = UI_COLOR_TAB_ACTIVE;
        activeBg.layer.cornerRadius = 7.0f;
        activeBg.hidden = (i != 0);
        activeBg.userInteractionEnabled = NO;
        [tabBtn addSubview:activeBg];
        [_tabActiveBgs addObject:activeBg];
        
        // Line-art Icon (No colorful emoji)
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, sidebarWidth, 20)];
        iconView.contentMode = UIViewContentModeCenter;
        iconView.userInteractionEnabled = NO;
        [tabBtn addSubview:iconView];
        [_tabIconViews addObject:iconView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, sidebarWidth, 18)];
        nameLabel.text = tabNames[i];
        nameLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        nameLabel.textColor = (i == 0) ? [UIColor whiteColor] : UI_COLOR_TEXT_MUTED;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.tag = 102;
        nameLabel.userInteractionEnabled = NO;
        [tabBtn addSubview:nameLabel];
        
        // Right vertical blue indicator bar
        UIView *ind = [[UIView alloc] initWithFrame:CGRectMake(sidebarWidth - 3.5f, 12, 3.5f, tabH - 24)];
        ind.backgroundColor = UI_COLOR_ACCENT;
        ind.layer.cornerRadius = 1.75f;
        ind.hidden = (i != 0); // Default to Aimbot
        ind.userInteractionEnabled = NO;
        [tabBtn addSubview:ind];
        
        [_sidebarView addSubview:tabBtn];
        [_tabButtons addObject:tabBtn];
        [_tabIndicators addObject:ind];
    }
    
    // --- 2. Right Content Header Pill Bar (Named Fluorite Max) ---
    CGFloat contentX = sidebarWidth;
    CGFloat contentW = menuWidth - sidebarWidth;
    CGFloat headerMargin = 12.0f;
    CGFloat headerW = contentW - (headerMargin * 2);
    CGFloat headerH = 34.0f;
    
    _headerPillView = [[UIView alloc] initWithFrame:CGRectMake(contentX + headerMargin, 10, headerW, headerH)];
    _headerPillView.backgroundColor = UI_COLOR_HEADER_BG;
    _headerPillView.layer.cornerRadius = 6.0f;
    _headerPillView.layer.borderWidth = 0.8f;
    _headerPillView.layer.borderColor = UI_COLOR_HEADER_BORDER.CGColor;
    [_menuView addSubview:_headerPillView];
    
    _headerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 18, 18)];
    _headerIconView.contentMode = UIViewContentModeCenter;
    [_headerPillView addSubview:_headerIconView];
    
    _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 7, 70, 20)];
    _headerTitleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    _headerTitleLabel.textColor = UI_COLOR_ACCENT;
    [_headerPillView addSubview:_headerTitleLabel];
    
    _headerDividerLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 7, 8, 20)];
    _headerDividerLabel.text = @"|";
    _headerDividerLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    _headerDividerLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:50.0/255.0 blue:72.0/255.0 alpha:1.0];
    [_headerPillView addSubview:_headerDividerLabel];
    
    _headerSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(124, 7, headerW - 130, 20)];
    _headerSubLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightMedium];
    _headerSubLabel.textColor = UI_COLOR_TEXT_MAIN;
    _headerSubLabel.text = @"Fluorite Max";
    _headerSubLabel.adjustsFontSizeToFitWidth = YES;
    _headerSubLabel.minimumScaleFactor = 0.75f;
    [_headerPillView addSubview:_headerSubLabel];
    
    // --- 3. Content Tabs Container ---
    CGFloat contentTop = 50.0f;
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
    
    // Build Interactive Dropdown Picker Overlay
    [self setupPickerOverlay];
    
    // Select Aimbot by default
    [self selectTab:0];
}

// ===== DROPDOWN PICKER OVERLAY MODAL =====
- (void)setupPickerOverlay {
    _pickerOverlayView = [[UIView alloc] initWithFrame:_menuView.bounds];
    _pickerOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65f];
    _pickerOverlayView.hidden = YES;
    _pickerOverlayView.userInteractionEnabled = YES;
    
    // Dismiss on background tap
    UITapGestureRecognizer *tapBg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDropdownPicker)];
    [_pickerOverlayView addGestureRecognizer:tapBg];
    
    // Picker Center Card
    CGFloat cardW = 280.0f;
    CGFloat cardH = 190.0f;
    _pickerCardView = [[UIView alloc] initWithFrame:CGRectMake((_menuView.bounds.size.width - cardW)/2, (_menuView.bounds.size.height - cardH)/2, cardW, cardH)];
    _pickerCardView.backgroundColor = [UIColor colorWithRed:14.0/255.0 green:18.0/255.0 blue:30.0/255.0 alpha:0.98];
    _pickerCardView.layer.cornerRadius = 10.0f;
    _pickerCardView.layer.borderWidth = 1.0f;
    _pickerCardView.layer.borderColor = UI_COLOR_BOX_BORDER.CGColor;
    _pickerCardView.clipsToBounds = YES;
    [_pickerOverlayView addSubview:_pickerCardView];
    
    // Header Bar
    UIView *cardHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cardW, 34)];
    cardHeader.backgroundColor = UI_COLOR_HEADER_BG;
    [_pickerCardView addSubview:cardHeader];
    
    _pickerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, cardW - 45, 22)];
    _pickerTitleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    _pickerTitleLabel.textColor = UI_COLOR_ACCENT;
    [cardHeader addSubview:_pickerTitleLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(cardW - 32, 3, 28, 28);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:UI_COLOR_TEXT_MUTED forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    [closeBtn addTarget:self action:@selector(hideDropdownPicker) forControlEvents:UIControlEventTouchUpInside];
    [cardHeader addSubview:closeBtn];
    
    // Scrollable Options List
    _pickerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 34, cardW, cardH - 34)];
    _pickerScrollView.showsVerticalScrollIndicator = YES;
    _pickerScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [_pickerCardView addSubview:_pickerScrollView];
    
    [_menuView addSubview:_pickerOverlayView];
}

- (void)showDropdownPickerFor:(CustomDropdown *)dropdown {
    _activeDropdown = dropdown;
    _pickerTitleLabel.text = dropdown.dropdownHeader ? dropdown.dropdownHeader : @"Select Option";
    
    // Clear old buttons
    for (UIView *v in _pickerScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    CGFloat py = 6.0f;
    CGFloat btnW = _pickerCardView.bounds.size.width - 16.0f;
    CGFloat btnH = 32.0f;
    
    for (int i = 0; i < dropdown.options.count; i++) {
        NSString *opt = dropdown.options[i];
        BOOL isSel = (i == dropdown.selectedIndex);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(8, py, btnW, btnH);
        btn.tag = i;
        btn.layer.cornerRadius = 5.0f;
        btn.backgroundColor = isSel ? UI_COLOR_ACCENT : UI_COLOR_BOX_BG;
        
        UILabel *textL = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, btnW - 40, btnH)];
        textL.text = opt;
        textL.font = [UIFont systemFontOfSize:12 weight:isSel ? UIFontWeightBold : UIFontWeightRegular];
        textL.textColor = [UIColor whiteColor];
        textL.userInteractionEnabled = NO;
        [btn addSubview:textL];
        
        if (isSel) {
            UILabel *chk = [[UILabel alloc] initWithFrame:CGRectMake(btnW - 28, 0, 20, btnH)];
            chk.text = @"✓";
            chk.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
            chk.textColor = [UIColor whiteColor];
            chk.textAlignment = NSTextAlignmentCenter;
            chk.userInteractionEnabled = NO;
            [btn addSubview:chk];
        }
        
        [btn addTarget:self action:@selector(pickerOptionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerScrollView addSubview:btn];
        py += btnH + 5.0f;
    }
    
    _pickerScrollView.contentSize = CGSizeMake(_pickerCardView.bounds.size.width, py + 6.0f);
    
    // Resize card dynamically if fewer options
    CGFloat targetCardH = MIN(py + 40.0f, 200.0f);
    _pickerCardView.frame = CGRectMake((_menuView.bounds.size.width - 280.0f)/2, (_menuView.bounds.size.height - targetCardH)/2, 280.0f, targetCardH);
    _pickerScrollView.frame = CGRectMake(0, 34, 280.0f, targetCardH - 34);
    
    _pickerOverlayView.hidden = NO;
    [_menuView bringSubviewToFront:_pickerOverlayView];
}

- (void)pickerOptionSelected:(UIButton *)sender {
    if (_activeDropdown) {
        [_activeDropdown setSelectedIndex:sender.tag];
        if (_activeDropdown.onSelectionChanged) {
            _activeDropdown.onSelectionChanged(_activeDropdown.options[sender.tag], sender.tag);
        }
    }
    [self hideDropdownPicker];
}

- (void)hideDropdownPicker {
    _pickerOverlayView.hidden = YES;
    _activeDropdown = nil;
}

// ===== TAB 0: AIMBOT VIEW (ENRICHED & CLEANED) =====
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
    
    // Aiming method (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Aiming method" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *aimMethodDrop = [[CustomDropdown alloc] initWithHeader:@"Aiming Method" options:@[@"Silent aimbot", @"Memory aimbot", @"Legit / Camera aim", @"Touch simulation"] defaultIndex:0 menu:self];
    aimMethodDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:aimMethodDrop];
    py += 38;
    
    // Show FOV circle with right color swatch
    CustomCheckbox *fovCheck = [[CustomCheckbox alloc] initWithTitle:@"Show FOV circle" checked:YES];
    fovCheck.frame = CGRectMake(px, py, pw - 35, 26);
    [sv addSubview:fovCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 24, py + 3, 24, 18)]];
    py += 32;
    
    // FOV Radius Slider
    [sv addSubview:[self makeSliderRow:@"FOV radius" value:@"60.0°" defaultVal:0.35f y:&py width:pw x:px]];
    
    // Lock-on Speed Slider
    [sv addSubview:[self makeSliderRow:@"Lock-on speed" value:@"0.0" defaultVal:0.0f y:&py width:pw x:px]];
    
    // Max Distance Slider
    [sv addSubview:[self makeSliderRow:@"Max aim distance" value:@"120.0m" defaultVal:0.40f y:&py width:pw x:px]];
    
    // Ignore types (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Ignore types" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *ignoreDrop = [[CustomDropdown alloc] initWithHeader:@"Ignore Types" options:@[@"Invisible, Knocked", @"Invisible only", @"Knocked only", @"Teammates only", @"None"] defaultIndex:0 menu:self];
    ignoreDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:ignoreDrop];
    py += 38;
    
    // Hitbox (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Hitbox" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *hitboxDrop = [[CustomDropdown alloc] initWithHeader:@"Hitbox Priority" options:@[@"Head", @"Neck", @"Chest / Body", @"Nearest bone"] defaultIndex:0 menu:self];
    hitboxDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:hitboxDrop];
    py += 38;
    
    // Target priority (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Target priority" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *priorityDrop = [[CustomDropdown alloc] initWithHeader:@"Target Priority" options:@[@"Closest to crosshair", @"Lowest health", @"Closest distance", @"Most visible"] defaultIndex:0 menu:self];
    priorityDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:priorityDrop];
    py += 38;
    
    // Force Lock
    CustomCheckbox *forceLock = [[CustomCheckbox alloc] initWithTitle:@"Force lock-on" checked:NO];
    forceLock.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:forceLock];
    py += 32;
    
    // Auto-fire
    CustomCheckbox *autoShoot = [[CustomCheckbox alloc] initWithTitle:@"Auto-fire when locked" checked:NO];
    autoShoot.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:autoShoot];
    py += 32;
    
    // Visible check
    CustomCheckbox *visCheck = [[CustomCheckbox alloc] initWithTitle:@"Visible target check" checked:YES];
    visCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:visCheck];
    py += 36;
    
    sv.contentSize = CGSizeMake(w, py + 15);
    return sv;
}

// ===== TAB 1: VISUALS VIEW (ENRICHED WITH REALISTIC FEATURES) =====
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
    _lineCheck.frame = CGRectMake(px, py, pw - 35, 26);
    _lineCheck.onToggle = ^(BOOL checked) {
        Vars.lines = checked;
    };
    [sv addSubview:_lineCheck];
    [sv addSubview:[self makeColorSwatch:[UIColor whiteColor] frame:CGRectMake(px + pw - 24, py + 3, 24, 18)]];
    py += 32;
    
    // Snapline Origin (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Line origin" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *linePosDrop = [[CustomDropdown alloc] initWithHeader:@"Line Origin" options:@[@"Bottom screen", @"Center / Crosshair", @"Top screen"] defaultIndex:0 menu:self];
    linePosDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:linePosDrop];
    py += 38;
    
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
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:255.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 52, py + 3, 22, 18)]];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:25.0/255.0 green:225.0/255.0 blue:55.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 24, py + 3, 22, 18)]];
    py += 32;
    
    // Box Style (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Box style" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *boxStyleDrop = [[CustomDropdown alloc] initWithHeader:@"Box Style" options:@[@"2D Full Box", @"Corner Box", @"Filled Box", @"3D Bounding Box"] defaultIndex:0 menu:self];
    boxStyleDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:boxStyleDrop];
    py += 38;
    
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
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:24.0/255.0 green:60.0/255.0 blue:255.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 52, py + 3, 22, 18)]];
    [sv addSubview:[self makeColorSwatch:[UIColor colorWithRed:25.0/255.0 green:225.0/255.0 blue:55.0/255.0 alpha:1.0] frame:CGRectMake(px + pw - 24, py + 3, 22, 18)]];
    py += 34;
    
    // Skeleton bone thickness slider (2.0)
    [sv addSubview:[self makeSliderRow:@"Skeleton bone thickness" value:@"2.0" defaultVal:0.4f y:&py width:pw x:px]];
    
    // Head Circle
    CustomCheckbox *headCircle = [[CustomCheckbox alloc] initWithTitle:@"Head circle / dot" checked:NO];
    headCircle.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:headCircle];
    py += 32;
    
    // Item / Loot ESP
    CustomCheckbox *itemESP = [[CustomCheckbox alloc] initWithTitle:@"Weapons & Loot ESP" checked:NO];
    itemESP.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:itemESP];
    py += 32;
    
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
    
    CustomCheckbox *aspectCheck = [[CustomCheckbox alloc] initWithTitle:@"Aspect ratio (iPad View)" checked:NO];
    aspectCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:aspectCheck];
    py += 32;
    
    // Aspect ratio FOV scale slider
    [sv addSubview:[self makeSliderRow:@"Camera zoom scale" value:@"1.2x" defaultVal:0.2f y:&py width:pw x:px]];
    
    CustomCheckbox *autoFireCheck = [[CustomCheckbox alloc] initWithTitle:@"Auto-fire" checked:NO];
    autoFireCheck.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:autoFireCheck];
    py += 30;
    
    CustomCheckbox *fastSwitch = [[CustomCheckbox alloc] initWithTitle:@"Fast weapon switch" checked:NO];
    fastSwitch.frame = CGRectMake(px, py, pw, 26);
    [sv addSubview:fastSwitch];
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
    
    // Language (Interactive Dropdown)
    [sv addSubview:[self makeLabel:@"Language" frame:CGRectMake(px, py, pw, 18)]];
    py += 20;
    CustomDropdown *langDrop = [[CustomDropdown alloc] initWithHeader:@"Language" options:@[@"English", @"Español", @"Português", @"Русский", @"العربية", @"বাংলা"] defaultIndex:0 menu:self];
    langDrop.frame = CGRectMake(px, py, pw, 30);
    [sv addSubview:langDrop];
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

- (UIView *)makeColorSwatch:(UIColor *)color frame:(CGRect)frame {
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.backgroundColor = color;
    v.layer.cornerRadius = 4.0f;
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
    
    NSArray *titles = @[@"AIMBOT", @"VISUALS", @"MISC", @"SETTINGS"];
    
    CGSize iconSize = CGSizeMake(18, 18);
    UIImage *activeHeaderIcon = nil;
    if (index == 0) activeHeaderIcon = [IconHelper drawAimbotIconWithColor:UI_COLOR_ACCENT size:iconSize];
    else if (index == 1) activeHeaderIcon = [IconHelper drawVisualsIconWithColor:UI_COLOR_ACCENT size:iconSize];
    else if (index == 2) activeHeaderIcon = [IconHelper drawMiscIconWithColor:UI_COLOR_ACCENT size:iconSize];
    else activeHeaderIcon = [IconHelper drawSettingsIconWithColor:UI_COLOR_ACCENT size:iconSize];
    
    _headerIconView.image = activeHeaderIcon;
    _headerTitleLabel.text = titles[index];
    _headerSubLabel.text = @"Fluorite Max";
    
    // Auto adjust header title width based on text
    CGFloat titleW = (index == 3) ? 75.0f : ((index == 1) ? 68.0f : ((index == 0) ? 62.0f : 44.0f));
    _headerTitleLabel.frame = CGRectMake(36, 7, titleW, 20);
    _headerDividerLabel.frame = CGRectMake(36 + titleW + 6, 7, 8, 20);
    CGFloat subX = 36 + titleW + 18;
    _headerSubLabel.frame = CGRectMake(subX, 7, _headerPillView.bounds.size.width - subX - 8, 20);
    
    // Update Sidebar tabs
    CGSize tabIconSize = CGSizeMake(20, 20);
    for (int i = 0; i < _tabButtons.count; i++) {
        UIButton *btn = _tabButtons[i];
        UIView *bg = _tabActiveBgs[i];
        UIView *ind = _tabIndicators[i];
        UIImageView *iconV = _tabIconViews[i];
        UILabel *nameL = [btn viewWithTag:102];
        
        BOOL isActive = (i == index);
        UIColor *iconColor = isActive ? [UIColor whiteColor] : UI_COLOR_TEXT_MUTED;
        
        if (i == 0) iconV.image = [IconHelper drawAimbotIconWithColor:iconColor size:tabIconSize];
        else if (i == 1) iconV.image = [IconHelper drawVisualsIconWithColor:iconColor size:tabIconSize];
        else if (i == 2) iconV.image = [IconHelper drawMiscIconWithColor:iconColor size:tabIconSize];
        else if (i == 3) iconV.image = [IconHelper drawSettingsIconWithColor:iconColor size:tabIconSize];
        
        if (isActive) {
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
    
    if (Vars.Enable) {
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

// ===== GAME SDK INITIALIZATION =====
void game_sdk_t::init()
{
    uintptr_t base = getAbsoluteAddress("UnityFramework", 0);
    if (base == 0) {
        this->isReady = false;
        return;
    }

    this->get_camera = (void *(*)())getRealOffset(0x918E4D0);
    this->WorldToScreenPoint = (Vector3(*)(void *, Vector3))getRealOffset(0x918DDDC);
    this->Component_GetTransform = (void *(*)(void *))getRealOffset(0x91E7DD0);
    this->get_position = (Vector3(*)(void *))getRealOffset(0x91FA058);
    this->GetForward = (Vector3(*)(void *))getRealOffset(0x91FAA50);

    this->name = (monoString *(*)(void *))getRealOffset(0x53EC2B8);
    this->get_IsDieing = (bool (*)(void *))getRealOffset(0x53D6C7C);
    this->get_isLocalTeam = (bool (*)(void *))getRealOffset(0x54101A8);

    this->GetHeadTF = (void *(*)(void *))getRealOffset(0x54828CC);
    this->GetHipTF = (void *(*)(void *))getRealOffset(0x5482A7C);
    this->GetLeftAnkleTF = (void *(*)(void *))getRealOffset(0x5482ECC);
    this->GetRightAnkleTF = (void *(*)(void *))getRealOffset(0x5482FD8);
    this->GetLeftToeTF = (void *(*)(void *))getRealOffset(0x54830E4);
    this->GetRightToeTF = (void *(*)(void *))getRealOffset(0x54831F0);

    this->GetCurrentMatch = (void *(*)())getRealOffset(0x55F1F84);
    this->GetPlayerList = (monoList<void **>*(*)(void *))getRealOffset(0x5669EE8);
    this->GetLocalPlayer = (void *(*)(void *))getRealOffset(0x563B718);

    this->isReady = true;
}

// ===== STANDALONE APP DELEGATE FOR IPA EXECUTION =====
@interface StandaloneAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation StandaloneAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:10.0/255.0 blue:16.0/255.0 alpha:1.0];
    
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    // Background demo wallpaper/game scene simulation
    UILabel *bgLabel = [[UILabel alloc] initWithFrame:self.window.bounds];
    bgLabel.text = @"Fluorite Max • Standalone Engine";
    bgLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    bgLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    bgLabel.textAlignment = NSTextAlignmentCenter;
    [rootVC.view addSubview:bgLabel];
    
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height - 40, self.window.bounds.size.width, 30)];
    hintLabel.text = @"Tap with 2 fingers to Toggle Menu • Drag to Move";
    hintLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.35];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    [rootVC.view addSubview:hintLabel];
    
    mainWindow = self.window;
    
    // Automatically initialize and display Menu
    BrazilixMenu *menu = [BrazilixMenu new];
    [menu setupDisplayLink];
    [menu initTapGes];
    [menu openMenu];
    
    return YES;
}
@end

#ifndef TWEAK_COMPILATION
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([StandaloneAppDelegate class]));
    }
}
#endif

