#pragma once
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "UnityTypes.h"
#import "Vector3.h"
#import "Vector2.h"
#import "MemoryUtils.h"

// ===== BASIC STRUCTURES =====
struct SimpleVec2 {
    float x, y;
    SimpleVec2() : x(0), y(0) {}
    SimpleVec2(float x, float y) : x(x), y(y) {}
};

#define kUnifiedRedColor [UIColor redColor].CGColor

// ===== SIMPLIFIED VARIABLES =====
struct Vars_t
{
    bool Enable = false;
    bool lines = false;
    bool Box = false;
    bool Name = false;
    bool Health = false;
    bool Distance = false;
    bool skeleton = false;
    bool counts = false;
    bool NoFog = false;
} Vars;

// ===== GAME SDK =====
class game_sdk_t
{
public:
    bool isReady;
    void init();
    void *(*get_camera)();
    Vector3 (*WorldToScreenPoint)(void *, Vector3);
    void *(*Component_GetTransform)(void *player);
    Vector3 (*get_position)(void *player);
    Vector3 (*GetForward)(void *player);
    
    // Player Methods
    monoString *(*name)(void *player);
    bool (*get_IsDieing)(void *player);
    bool (*get_isLocalTeam)(void *player);
    
    // Bone Transforms
    void *(*GetHeadTF)(void *);
    void *(*GetHipTF)(void *);
    void *(*GetLeftAnkleTF)(void *);
    void *(*GetRightAnkleTF)(void *);
    void *(*GetLeftToeTF)(void *);
    void *(*GetRightToeTF)(void *);
    
    // Match / Players List
    monoList<void **> *(*GetPlayerList)();
    void *(*GetLocalPlayer)();
};

extern game_sdk_t *game_sdk;

// ===== SAFE WORLD TO SCREEN HELPER =====
namespace Camera$$WorldToScreen
{
    inline SimpleVec2 Regular(Vector3 pos)
    {
        if (!game_sdk || !game_sdk->isReady || !game_sdk->get_camera || !game_sdk->WorldToScreenPoint) return SimpleVec2(0, 0);
        
        void *cam = game_sdk->get_camera();
        if (!cam) return SimpleVec2(0, 0);
        
        Vector3 worldPoint = game_sdk->WorldToScreenPoint(cam, pos);
        if (worldPoint.z < 0.01f) return SimpleVec2(0, 0);

        CGRect screenBounds = [UIScreen mainScreen].nativeBounds;
        CGFloat screenWidth = screenBounds.size.width / [UIScreen mainScreen].nativeScale;
        CGFloat screenHeight = screenBounds.size.height / [UIScreen mainScreen].nativeScale;
        
        if (screenWidth < screenHeight) {
            CGFloat temp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = temp;
        }

        float lx = screenWidth * worldPoint.x;
        float ly = screenHeight * (1.0f - worldPoint.y);
        
        return SimpleVec2(lx, ly);
    }
}

// ===== SAFE HELPERS =====
inline Vector3 getPosition(void *transformOrPlayer)
{
    if (!transformOrPlayer || !game_sdk || !game_sdk->isReady) return Vector3();
    if (!game_sdk->Component_GetTransform || !game_sdk->get_position) return Vector3();
    void *tf = game_sdk->Component_GetTransform(transformOrPlayer);
    if (!tf) return Vector3();
    return game_sdk->get_position(tf);
}

inline Vector3 GetBonePosition(void *player, void *(*transformGetter)(void *)) {
    if (!player || !transformGetter || !game_sdk || !game_sdk->isReady) return Vector3();
    void *transform = transformGetter(player);
    if (!transform) return Vector3();
    if (!game_sdk->Component_GetTransform || !game_sdk->get_position) return Vector3();
    void *tf = game_sdk->Component_GetTransform(transform);
    return tf ? game_sdk->get_position(tf) : Vector3();
}

// ===== OPTIMIZED ESP RENDERER =====
@interface ESPRenderer : NSObject
@property (nonatomic, strong) CAShapeLayer *espLayer;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *textPool;
@property (nonatomic, strong) NSMutableArray<CALayer *> *healthPool;
@property (nonatomic, assign) int textUsedCount;
@property (nonatomic, assign) int healthUsedCount;

+ (instancetype)sharedInstance;
- (void)renderOnView:(UIView *)view;
- (void)clearDrawings;
- (void)drawBoxFrom:(SimpleVec2)min to:(SimpleVec2)max path:(UIBezierPath *)path;
- (void)drawLineFrom:(SimpleVec2)from to:(SimpleVec2)to path:(UIBezierPath *)path;
- (void)drawTextAt:(SimpleVec2)position text:(NSString*)text;
- (void)drawHealthBarAt:(SimpleVec2)min to:(SimpleVec2)max multiplier:(float)multiplier;
@end

