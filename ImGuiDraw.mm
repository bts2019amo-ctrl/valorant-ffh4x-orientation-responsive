// Created by chunmod on 2025/05/12.
// Telegram: @chunmodvn

#import "ImGuiView.h"
#import <QuartzCore/QuartzCore.h>
#import "ImGuiDraw.h"
#import "ffh4x_login_logo_embedded.h"
#import "OBF/mahoa.h"
#import "fishhook/hook.h"
#import "fishhook/patch.h"
#include <vector>
#include <math.h>
#include <float.h>
#include "Other/nav_elements.h"
#include "Other/etc_elements.h"

#define kuan [UIScreen mainScreen].bounds.size.width // 1194
#define gao [UIScreen mainScreen].bounds.size.height // 834
#define Scalesi [UIScreen mainScreen].nativeScale


bool Masskill; 
enum heads {
    rage, antiaim, visuals, settings
};

enum sub_heads {
    general, accuracy, exploits, _general, advanced
};

static heads tab{ rage };
static sub_heads subtab{ general };

const ImColor tab_colors[3] = { ImColor(255, 0, 0), ImColor(255, 165, 0), ImColor(0, 128, 0) };

static uintptr_t moudule_base;

const char *CurrentHealthBar;
const char *MaxHealthBar;
const char *WorldAddress;
const char *kGetViewportSize;
const char *kProjectWorldLocationToScreen;
const char *kLineOfSight_1;
const char *kLineOfSight_2;
const char *kLineOfSight_3;
const char *kLineOfSight_4;
const char *kLineOfSight_5;

static Vector2 CanvasSize;
static CGSize screenSize;

static int totalEnemies, AItotalEnemies = 0;

static long GWorld, UName;
static long Character, WeaponID;
static long PlayerController, Pawn;
static long PlayerCameraManager;
static MinimalViewInfo POV;
static long ControlRotation;
static bool isFiring;
static bool isGunADS;
static int MyTeamId;
static int ZCMyTeamId;
static float (*GetHealth)(void *actor);
static float (*GetHealthMax)(void *actor);
static char PlayerName[100];
static float aimSpeed = 1.0f; // Tốc độ tự ngắm
static float AimBotFOV = 100.0f; // Phạm vi tự ngắm
static float wuzi;
static float yq = 0.0;
static FRotator aimRotation;
static float tDistance = 0;
static NSString *bundle;
static int ratioCustom = 3;





// Thêm vào khu vực định nghĩa biến bool khác

static NSTimer *offsetUpdateTimer = nil; // Thêm vào khu vực biến toàn cục, gọi địa chỉ server nền

static const char* GetBoneFTransformName(int index); // Tuyên bố hàm điểm đánh
bool isMenuVisible = true;
bool TeamCheckSwitch;
bool BattlefieldSwitch;

bool AIDisplay;
//bool BoxSwitch, HelmetArmorSwitch, PlayerName, DistanceSwitch, RaySwitch, HealthSwitch, SkeletonSwitch, NoChaseDowned;
bool BoxSwitch, HelmetArmorSwitch, PlayerNameSwitch, DistanceSwitch, HealthSwitch, SkeletonSwitch, NoChaseDowned;

bool NoRecoilSwitch, StrongholdSwitch;
bool CrateSwitch, CrateItems, MapItems;
bool TrackingSwitch;
bool AimBotSwitch;

bool LineSwitch;
// Thêm vào khu vực biến toàn cục:
static int selectedBoneIndex = 1; // Mặc định là 3 (ngực)
bool EnableSwitch;

float sliderValue1;
float sliderValue2;
float sliderValue3;
float sliderValue4;

typedef uintptr_t kaddr;
uintptr_t anogs;

