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
                ShowProxyKayAlert(NO, proxyKayReason, 0);
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
extern void MyMenu() {
    if (proxyKaySubmitted && !proxyKayError) {
        return;
    }
    isMenuVisible = true;

    if (!proxyKayAutoChecked) {
        proxyKayAutoChecked = true;
        NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"proxy_access_key"];
        if (savedKey.length > 0) {
            strncpy(proxyKay, savedKey.UTF8String, sizeof(proxyKay) - 1);
            proxyKay[sizeof(proxyKay) - 1] = '\0';
            ValidateProxyKeyAsync(proxyKay);
        }
    }

    ImGuiIO& io = ImGui::GetIO();
    const ImVec2 viewport = io.DisplaySize;
    ImDrawList* draw = ImGui::GetBackgroundDrawList();

    // Tela Android original: fundo preto com leve variação vermelha no topo.
    draw->AddRectFilled(ImVec2(0.0f, 0.0f), viewport, ImColor(5, 5, 5, 255));
    draw->AddRectFilledMultiColor(ImVec2(0.0f, 0.0f), ImVec2(viewport.x, viewport.y * 0.48f),
                                  ImColor(26, 0, 0, 255), ImColor(8, 8, 8, 255),
                                  ImColor(8, 8, 8, 255), ImColor(5, 5, 5, 255));

    const float layoutAxis = ImMin(viewport.x, viewport.y);
    const float scale = ImClamp(layoutAxis / 390.0f, 0.72f, 1.18f);
    const float maxContentWidth = 390.0f * scale;
    const float contentWidth = ImMin(viewport.x - (48.0f * scale), maxContentWidth);
    const float contentLeft = (viewport.x - contentWidth) * 0.5f;
    const float iconSize = 80.0f * scale;
    const float titleSize = 28.0f * scale;
    const float subtitleSize = 15.0f * scale;
    const float fieldHeight = 60.0f * scale;
    const float textScale = scale * 0.48f;
    const float centerX = viewport.x * 0.5f;
    const float blockHeight = iconSize + 24.0f * scale + titleSize + 8.0f * scale + subtitleSize + 40.0f * scale + fieldHeight + 20.0f * scale + fieldHeight;
    const float top = ImMax(32.0f * scale, viewport.y * 0.5f - blockHeight * 0.5f);

    ImGui::SetNextWindowPos(ImVec2(0.0f, 0.0f), ImGuiCond_Always);
    ImGui::SetNextWindowSize(viewport, ImGuiCond_Always);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
    ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(32.0f * scale, 0.0f));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.0f, 0.0f, 0.0f, 0.0f));

    if (ImGui::Begin("##android_login_screen", nullptr,
                     ImGuiWindowFlags_NoDecoration |
                     ImGuiWindowFlags_NoMove |
                     ImGuiWindowFlags_NoResize |
                     ImGuiWindowFlags_NoSavedSettings |
                     ImGuiWindowFlags_NoScrollbar |
                     ImGuiWindowFlags_NoScrollWithMouse)) {
        ImGui::SetWindowFontScale(textScale);
        ImGui::SetCursorPos(ImVec2(0.0f, top));

        // Artwork fornecido pelo usuário, mantido quadrado e sem deformação.
        const ImVec2 iconCenter(centerX, top + iconSize * 0.5f);
        if (loginArtworkView != nil) {
            CGRect artworkFrame = CGRectMake(iconCenter.x - iconSize * 0.5f,
                                             iconCenter.y - iconSize * 0.5f,
                                             iconSize,
                                             iconSize);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (loginArtworkView != nil) {
                    loginArtworkView.frame = artworkFrame;
                    loginArtworkView.hidden = NO;
                    loginArtworkView.alpha = (loginSplashView != nil) ? 0.0f : 1.0f;
                    [loginArtworkView.superview bringSubviewToFront:loginArtworkView];
                    loginArtworkView.layer.cornerRadius = iconSize * 0.18f;
                }
            });
        }

        ImGui::SetCursorPosY(top + iconSize + 30.0f * scale);
        const float redPulse = 0.82f + 0.18f * (0.5f + 0.5f * sinf((float)ImGui::GetTime() * 3.2f));
        const float titleWidth = ImGui::CalcTextSize("FFH4X SYSTEM").x * 1.42f;
        const ImVec4 pulseRed = ImVec4(0.88f * redPulse, 0.035f, 0.04f, 1.0f);
        const ImVec4 brightRed = ImVec4(1.0f, 0.08f + 0.04f * redPulse, 0.08f + 0.04f * redPulse, 1.0f);
        ImGui::SetCursorPosX((viewport.x - titleWidth) * 0.5f);
        ImGui::SetWindowFontScale(textScale * 1.42f);
        ImGui::PushStyleColor(ImGuiCol_Text, pulseRed);
        ImGui::Text("FFH4X SYSTEM");
        ImGui::PopStyleColor();

        ImGui::SetWindowFontScale(textScale);
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 5.0f * scale);
        ImGui::SetCursorPosX((viewport.x - ImGui::CalcTextSize("Digite sua chave de acesso para continuar").x) * 0.5f);
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.96f * redPulse, 0.32f, 0.34f, 1.0f));
        ImGui::Text("Digite sua chave de acesso para continuar");
        ImGui::PopStyleColor();

        ImGui::SetCursorPosY(top + iconSize + 24.0f * scale + titleSize + 8.0f * scale + subtitleSize + 40.0f * scale);
        ImGui::SetCursorPosX(contentLeft);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 10.0f * scale);
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(18.0f * scale, 13.0f * scale));
        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 1.0f);
        ImGui::PushStyleColor(ImGuiCol_FrameBg, ImVec4(0.11f, 0.11f, 0.12f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_FrameBgHovered, ImVec4(0.14f, 0.14f, 0.15f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_FrameBgActive, ImVec4(0.14f, 0.14f, 0.15f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(0.52f * redPulse, 0.035f, 0.045f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_TextDisabled, ImVec4(0.33f, 0.33f, 0.34f, 1.0f));
        if (loginInputField != nil) {
            CGRect inputFrame = CGRectMake(contentLeft,
                                           top + iconSize + 24.0f * scale + titleSize + 8.0f * scale + subtitleSize + 40.0f * scale,
                                           contentWidth,
                                           fieldHeight);
            loginInputField.frame = inputFrame;
            NSString *currentValue = [NSString stringWithUTF8String:proxyKay] ?: @"";
            if (![loginInputField.text isEqualToString:currentValue] && !loginInputField.isFirstResponder) {
                loginInputField.text = currentValue;
            }
        }
        ImGui::SetNextItemWidth(contentWidth);
        ImGui::InputTextWithHint("##android_access_key", "XXXX-XXXX-XXXX-XXXX", proxyKay,
                                 IM_ARRAYSIZE(proxyKay), ImGuiInputTextFlags_Password,
                                 nullptr, nullptr);
        if (ImGui::IsItemClicked()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (loginInputField != nil) {
                    [loginInputField becomeFirstResponder];
                    [loginInputField.superview bringSubviewToFront:loginInputField];
                }
            });
        }
        ImGui::PopStyleColor(6);
        ImGui::PopStyleVar(3);
        ImGui::SetCursorPosY(top + iconSize + 24.0f * scale + titleSize + 8.0f * scale + subtitleSize + 40.0f * scale + fieldHeight + 20.0f * scale);
        ImGui::SetCursorPosX(contentLeft);
        ImGui::BeginDisabled(proxyKayLoading);
        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 12.0f * scale);
        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.64f * redPulse, 0.025f, 0.035f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, brightRed);
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.45f, 0.01f, 0.018f, 1.0f));
        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
        if (ImGui::Button(proxyKayLoading ? "VALIDANDO..." : "VALIDAR CHAVE", ImVec2(contentWidth, fieldHeight))) {
            if (proxyKay[0] == '\0') {
                proxyKayError = true;
                proxyKayReason = @"Digite sua chave de acesso.";
                proxyKayAlertShown = false;
                ShowProxyKayAlert(NO, proxyKayReason, 0);
            } else {
                proxyKayError = false;
                ValidateProxyKeyAsync(proxyKay);
            }
        }
        ImGui::PopStyleColor(4);
        ImGui::PopStyleVar();
        ImGui::EndDisabled();

        if (proxyKayReason != nil) {
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"n?o" withString:@"não"];
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"N?o" withString:@"Não"];
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"inv?lida" withString:@"inválida"];
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"Inv?lida" withString:@"Inválida"];
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"invÃ¡lida" withString:@"inválida"];
                proxyKayReason = [proxyKayReason stringByReplacingOccurrencesOfString:@"InvÃ¡lida" withString:@"Inválida"];
            }
            if (proxyKayError || proxyKayLoading) {
            ImGui::SetCursorPosY(top + blockHeight + 12.0f * scale);
            ImGui::SetCursorPosX(contentLeft);
            ImGui::PushStyleColor(ImGuiCol_Text, proxyKayError ? ImVec4(1.0f, 0.23f, 0.27f, 1.0f) : ImVec4(0.56f, 0.56f, 0.58f, 1.0f));
            ImGui::TextWrapped("%s", proxyKayLoading ? "Validando sua chave..." : (proxyKayReason != nil ? proxyKayReason.UTF8String : "Chave inválida ou expirada."));
            ImGui::PopStyleColor();
        }

        ImGui::SetWindowFontScale(1.0f);
        ImGui::End();
    }

    ImGui::PopStyleColor();
    ImGui::PopStyleVar(3);
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
                    loginBlurView.alpha = 0.76f;
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
                    // A KAY copiada só é verificada depois que a abertura terminar.
                    // O disparo pós-abertura acontece no completion abaixo.

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

                    // Tela de abertura profissional: cobre o login durante 30 segundos.
                    loginSplashView = [[UIView alloc] initWithFrame:hostBounds];
                    loginSplashView.backgroundColor = [UIColor colorWithRed:0.015f green:0.02f blue:0.035f alpha:0.98f];
                    loginSplashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    loginSplashView.userInteractionEnabled = YES;

                    CAGradientLayer *splashGradient = [CAGradientLayer layer];
                    splashGradient.frame = hostBounds;
                    splashGradient.colors = @[(id)[UIColor colorWithRed:0.02f green:0.04f blue:0.08f alpha:1.0f].CGColor,
                                              (id)[UIColor colorWithRed:0.005f green:0.008f blue:0.015f alpha:1.0f].CGColor];
                    splashGradient.startPoint = CGPointMake(0.0, 0.0);
                    splashGradient.endPoint = CGPointMake(1.0, 1.0);
                    [loginSplashView.layer addSublayer:splashGradient];
                    CABasicAnimation *gradientMotion = [CABasicAnimation animationWithKeyPath:@"locations"];
                    gradientMotion.fromValue = @[@0.0f, @0.42f, @1.0f];
                    gradientMotion.toValue = @[@(-0.20f), @0.50f, @1.20f];
                    gradientMotion.duration = 6.0f;
                    gradientMotion.autoreverses = YES;
                    gradientMotion.repeatCount = HUGE_VALF;
                    gradientMotion.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    [splashGradient addAnimation:gradientMotion forKey:@"ffh4x_gradient_motion"];

                    // Cartão de vidro fosco inspirado no iOS 26.
                    // Camada transparente full-screen: sem cartão/quadrado visível.
                    UIView *splashCard = [[UIView alloc] initWithFrame:hostBounds];
                    splashCard.backgroundColor = UIColor.clearColor;
                    splashCard.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    splashCard.layer.cornerRadius = 0.0f;
                    splashCard.layer.borderWidth = 0.0f;
                    splashCard.layer.shadowOpacity = 0.0f;
                    [loginSplashView addSubview:splashCard];

                    UIImageView *splashArtworkView = nil;
                    if (artwork != nil) {
                        splashArtworkView = [[UIImageView alloc] initWithImage:artwork];
                        splashArtworkView.frame = CGRectMake(hostBounds.size.width * 0.5f - 72.0f,
                                                             hostBounds.size.height * 0.5f - 170.0f,
                                                             144.0f,
                                                             144.0f);
                        splashArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                        splashArtworkView.clipsToBounds = YES;
                        splashArtworkView.layer.cornerRadius = 28.0f;
                        splashArtworkView.layer.borderWidth = 1.0f;
                        splashArtworkView.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.18f].CGColor;
                        [splashCard addSubview:splashArtworkView];
                    }

                    UILabel *splashTitle = [[UILabel alloc] initWithFrame:CGRectMake(24.0f,
                                                                                       hostBounds.size.height * 0.5f + 4.0f,
                                                                                       hostBounds.size.width - 48.0f,
                                                                                       42.0f)];
                    splashTitle.text = @"FFH4X SYSTEM";
                    splashTitle.textColor = [UIColor colorWithRed:1.0f green:0.035f blue:0.045f alpha:1.0f];
                    splashTitle.font = [UIFont systemFontOfSize:28.0f weight:UIFontWeightBold];
                    splashTitle.textAlignment = NSTextAlignmentCenter;
                    splashTitle.layer.shadowColor = [UIColor redColor].CGColor;
                    splashTitle.layer.shadowOpacity = 0.85f;
                    splashTitle.layer.shadowRadius = 14.0f;
                    CABasicAnimation *splashTitlePulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    splashTitlePulse.fromValue = @0.60f;
                    splashTitlePulse.toValue = @1.0f;
                    splashTitlePulse.duration = 1.1f;
                    splashTitlePulse.autoreverses = YES;
                    splashTitlePulse.repeatCount = HUGE_VALF;
                    [splashTitle.layer addAnimation:splashTitlePulse forKey:@"ffh4x_splash_title_pulse"];
                    [splashCard addSubview:splashTitle];

                    UILabel *splashSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(24.0f,
                                                                                          hostBounds.size.height * 0.5f + 48.0f,
                                                                                          hostBounds.size.width - 48.0f,
                                                                                          24.0f)];
                    splashSubtitle.text = @"Inicializando sistema...";
                    splashSubtitle.textColor = [UIColor colorWithWhite:0.72f alpha:1.0f];
                    splashSubtitle.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightMedium];
                    splashSubtitle.textAlignment = NSTextAlignmentCenter;
                    [splashCard addSubview:splashSubtitle];

                    UIActivityIndicatorView *splashSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
                    splashSpinner.color = [UIColor colorWithRed:1.0f green:0.035f blue:0.045f alpha:1.0f];
                    splashSpinner.center = CGPointMake(hostBounds.size.width * 0.5f, hostBounds.size.height * 0.5f + 92.0f);
                    [splashSpinner startAnimating];
                    [splashCard addSubview:splashSpinner];

                    loginSplashProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
                    loginSplashProgress.frame = CGRectMake(56.0f,
                                                            hostBounds.size.height * 0.5f + 128.0f,
                                                            hostBounds.size.width - 112.0f,
                                                            4.0f);
                    loginSplashProgress.progressTintColor = [UIColor colorWithRed:0.95f green:0.025f blue:0.035f alpha:1.0f];
                    loginSplashProgress.trackTintColor = [UIColor colorWithWhite:1.0f alpha:0.12f];
                    loginSplashProgress.progress = 0.0f;
                    [splashCard addSubview:loginSplashProgress];
                    UIView *splashProgressMarker = [[UIView alloc] initWithFrame:CGRectMake(56.0f,
                                                                                             hostBounds.size.height * 0.5f + 124.0f,
                                                                                             118.0f,
                                                                                             10.0f)];
                    splashProgressMarker.backgroundColor = [UIColor colorWithRed:1.0f green:0.04f blue:0.05f alpha:0.92f];
                    splashProgressMarker.layer.cornerRadius = 5.0f;
                    splashProgressMarker.layer.shadowColor = [UIColor redColor].CGColor;
                    splashProgressMarker.layer.shadowOpacity = 0.9f;
                    splashProgressMarker.layer.shadowRadius = 12.0f;
                    splashProgressMarker.layer.shadowOffset = CGSizeZero;
                    [splashCard addSubview:splashProgressMarker];
                    [UIView animateWithDuration:1.35
                                          delay:0.0
                                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                                     animations:^{
                        splashProgressMarker.frame = CGRectMake(hostBounds.size.width - 174.0f,
                                                                 hostBounds.size.height * 0.5f + 124.0f,
                                                                 118.0f,
                                                                 10.0f);
                        splashProgressMarker.alpha = 0.42f;
                    } completion:nil];
                                        [hostWindow addSubview:loginSplashView];
                    [hostWindow bringSubviewToFront:loginSplashView];
                    splashCard.alpha = 0.0f;
                    splashCard.transform = CGAffineTransformMakeScale(0.88f, 0.88f);
                    splashArtworkView.alpha = 0.0f;
                    splashArtworkView.transform = CGAffineTransformMakeScale(0.72f, 0.72f);
                    splashTitle.alpha = 0.0f;
                    splashSubtitle.alpha = 0.0f;
                    splashSpinner.alpha = 0.0f;
                    loginSplashProgress.alpha = 0.0f;
                    [UIView animateWithDuration:0.75 delay:0.05 usingSpringWithDamping:0.82 initialSpringVelocity:0.35 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        splashCard.alpha = 1.0f;
                        splashCard.transform = CGAffineTransformIdentity;
                    } completion:nil];
                    [UIView animateWithDuration:0.70 delay:0.22 usingSpringWithDamping:0.76 initialSpringVelocity:0.55 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        splashArtworkView.alpha = 1.0f;
                        splashArtworkView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                    CAKeyframeAnimation *splashFloat = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                    splashFloat.values = @[@(-7.0f), @(7.0f), @(-7.0f)];
                    splashFloat.keyTimes = @[@0.0f, @0.5f, @1.0f];
                    splashFloat.duration = 3.6f;
                    splashFloat.repeatCount = HUGE_VALF;
                    splashFloat.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    [splashArtworkView.layer addAnimation:splashFloat forKey:@"ffh4x_splash_float"];
                    [UIView animateWithDuration:0.50 delay:0.48 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        splashTitle.alpha = 1.0f;
                    } completion:nil];
                    [UIView animateWithDuration:0.50 delay:0.62 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        splashSubtitle.alpha = 1.0f;
                        splashSpinner.alpha = 1.0f;
                        loginSplashProgress.alpha = 1.0f;
                    } completion:nil];
                    [UIView animateWithDuration:20.0 animations:^{
                        loginSplashProgress.progress = 1.0f;
                    }];
                    [loginSplashProgress setProgress:1.0f animated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.60 animations:^{
                            loginSplashView.alpha = 0.0f;
                            loginSplashView.transform = CGAffineTransformMakeScale(1.035f, 1.035f);
                        } completion:^(BOOL finished) {
                            [loginSplashView removeFromSuperview];
                            loginSplashView = nil;
                            loginSplashProgress = nil;
                            if (loginBlurView != nil) {
                                [hostWindow bringSubviewToFront:Global_DrawView];
                                if (loginArtworkView != nil) {
                                    [hostWindow bringSubviewToFront:loginArtworkView];
                                    loginArtworkView.alpha = 0.0f;
                                    loginArtworkView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
                                    [UIView animateWithDuration:0.72 delay:0.05 usingSpringWithDamping:0.82 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        loginArtworkView.alpha = 1.0f;
                                        loginArtworkView.transform = CGAffineTransformIdentity;
                                    } completion:nil];
                                }
                            }
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                TryAutoPasteProxyKey();
                            });
                        }];
                    });
                }
            });
        // }];
    });
}



@end