@implementation ESPRenderer

+ (instancetype)sharedInstance {
    static ESPRenderer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _espLayer = [CAShapeLayer layer];
        _espLayer.name = @"ESP_Layer_Optimized";
        _espLayer.fillColor = [UIColor clearColor].CGColor;
        _espLayer.strokeColor = kUnifiedRedColor;
        _espLayer.lineWidth = 1.2f;
        _textPool = [NSMutableArray new];
        _healthPool = [NSMutableArray new];
    }
    return self;
}

- (void)renderOnView:(UIView *)view {
    if (!view) return;
    if (!_containerView || _containerView != view) {
        _containerView = view;
        [_containerView.layer addSublayer:_espLayer];
    }
    _espLayer.frame = view.bounds;
    _textUsedCount = 0;
    _healthUsedCount = 0;
}

- (void)clearDrawings {
    _espLayer.path = nil;
    for (CATextLayer *layer in _textPool) layer.hidden = YES;
    for (CALayer *layer in _healthPool) layer.hidden = YES;
}

- (void)drawBoxFrom:(SimpleVec2)min to:(SimpleVec2)max path:(UIBezierPath *)path {
    if (!path) return;
    [path moveToPoint:CGPointMake(min.x, min.y)];
    [path addLineToPoint:CGPointMake(max.x, min.y)];
    [path addLineToPoint:CGPointMake(max.x, max.y)];
    [path addLineToPoint:CGPointMake(min.x, max.y)];
    [path closePath];
}

- (void)drawLineFrom:(SimpleVec2)from to:(SimpleVec2)to path:(UIBezierPath *)path {
    if (!path) return;
    [path moveToPoint:CGPointMake(from.x, from.y)];
    [path addLineToPoint:CGPointMake(to.x, to.y)];
}

- (void)drawTextAt:(SimpleVec2)position text:(NSString*)text {
    if (!text || !_containerView) return;
    CATextLayer *textLayer;
    if (_textUsedCount < _textPool.count) {
        textLayer = _textPool[_textUsedCount];
    } else {
        textLayer = [CATextLayer layer];
        textLayer.fontSize = 9.0f;
        textLayer.foregroundColor = kUnifiedRedColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        [_containerView.layer addSublayer:textLayer];
        [_textPool addObject:textLayer];
    }
    textLayer.string = text;
    textLayer.hidden = NO;
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:9.0f]}];
    textLayer.frame = CGRectMake(position.x - textSize.width/2, position.y, textSize.width + 4, textSize.height + 2);
    _textUsedCount++;
}

- (void)drawHealthBarAt:(SimpleVec2)min to:(SimpleVec2)max multiplier:(float)multiplier {
    if (!_containerView) return;
    CALayer *bgLayer;
    CALayer *fgLayer;
    int index = _healthUsedCount * 2;
    
    if (index + 1 < _healthPool.count) {
        bgLayer = _healthPool[index];
        fgLayer = _healthPool[index + 1];
    } else {
        bgLayer = [CALayer layer];
        bgLayer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8].CGColor;
        [_containerView.layer addSublayer:bgLayer];
        [_healthPool addObject:bgLayer];
        
        fgLayer = [CALayer layer];
        fgLayer.backgroundColor = kUnifiedRedColor;
        [_containerView.layer addSublayer:fgLayer];
        [_healthPool addObject:fgLayer];
    }
    
    float height = max.y - min.y;
    bgLayer.frame = CGRectMake(min.x, min.y, 2, height);
    fgLayer.frame = CGRectMake(min.x, max.y - (height * multiplier), 2, height * multiplier);
    bgLayer.hidden = NO;
    fgLayer.hidden = NO;
    _healthUsedCount++;
}

@end