// Estado exclusivamente visual da tela de autenticação.
static char proxyKay[128] = "";
static bool proxyKayVisible = false;
static bool proxyKaySubmitted = false;
static bool proxyKayError = false;
static bool proxyKayLoading = false;
static bool proxyKayAutoChecked = false;
static bool proxyKayClipboardChecked = false;
static bool proxyKayAlertShown = false;
static void ShowAccessKeyPrompt(void);
static NSString *proxyKayReason = nil;
static NSInteger proxyKayDaysLeft = 0;
static UIVisualEffectView *loginBlurView = nil;
static UITextField *loginInputField = nil;
static UIImageView *loginArtworkView = nil;
static UIView *loginSplashView = nil;
static UIProgressView *loginSplashProgress = nil;
static NSTimer *proxyKayExpiryTimer = nil;
static bool proxyKayPeriodicCheck = false;
static bool proxyLifecycleObserverInstalled = false;
static void ValidateProxyKeyAsync(const char *key);
static void ScheduleProxyKayExpiryCheck(void);
static void TryAutoPasteProxyKey(void);
static void InstallProxyLifecycleObserver(void) {
    if (proxyLifecycleObserverInstalled) return;
    proxyLifecycleObserverInstalled = true;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSArray<UIView *> *animatedViews = @[loginSplashView ?: [UIView new], loginArtworkView ?: [UIView new], loginBlurView ?: [UIView new]];
        for (UIView *view in animatedViews) {
            view.layer.speed = 1.0;
            view.layer.timeOffset = 0.0;
            view.layer.beginTime = 0.0;
            for (CALayer *sublayer in view.layer.sublayers) {
                sublayer.speed = 1.0;
                sublayer.timeOffset = 0.0;
                sublayer.beginTime = 0.0;
            }
        }
        for (UIView *subview in loginSplashView.subviews) {
            if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
                [(UIActivityIndicatorView *)subview startAnimating];
            }
        }
        if (loginSplashProgress != nil) {
            [loginSplashProgress setProgress:loginSplashProgress.progress animated:YES];
        }
    }];
}
static void ShowProxyKayAlert(BOOL valid, NSString *message, NSInteger daysLeft) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (proxyKayAlertShown) return;
        proxyKayAlertShown = true;
        UIWindow *window = nil;
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState == UISceneActivationStateUnattached) continue;
            for (UIWindow *candidate in windowScene.windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window != nil) break;
        }
        if (window == nil) window = [UIApplication sharedApplication].keyWindow;
        UIViewController *presenting = window.rootViewController;
        while (presenting.presentedViewController != nil) presenting = presenting.presentedViewController;
        if (presenting == nil) { proxyKayAlertShown = false; return; }
        NSString *title = valid ? @"Chave validada" : @"Chave inválida";
        NSString *body = message.length > 0 ? message : (valid ? @"Sua KAY foi validada com sucesso." : @"A KAY informada é inválida ou expirou.");
        if (valid && daysLeft > 0) body = [NSString stringWithFormat:@"%@\nDias restantes: %ld", body, (long)daysLeft];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
        alert.view.tintColor = [UIColor colorWithRed:1.0f green:0.035f blue:0.045f alpha:1.0f];
        UIAlertActionStyle style = valid ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive;
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:style handler:^(UIAlertAction *action) {
            proxyKayAlertShown = false;
        }]];
        [presenting presentViewController:alert animated:YES completion:^{
            alert.view.layer.cornerRadius = 24.0f;
            alert.view.layer.cornerCurve = kCACornerCurveContinuous;
            alert.view.layer.borderWidth = 1.0f;
            alert.view.layer.borderColor = [UIColor colorWithRed:1.0f green:0.035f blue:0.045f alpha:0.65f].CGColor;
            alert.view.layer.shadowColor = [UIColor redColor].CGColor;
            alert.view.layer.shadowOpacity = 0.55f;
            alert.view.layer.shadowRadius = 22.0f;
            alert.view.transform = CGAffineTransformMakeScale(0.86f, 0.86f);
            alert.view.alpha = 0.0f;
            [UIView animateWithDuration:0.42 delay:0.0 usingSpringWithDamping:0.78 initialSpringVelocity:0.55 options:UIViewAnimationOptionCurveEaseOut animations:^{
                alert.view.transform = CGAffineTransformIdentity;
                alert.view.alpha = 1.0f;
            } completion:nil];
        }];
    });
}
@interface ProxyLoginInputDelegate : NSObject <UITextFieldDelegate>
@end

@implementation ProxyLoginInputDelegate
- (void)inputChanged:(UITextField *)sender {
    NSString *value = sender.text ?: @"";
    strncpy(proxyKay, value.UTF8String, sizeof(proxyKay) - 1);
    proxyKay[sizeof(proxyKay) - 1] = '\0';
    proxyKayError = false;
    proxyKayReason = nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        ValidateProxyKeyAsync(proxyKay);
    } else {
        proxyKayError = true;
        proxyKayReason = @"Digite sua chave de acesso.";
    }
    return YES;
}
@end

static ProxyLoginInputDelegate *loginInputDelegate = nil;

