#import <UIKit/UIKit.h>

@interface BrazilixMenu : NSObject
- (void)setupDisplayLink;
- (void)initTapGes;
- (void)openMenu;
@end

@interface FluoriteAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation FluoriteAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:10.0/255.0 blue:16.0/255.0 alpha:1.0];
    
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    // Background branding & guidance
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height * 0.35, self.window.bounds.size.width, 40)];
    titleLabel.text = @"Fluorite Max • Standalone Engine";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:229.0/255.0 blue:255.0/255.0 alpha:0.8];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [rootVC.view addSubview:titleLabel];
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height * 0.35 + 45, self.window.bounds.size.width, 25)];
    subLabel.text = @"Double tap with two fingers to toggle menu";
    subLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    subLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    subLabel.textAlignment = NSTextAlignmentCenter;
    [rootVC.view addSubview:subLabel];
    
    // Initialize Fluorite Max Menu directly
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BrazilixMenu *menu = [BrazilixMenu new];
        [menu setupDisplayLink];
        [menu initTapGes];
        [menu openMenu];
    });
    
    return YES;
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FluoriteAppDelegate class]));
    }
}