// ===== MAIN SAFE ESP FUNCTION =====
inline void get_players()
{
    if (!game_sdk || !game_sdk->isReady) return;
    if (!Vars.Enable) {
        [[ESPRenderer sharedInstance] clearDrawings];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!Vars.Enable) {
            [[ESPRenderer sharedInstance] clearDrawings];
            return;
        }

        // Optional Fog control
        if (Vars.NoFog) {
            void *setFogAddr = (void*)getRealOffset(0x91AAAE4);
            if (setFogAddr) ((void (*)(bool))setFogAddr)(false);
        }

        if (!game_sdk->GetPlayerList) return;
        monoList<void **> *players = game_sdk->GetPlayerList();
        if (!players || !players->getItems() || players->getSize() <= 0) {
            [[ESPRenderer sharedInstance] clearDrawings];
            return;
        }

        void *local_player = game_sdk->GetLocalPlayer ? game_sdk->GetLocalPlayer() : nullptr;

        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;

        ESPRenderer *renderer = [ESPRenderer sharedInstance];
        [renderer renderOnView:keyWindow];
        [renderer clearDrawings];

        UIBezierPath *combinedPath = [UIBezierPath bezierPath];
        Vector3 localPos = local_player ? getPosition(local_player) : Vector3();
        int drawnCount = 0;
        int totalEnemies = 0;

        CGRect screenBounds = [UIScreen mainScreen].nativeBounds;
        CGFloat sW = screenBounds.size.width / [UIScreen mainScreen].nativeScale;
        CGFloat sH = screenBounds.size.height / [UIScreen mainScreen].nativeScale;
        if (sW < sH) { CGFloat t = sW; sW = sH; sH = t; }

        SimpleVec2 lineStart(sW / 2.0f, sH - 15.0f);
        int totalPlayers = players->getSize();
        if (totalPlayers > 60) totalPlayers = 60; // Safety clamp

        for (int u = 0; u < totalPlayers; u++) {
            void *enemy = players->getItems()[u];
            if (!enemy || enemy == local_player) continue;
            
            // Check teammate and dying
            if (game_sdk->get_isLocalTeam && game_sdk->get_isLocalTeam(enemy)) continue;
            if (game_sdk->get_IsDieing && game_sdk->get_IsDieing(enemy)) continue;

            totalEnemies++;
            if (drawnCount >= 15) continue;

            Vector3 pos = getPosition(enemy);
            if (pos.x == 0 && pos.y == 0 && pos.z == 0) continue;

            float distance = (localPos.x != 0 || localPos.y != 0 || localPos.z != 0) ? Vector3::Distance(pos, localPos) : 0.0f;
            if (distance > 300.0f) continue;

            SimpleVec2 bot_pos = Camera$$WorldToScreen::Regular(pos);
            if (bot_pos.x == 0 && bot_pos.y == 0) continue;

            SimpleVec2 top_pos = Camera$$WorldToScreen::Regular(pos + Vector3(0, 1.8f, 0));
            float height = fabsf(bot_pos.y - top_pos.y);
            if (height < 5.0f || height > sH * 1.5f) continue;
            float width = height / 2.0f;

            if (Vars.Box) {
                [renderer drawBoxFrom:SimpleVec2(bot_pos.x - width/2, top_pos.y) to:SimpleVec2(bot_pos.x + width/2, bot_pos.y) path:combinedPath];
            }

            if (Vars.lines) {
                [renderer drawLineFrom:lineStart to:SimpleVec2(bot_pos.x, top_pos.y) path:combinedPath];
            }

            if (Vars.skeleton) {
                Vector3 headP = GetBonePosition(enemy, game_sdk->GetHeadTF);
                Vector3 hipP = GetBonePosition(enemy, game_sdk->GetHipTF);
                Vector3 lAnkP = GetBonePosition(enemy, game_sdk->GetLeftAnkleTF);
                Vector3 rAnkP = GetBonePosition(enemy, game_sdk->GetRightAnkleTF);
                
                SimpleVec2 sHead = Camera$$WorldToScreen::Regular(headP);
                SimpleVec2 sHip = Camera$$WorldToScreen::Regular(hipP);
                SimpleVec2 sLAnk = Camera$$WorldToScreen::Regular(lAnkP);
                SimpleVec2 sRAnk = Camera$$WorldToScreen::Regular(rAnkP);
                
                if (sHead.x != 0 && sHip.x != 0) {
                    [renderer drawLineFrom:sHead to:sHip path:combinedPath];
                    if (sLAnk.x != 0) [renderer drawLineFrom:sHip to:sLAnk path:combinedPath];
                    if (sRAnk.x != 0) [renderer drawLineFrom:sHip to:sRAnk path:combinedPath];
                }
            }

            if (Vars.Name && game_sdk->name) {
                monoString *pname = game_sdk->name(enemy);
                if (pname) {
                    NSString *nsName = pname->toNSString();
                    if (nsName && nsName.length > 0 && nsName.length < 32) {
                        [renderer drawTextAt:SimpleVec2(bot_pos.x, top_pos.y - 12) text:nsName];
                    }
                }
            }

            if (Vars.Distance && distance > 0.1f) {
                [renderer drawTextAt:SimpleVec2(bot_pos.x, bot_pos.y + 2) text:[NSString stringWithFormat:@"%.0fm", distance]];
            }

            drawnCount++;
        }

        if (Vars.counts) {
            [renderer drawTextAt:SimpleVec2(sW / 2, 40) text:[NSString stringWithFormat:@"Enemies: %d", totalEnemies]];
        }

        renderer.espLayer.path = combinedPath.CGPath;
    });
}