bool IsProxyAuthenticated() {
    if (proxyKaySubmitted && !proxyKayError) {
        if (loginBlurView != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loginBlurView removeFromSuperview];
                loginBlurView = nil;
                [loginInputField resignFirstResponder];
                [loginInputField removeFromSuperview];
                loginInputField = nil;
                [loginArtworkView removeFromSuperview];
                loginArtworkView = nil;
            });
        }
        return true;
    }
    return false;
}

static void ValidateProxyKeyAsync(const char *key) {
    if (key == nullptr || key[0] == '\0' || proxyKayLoading) return;

    NSString *keyString = [[NSString alloc] initWithUTF8String:key];
    if (keyString.length == 0) return;

    proxyKayLoading = true;
    proxyKayError = false;
    proxyKayAlertShown = false;
    proxyKayReason = nil;

    NSString *escapedKey = [keyString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapedKey = [escapedKey stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSDictionary *jsonPayload = @{ @"0": @{ @"json": @{ @"key": escapedKey } } };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonPayload options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *encodedInput = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *urlString = [NSString stringWithFormat:@"https://proxysystem.org/api/trpc/android.validateKey?batch=1&input=%@", encodedInput ?: @""];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        proxyKayLoading = false;
        proxyKayError = true;
        proxyKayReason = @"URL da API inválida.";
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:10.0];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            proxyKayLoading = false;

            if (error != nil || data == nil) {
                proxyKaySubmitted = false;
                proxyKayError = true;
                proxyKayReason = @"Não foi possível conectar ao servidor.";
                return;
            }

            NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
            if (http.statusCode != 200) {
                proxyKaySubmitted = false;
                proxyKayError = true;
                proxyKayReason = [NSString stringWithFormat:@"Servidor retornou HTTP %ld.", (long)http.statusCode];
                return;
            }

            NSError *parseError = nil;
            id root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSDictionary *json = nil;
            if ([root isKindOfClass:[NSArray class]] && [(NSArray *)root count] > 0) {
                id first = [(NSArray *)root objectAtIndex:0];
                json = first[@"result"][@"data"][@"json"];
            }

            if (parseError != nil || ![json isKindOfClass:[NSDictionary class]]) {
                proxyKaySubmitted = false;
                proxyKayError = true;
                proxyKayReason = @"Resposta inválida da API.";
                return;
            }

            BOOL valid = [json[@"valid"] boolValue];
            proxyKayDaysLeft = [json[@"daysLeft"] integerValue];
            NSString *reason = [json[@"reason"] isKindOfClass:[NSString class]] ? json[@"reason"] : nil;

            if (valid) {
                proxyKaySubmitted = true;
                proxyKayError = false;
                proxyKayReason = nil;
                if (!proxyKayPeriodicCheck) {
                    ShowProxyKayAlert(YES, @"Sua KAY foi validada com sucesso.", proxyKayDaysLeft);
                }
                proxyKayPeriodicCheck = false;
                [[NSUserDefaults standardUserDefaults] setObject:keyString forKey:@"proxy_access_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                ScheduleProxyKayExpiryCheck();
            } else {
                proxyKaySubmitted = false;
                proxyKayError = true;
                proxyKayReason = reason.length > 0 ? reason : @"KAY inválida ou expirada.";
                proxyKayPeriodicCheck = false;
                proxyKayClipboardChecked = false;
                [proxyKayExpiryTimer invalidate];
                proxyKayExpiryTimer = nil;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"proxy_access_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                memset(proxyKay, 0, sizeof(proxyKay));
                ShowAccessKeyPrompt();
            }
        });
    }];
    [task resume];
}

// Function prototypes
void SaveSettings();
void LoadSettings();
void ToggleMenuVisibility();
void MyMenu();
void ReaMemData();
static void ValidateProxyKeyAsync(const char *key);
static void ScheduleProxyKayExpiryCheck(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [proxyKayExpiryTimer invalidate];
        proxyKayExpiryTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                                repeats:YES
                                                                  block:^(NSTimer *timer) {
            if (!proxyKaySubmitted || proxyKayError || proxyKayLoading || proxyKay[0] == '\0') return;
            proxyKayPeriodicCheck = true;
            ValidateProxyKeyAsync(proxyKay);
        }];
    });
}
static void TryAutoPasteProxyKey(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (proxyKayClipboardChecked || proxyKaySubmitted || proxyKayLoading) return;
        proxyKayClipboardChecked = true;
        NSString *clipboardKey = [UIPasteboard generalPasteboard].string;
        clipboardKey = [clipboardKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (clipboardKey.length < 4 || clipboardKey.length >= sizeof(proxyKay)) return;
        if ([clipboardKey containsString:@" "]) return;
        strncpy(proxyKay, clipboardKey.UTF8String, sizeof(proxyKay) - 1);
        proxyKay[sizeof(proxyKay) - 1] = '\0';
        if (loginInputField != nil) {
            loginInputField.text = clipboardKey;
        }
        ValidateProxyKeyAsync(proxyKay);
    });
}
static bool accessKeyPromptVisible = false;

static void ShowAccessKeyPrompt(void) {
    if (accessKeyPromptVisible || proxyKaySubmitted || proxyKayLoading) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (accessKeyPromptVisible || proxyKaySubmitted || proxyKayLoading) return;
        UIWindow *window = nil;
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window != nil) break;
        }
        if (window == nil) window = [UIApplication sharedApplication].keyWindow;
        UIViewController *presenting = window.rootViewController;
        while (presenting.presentedViewController != nil) presenting = presenting.presentedViewController;
        if (presenting == nil) return;

        accessKeyPromptVisible = true;
        UIAlertController *prompt = [UIAlertController alertControllerWithTitle:@"FFH4X SYSTEM"
                                                                          message:@"Cole sua KAY para continuar."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
        [prompt addTextFieldWithConfigurationHandler:^(UITextField *field) {
            field.placeholder = @"Cole a KAY aqui";
            field.secureTextEntry = YES;
            field.autocorrectionType = UITextAutocorrectionTypeNo;
            field.autocapitalizationType = UITextAutocapitalizationTypeNone;
            field.keyboardType = UIKeyboardTypeASCIICapable;
            field.text = [NSString stringWithUTF8String:proxyKay] ?: @"";
        }];
        [prompt addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            accessKeyPromptVisible = false;
            proxyKayError = true;
            proxyKayReason = @"Uma KAY válida é necessária para continuar.";
            ShowAccessKeyPrompt();
        }]];
        [prompt addAction:[UIAlertAction actionWithTitle:@"Validar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            accessKeyPromptVisible = false;
            NSString *value = prompt.textFields.firstObject.text ?: @"";
            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            memset(proxyKay, 0, sizeof(proxyKay));
            strncpy(proxyKay, value.UTF8String ?: "", sizeof(proxyKay) - 1);
            proxyKay[sizeof(proxyKay) - 1] = '\0';
            if (proxyKay[0] == '\0') {
                proxyKayError = true;
                proxyKayReason = @"Cole uma KAY para continuar.";
                ShowAccessKeyPrompt();
            } else {
                proxyKayError = false;
                ValidateProxyKeyAsync(proxyKay);
            }
        }]];
        [presenting presentViewController:prompt animated:YES completion:nil];
    });
}

extern void MyMenu() {
    if (proxyKaySubmitted && !proxyKayError) return;
    isMenuVisible = true;

    // Garante que nenhuma camada da antiga tela gráfica permaneça na janela.
    static bool oldLoginLayersRemoved = false;
    if (!oldLoginLayersRemoved) {
        oldLoginLayersRemoved = true;
        dispatch_async(dispatch_get_main_queue(), ^{
            [loginBlurView removeFromSuperview];
            loginBlurView = nil;
            [loginArtworkView removeFromSuperview];
            loginArtworkView = nil;
            [loginInputField removeFromSuperview];
            loginInputField = nil;
        });
    }

    if (!proxyKayAutoChecked) {
        proxyKayAutoChecked = true;
        NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy_access_key"];
        if (savedKey.length > 0) {
            strncpy(proxyKay, savedKey.UTF8String, sizeof(proxyKay) - 1);
            proxyKay[sizeof(proxyKay) - 1] = '\0';
            ValidateProxyKeyAsync(proxyKay);
        } else {
            ShowAccessKeyPrompt();
        }
    } else if (proxyKayError) {
        ShowAccessKeyPrompt();
    }

    // Nenhuma tela de login é desenhada. O acesso é solicitado pelo prompt nativo acima.
}

// Marca visual exibida no login e também depois que a KAY foi validada.
void DrawAuthenticatedBranding() {
    ImGuiIO& io = ImGui::GetIO();
    const ImVec2 viewport = io.DisplaySize;
    ImDrawList* draw = ImGui::GetForegroundDrawList();
    const bool landscape = viewport.x > viewport.y * 1.15f;
    const float scale = ImClamp(ImMin(viewport.x, viewport.y) / 430.0f, 0.62f, 0.95f);
    const float fontSize = (landscape ? 19.0f : 20.0f) * scale;
    const char *label = "FFH4X SYSTEM BY MARCELO";
    const ImVec2 textSize = ImGui::GetFont()->CalcTextSizeA(fontSize, FLT_MAX, 0.0f, label);
    const float margin = 12.0f * scale;
    const float padX = 10.0f * scale;
    const float padY = 6.0f * scale;
    const ImVec2 min(viewport.x - textSize.x - (padX * 2.0f) - margin,
                     margin);
    const ImVec2 max(viewport.x - margin,
                     margin + textSize.y + (padY * 2.0f));

    // Fundo preto sólido para cobrir completamente o conteúdo atrás da etiqueta.
    draw->AddRectFilled(min, max, ImColor(0, 0, 0, 255), 10.0f * scale);
    draw->AddRect(min, max, ImColor(255, 255, 255, 100), 10.0f * scale, 0, 1.0f * scale);

    ImVec2 cursor(min.x + padX, min.y + padY);
    const float time = (float)ImGui::GetTime();
    for (const char *c = label; *c != '\0'; ++c) {
        char glyph[2] = {*c, '\0'};
        const float hue = fmodf(time * 0.16f + (cursor.x - min.x) / ImMax(textSize.x, 1.0f) * 0.42f, 1.0f);
        const ImU32 color = ImColor::HSV(hue < 0.0f ? hue + 1.0f : hue, 0.78f, 1.0f, 1.0f);
        draw->AddText(ImGui::GetFont(), fontSize, ImVec2(cursor.x + 1.0f * scale, cursor.y + 1.0f * scale),
                      ImColor(0, 0, 0, 190), glyph);
        draw->AddText(ImGui::GetFont(), fontSize, cursor, color, glyph);
        cursor.x += ImGui::GetFont()->CalcTextSizeA(fontSize, FLT_MAX, 0.0f, glyph).x;
    }
}

void ToggleMenuVisibility() {
    isMenuVisible = !isMenuVisible; // Chuyển đổi hiển thị menu
    // Lưu trạng thái menu
    [[NSUserDefaults standardUserDefaults] setBool:isMenuVisible forKey:@"isMenuVisible"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Hàm lưu cài đặt
void SaveSettings() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Lưu các cài đặt Drawing
    [defaults setBool:EnableSwitch forKey:@"EnableSwitch"];
    [defaults setBool:AIDisplay forKey:@"AIDisplay"];
    [defaults setBool:BoxSwitch forKey:@"BoxSwitch"];
    [defaults setBool:DistanceSwitch forKey:@"DistanceSwitch"];
    [defaults setBool:PlayerNameSwitch forKey:@"PlayerNameSwitch"];
    [defaults setBool:CrateSwitch forKey:@"CrateSwitch"];
    [defaults setBool:NoChaseDowned forKey:@"NoChaseDowned"];
    [defaults setBool:TeamCheckSwitch forKey:@"TeamCheckSwitch"];
    [defaults setBool:SkeletonSwitch forKey:@"SkeletonSwitch"];
    [defaults setBool:HealthSwitch forKey:@"HealthSwitch"];
    [defaults setBool:LineSwitch forKey:@"LineSwitch"];
    [defaults setBool:HelmetArmorSwitch forKey:@"HelmetArmorSwitch"];
    [defaults setBool:NoRecoilSwitch forKey:@"NoRecoilSwitch"];
    [defaults setBool:MapItems forKey:@"MapItems"];
    
    // Lưu các cài đặt AimBot
    [defaults setBool:AimBotSwitch forKey:@"AimBotSwitch"];
    [defaults setFloat:aimSpeed forKey:@"aimSpeed"];
    [defaults setFloat:AimBotFOV forKey:@"AimBotFOV"];
    [defaults setFloat:wuzi forKey:@"wuzi"];
    [defaults setInteger:selectedBoneIndex forKey:@"selectedBoneIndex"];
    
    // Lưu các cài đặt khác
    
    [defaults synchronize];
}

// Hàm tải cài đặt
void LoadSettings() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Tải các cài đặt Drawing
    EnableSwitch = [defaults boolForKey:@"EnableSwitch"];
    AIDisplay = [defaults boolForKey:@"AIDisplay"];
    BoxSwitch = [defaults boolForKey:@"BoxSwitch"];
    DistanceSwitch = [defaults boolForKey:@"DistanceSwitch"];
    PlayerNameSwitch = [defaults boolForKey:@"PlayerNameSwitch"];
    CrateSwitch = [defaults boolForKey:@"CrateSwitch"];
    NoChaseDowned = [defaults boolForKey:@"NoChaseDowned"];
    TeamCheckSwitch = [defaults boolForKey:@"TeamCheckSwitch"];
    SkeletonSwitch = [defaults boolForKey:@"SkeletonSwitch"];
    HealthSwitch = [defaults boolForKey:@"HealthSwitch"];
    LineSwitch = [defaults boolForKey:@"LineSwitch"];
    HelmetArmorSwitch = [defaults boolForKey:@"HelmetArmorSwitch"];
    NoRecoilSwitch = [defaults boolForKey:@"NoRecoilSwitch"];
    MapItems = [defaults boolForKey:@"MapItems"];
    
    // Tải các cài đặt AimBot
    AimBotSwitch = [defaults boolForKey:@"AimBotSwitch"];
    aimSpeed = [defaults floatForKey:@"aimSpeed"];
    AimBotFOV = [defaults floatForKey:@"AimBotFOV"];
    wuzi = [defaults floatForKey:@"wuzi"];
    selectedBoneIndex = (int)[defaults integerForKey:@"selectedBoneIndex"];
    
    // Tải các cài đặt khác
}

static const char* GetBoneFTransformName(int index) {
    switch(index) {
        case 0: return "Head";
        case 1: return "Neck";
        case 2: return "Upper Chest";
        case 3: return "Chest";
        case 4: return "Waist";
        case 5: return "Pelvis";
        case 6: return "Left Shoulder";
        case 7: return "Left Upper Arm";
        case 8: return "Left Hand";
        case 9: return "Right Shoulder";
        case 10: return "Right Upper Arm";
        case 11: return "Right Hand";
        case 12: return "Left Thigh";
        case 13: return "Left Calf";
        case 14: return "Left Foot";
        case 15: return "Right Thigh";
        case 16: return "Right Calf";
        case 17: return "Right Foot";
        default: return "Unknown";
    }
}

sdkafowanbnonowaf * Global_DrawView;
Renderer *g_renderer;

@implementation sdkafowanbnonowaf

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

    // Cập nhật vị trí chuột ImGui
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(point.x, point.y);

    // Nếu menu hiển thị và click trong cửa sổ ImGui
    if (isMenuVisible && ImGui::IsWindowHovered(ImGuiHoveredFlags_AnyWindow)) {
        return hitView;
    }

    return nil;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}



#include "ESP.h"
void _function_return1(void *_this) { return; }
void _function_return2(void *_this) { return; }
void _function_return3(void *_this) { return; }
void _function_4(void *_this) { return; }
void _function_5(void *_this) { return; }
void _function_6(void *_this) { return; }

void showToast(NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(window.center.x - 100, window.center.y - 50, 200, 50)];
        toastLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        toastLabel.textColor = [UIColor redColor];
        toastLabel.textAlignment = NSTextAlignmentCenter;
        toastLabel.text = message;
        toastLabel.alpha = 1.0;
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = YES;
        [window addSubview:toastLabel];
        [UIView animateWithDuration:3.0 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{ toastLabel.alpha = 0.0; } completion:^(BOOL finished) { [toastLabel removeFromSuperview]; }];
    });
}

void hook_no_orig_function() {
    showToast(@"[TW-1 TG@TW_1_MOD]-Antiban!");
    hook(
        (void *[]) {
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0x1e250")),
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0x1e330")),
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0x991e4")),
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0xd15bc")),
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0x1c60f0")),
            (void *)getAbsoluteAddress("anogs", ENCRYPTOFFSET("0x1ed020"))
        },
        (void *[]) {
            (void *)_function_return1,
            (void *)_function_return2,
            (void *)_function_return3,
            (void *)_function_4,
            (void *)_function_5,
            (void *)_function_6
        },
        6
    );
}

static void __attribute__((constructor)) CosmkloadYZ() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Delay 1 giây trước khi khởi tạo API
        // [NSThread sleepForTimeInterval:1.0];
        
        // APIClient *API = [[APIClient alloc] init];
        // NSString *token = originalToken;
        // [API setToken:token];
        // [API setLanguage:NSSENCRYPT("vi")];
        // [API hideUI:NO]; // Đảm bảo UI key được hiển thị

        // [API paid:^{
            

   //antiban Jaibreak
             /*   
                vm_anogs(ENCRYPTOFFSET("0x103b1c"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
                vm_anogs(ENCRYPTOFFSET("0x103e54"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
                vm_anogs(ENCRYPTOFFSET("0x1c28b4"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
                vm_anogs(ENCRYPTOFFSET("0x227760"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
                vm_anogs(ENCRYPTOFFSET("0x2ac958"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
                vm_anogs(ENCRYPTOFFSET("0x2b0abc"), strtoul(ENCRYPTHEX("0xC0035FD6"), nullptr, 0));
             
  */
            // Tải cài đặt đã lưu
            LoadSettings();
            
            // Khởi tạo screenSize
            screenSize = [UIScreen mainScreen].bounds.size;
            screenSize.width *= [UIScreen mainScreen].nativeScale;
            screenSize.height *= [UIScreen mainScreen].nativeScale;
            uint32_t count = _dyld_image_count();
                for (int i = 0; i < count; i++) {
                    std::string path = (const char *)_dyld_get_image_name(i);
                    if (path.find("CodeV.app/CodeV") != path.npos) moudule_base = _dyld_get_image_vmaddr_slide(i);
                }
            // Tăng delay lên 4 giây để khởi tạo các thành phần khác
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    bundle = [[NSBundle mainBundle] bundleIdentifier];
    bundle = [NSString stringWithFormat:@"%@", bundle];
    
    char *showBundle = (char*) [bundle cStringUsingEncoding:NSUTF8StringEncoding];

    if (strstr(showBundle, ".proxima") != NULL || strstr(showBundle, ".dfm") != NULL || strstr(showBundle, "com.proxima.dfm") != NULL ) {
                    // Phiên bản quốc tế
                    CurrentHealthBar = "0x102C8EAFC";
                    MaxHealthBar = "0x102C9C1AC";
                    WorldAddress = "0x1104F7478";
                    kGetViewportSize = "0x106E51854";
                    kProjectWorldLocationToScreen = "0x106C83FE8";
                    kLineOfSight_1 = "0x1102871C0";
                    kLineOfSight_2 = "0x1104D9534";
                    kLineOfSight_3 = "0x106B77CDC";
                    kLineOfSight_4 = "0x106B78530";
                    kLineOfSight_5 = "0x10ACBCBAC";
                }

    else if (strstr(showBundle, ".garena") != NULL || strstr(showBundle, ".game") != NULL || strstr(showBundle, "com.garena.game.df") != NULL) {
                    // Phiên bản Garena
                    CurrentHealthBar = "0x102AC82D0";
                    MaxHealthBar = "0x102AD5980";
                    WorldAddress = "0x1102B30F8";
                    kGetViewportSize = "0x106C8A918";
                    kProjectWorldLocationToScreen = "0x106ABD0AC";
                    kLineOfSight_1 = "0x110043000";
                    kLineOfSight_2 = "0x1102951B4";
                    kLineOfSight_3 = "0x1069B0DA0";
                    kLineOfSight_4 = "0x1069B15F4";
                    kLineOfSight_5 = "0x10AAEC854";
                }

                // Criar a view de desenho diretamente na janela para ocupar toda a área.
                UIWindow *hostWindow = nil;
                UIScene *activeScene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
                if ([activeScene isKindOfClass:[UIWindowScene class]]) {
                    hostWindow = ((UIWindowScene *)activeScene).windows.firstObject;
                }
                CGRect hostBounds = hostWindow ? hostWindow.bounds : [UIScreen mainScreen].bounds;
                InstallProxyLifecycleObserver();
                if (hostWindow != nil) {
                    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
                    loginBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                    loginBlurView.frame = hostBounds;
                    // Blur forte no fundo, mas sem bloquear visualmente a tela deitada.
                    loginBlurView.alpha = 0.86f;
                    loginBlurView.userInteractionEnabled = NO;
                    loginBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [hostWindow addSubview:loginBlurView];
                }
                Global_DrawView = [[sdkafowanbnonowaf alloc] initWithFrame:hostBounds];
                Global_DrawView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                Global_DrawView.device = MTLCreateSystemDefaultDevice();
                Global_DrawView.preferredFramesPerSecond = 60;
                g_renderer = [[Renderer alloc] initWithMetalKitView:Global_DrawView];
                Global_DrawView.delegate = g_renderer;
                [Global_DrawView setBackgroundColor:[UIColor clearColor]];

                // Adicionar diretamente à janela, sem camada de ocultação de transmissão.
                if (hostWindow != nil) {
                    [hostWindow addSubview:Global_DrawView];

                    loginInputDelegate = [ProxyLoginInputDelegate new];
                    loginInputField = [[UITextField alloc] initWithFrame:CGRectZero];
                    loginInputField.backgroundColor = UIColor.clearColor;
                    loginInputField.textColor = UIColor.clearColor;
                    loginInputField.tintColor = UIColor.clearColor;
                    loginInputField.alpha = 0.02f;
                    loginInputField.autocorrectionType = UITextAutocorrectionTypeNo;
                    loginInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    loginInputField.spellCheckingType = UITextSpellCheckingTypeNo;
                    loginInputField.secureTextEntry = YES;
                    loginInputField.returnKeyType = UIReturnKeyDone;
                    loginInputField.keyboardType = UIKeyboardTypeASCIICapable;
                    loginInputField.delegate = loginInputDelegate;
                    [loginInputField addTarget:loginInputDelegate action:@selector(inputChanged:) forControlEvents:UIControlEventEditingChanged];
                    loginInputField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
                    loginInputField.userInteractionEnabled = YES;
                    [hostWindow addSubview:loginInputField];
                    [hostWindow bringSubviewToFront:loginInputField];
                    // Uma KAY copiada pode ser verificada assim que o login aparece.

                    // Procura o recurso tanto no bundle do tweak quanto nos caminhos rootless.
                    NSMutableArray<NSString *> *artworkCandidates = [NSMutableArray array];
                    NSArray<NSBundle *> *bundles = @[[NSBundle bundleForClass:[sdkafowanbnonowaf class]], [NSBundle mainBundle]];
                    for (NSBundle *candidateBundle in bundles) {
                        NSString *path = [candidateBundle pathForResource:@"ffh4x_login_logo" ofType:@"jpg"];
                        if (path.length > 0) [artworkCandidates addObject:path];
                        path = [candidateBundle pathForResource:@"ffh4x_login_logo" ofType:@"png"];
                        if (path.length > 0) [artworkCandidates addObject:path];
                    }
                    [artworkCandidates addObjectsFromArray:@[
                        @"/var/jb/Library/Application Support/destroying/ffh4x_login_logo.jpg",
                        @"/var/jb/Library/Application Support/destroying/Resources/ffh4x_login_logo.jpg",
                        @"/Library/Application Support/destroying/ffh4x_login_logo.jpg",
                        @"/Library/Application Support/destroying/Resources/ffh4x_login_logo.jpg"
                    ]];
                    UIImage *artwork = nil;
                    for (NSString *candidate in artworkCandidates) {
                        if ([[NSFileManager defaultManager] fileExistsAtPath:candidate]) {
                            artwork = [UIImage imageWithContentsOfFile:candidate];
                            if (artwork != nil) break;
                        }
                    }
                    // Fallback definitivo: a imagem também fica embutida no binário.
                    if (artwork == nil) {
                        NSData *embeddedArtworkData = [NSData dataWithBytes:ffh4x_login_logo_jpg length:ffh4x_login_logo_jpg_len];
                        artwork = [UIImage imageWithData:embeddedArtworkData scale:[UIScreen mainScreen].scale];
                    }
                    if (artwork != nil) {
                        loginArtworkView = [[UIImageView alloc] initWithImage:artwork];
                        loginArtworkView.frame = CGRectMake(0, 0, 1, 1);
                        loginArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                        loginArtworkView.clipsToBounds = YES;
                        loginArtworkView.hidden = NO;
                        loginArtworkView.alpha = 1.0f;
                        loginArtworkView.userInteractionEnabled = NO;
                        loginArtworkView.layer.cornerCurve = kCACornerCurveContinuous;
                        CAKeyframeAnimation *loginFloat = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                        loginFloat.values = @[@(-4.0f), @(4.0f), @(-4.0f)];
                        loginFloat.keyTimes = @[@0.0f, @0.5f, @1.0f];
                        loginFloat.duration = 3.2f;
                        loginFloat.repeatCount = HUGE_VALF;
                        loginFloat.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        [loginArtworkView.layer addAnimation:loginFloat forKey:@"ffh4x_login_float"];
                        [hostWindow addSubview:loginArtworkView];
                        [hostWindow bringSubviewToFront:loginArtworkView];
                    }

                    // Abertura removida: o login aparece imediatamente.
                    // Mantemos apenas o artwork como elemento de marca e o campo de texto
                    // continua sendo o controle nativo responsável pelo teclado seguro.
                    if (loginArtworkView != nil) {
                        [hostWindow bringSubviewToFront:loginArtworkView];
                        loginArtworkView.alpha = 1.0f;
                        loginArtworkView.transform = CGAffineTransformIdentity;
                    }
                    [hostWindow bringSubviewToFront:loginInputField];
                    TryAutoPasteProxyKey();
                }
            });
        // }];
    });
}



@end
