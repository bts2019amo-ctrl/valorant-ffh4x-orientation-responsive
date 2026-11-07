#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL gStarted = NO;
static BOOL gPromptVisible = NO;
static BOOL gAuthenticated = NO;
static NSUInteger gPresentationGeneration = 0;
static NSString *gLastKey = nil;
static id gActiveObserver = nil;
static id gLaunchObserver = nil;

static void RequestLoginPresentation(void);
static void PresentLoginAttempt(NSUInteger generation, NSUInteger attempt);
static void ValidateKey(NSString *key);
static void PresentResult(NSString *title, NSString *message, BOOL valid, BOOL retry);
static void PresentResultAttempt(NSString *title, NSString *message, BOOL valid, BOOL retry, NSUInteger attempt);

static UIViewController *TopViewController(void) {
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *keyWindow = nil;

    for (UIScene *scene in application.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        if (windowScene.activationState != UISceneActivationStateForegroundActive &&
            windowScene.activationState != UISceneActivationStateForegroundInactive) continue;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        if (keyWindow != nil) break;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (keyWindow == nil) keyWindow = application.keyWindow;
#pragma clang diagnostic pop

    UIViewController *controller = keyWindow.rootViewController;
    if (controller == nil || !keyWindow) return nil;

    while (YES) {
        UIViewController *next = controller.presentedViewController;
        if (next != nil && !next.isBeingDismissed) {
            controller = next;
            continue;
        }
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UIViewController *visible = ((UINavigationController *)controller).visibleViewController;
            if (visible != nil && visible != controller) {
                controller = visible;
                continue;
            }
        }
        if ([controller isKindOfClass:[UITabBarController class]]) {
            UIViewController *selected = ((UITabBarController *)controller).selectedViewController;
            if (selected != nil && selected != controller) {
                controller = selected;
                continue;
            }
        }
        break;
    }

    return controller.viewIfLoaded.window != nil ? controller : nil;
}

static void SchedulePresentationRetry(NSUInteger generation, NSUInteger attempt) {
    if (attempt >= 20 || generation != gPresentationGeneration || gAuthenticated || gPromptVisible) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PresentLoginAttempt(generation, attempt + 1);
    });
}

static void PresentLoginAttempt(NSUInteger generation, NSUInteger attempt) {
    if (generation != gPresentationGeneration || gAuthenticated || gPromptVisible) return;

    UIViewController *presenter = TopViewController();
    if (presenter == nil || presenter.isBeingPresented || presenter.isBeingDismissed ||
        [presenter isKindOfClass:[UIAlertController class]]) {
        SchedulePresentationRetry(generation, attempt);
        return;
    }

    gPromptVisible = YES;
    UIAlertController *prompt = [UIAlertController alertControllerWithTitle:@"8ball Pooll SYSTEM"
                                                                     message:@"Cole sua KAY para continuar."
                                                              preferredStyle:UIAlertControllerStyleAlert];
    __weak UIAlertController *weakPrompt = prompt;
    [prompt addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"Cole a KAY aqui";
        field.secureTextEntry = YES;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.spellCheckingType = UITextSpellCheckingTypeNo;
        field.keyboardType = UIKeyboardTypeASCIICapable;
        field.text = gLastKey ?: @"";
    }];

    [prompt addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
        gPromptVisible = NO;
    }]];
    [prompt addAction:[UIAlertAction actionWithTitle:@"Validar" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        NSString *rawValue = weakPrompt.textFields.firstObject.text ?: @"";
        NSString *value = [rawValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        gPromptVisible = NO;
        if (value.length == 0) {
            PresentResult(@"Chave necessária", @"Digite ou cole sua KAY para continuar.", NO, YES);
            return;
        }
        gLastKey = [value copy];
        ValidateKey(value);
    }]];

    [presenter presentViewController:prompt animated:YES completion:nil];
}

static void RequestLoginPresentation(void) {
    if (gAuthenticated || gPromptVisible) return;
    gPresentationGeneration++;
    PresentLoginAttempt(gPresentationGeneration, 0);
}

static void PresentResult(NSString *title, NSString *message, BOOL valid, BOOL retry) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (valid) gAuthenticated = YES;
        PresentResultAttempt(title, message, valid, retry, 0);
    });
}

static void PresentResultAttempt(NSString *title, NSString *message, BOOL valid, BOOL retry, NSUInteger attempt) {
    UIViewController *presenter = TopViewController();
    if (presenter == nil || presenter.isBeingPresented || presenter.isBeingDismissed ||
        [presenter isKindOfClass:[UIAlertController class]]) {
        if (attempt < 20) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                PresentResultAttempt(title, message, valid, retry, attempt + 1);
            });
        }
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    NSString *buttonTitle = retry ? @"Tentar novamente" : @"OK";
    [alert addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        if (retry && !gAuthenticated) RequestLoginPresentation();
    }]];
    [presenter presentViewController:alert animated:YES completion:nil];
}

static void ValidateKey(NSString *key) {
    NSDictionary *payload = @{ @"0": @{ @"json": @{ @"key": key } } };
    NSError *serializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&serializationError];
    if (jsonData == nil || serializationError != nil) {
        PresentResult(@"Erro de validação", @"Não foi possível preparar a solicitação.", NO, YES);
        return;
    }

    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://proxysystem.org/api/trpc/android.validateKey"];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"batch" value:@"1"],
        [NSURLQueryItem queryItemWithName:@"input" value:json ?: @""]
    ];
    NSURL *url = components.URL;
    if (url == nil) {
        PresentResult(@"Erro de validação", @"Não foi possível criar a solicitação.", NO, YES);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                      timeoutInterval:12.0];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil || data == nil) {
                PresentResult(@"Falha na validação", @"Não foi possível conectar ao servidor de chaves.", NO, YES);
                return;
            }
            if (![response isKindOfClass:[NSHTTPURLResponse class]] || ((NSHTTPURLResponse *)response).statusCode != 200) {
                NSInteger status = [response isKindOfClass:[NSHTTPURLResponse class]] ? ((NSHTTPURLResponse *)response).statusCode : 0;
                PresentResult(@"Falha na validação", [NSString stringWithFormat:@"O servidor retornou HTTP %ld.", (long)status], NO, YES);
                return;
            }

            NSError *parseError = nil;
            id root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSDictionary *result = nil;
            if ([root isKindOfClass:[NSArray class]] && [(NSArray *)root count] > 0) {
                id first = [(NSArray *)root firstObject];
                if ([first isKindOfClass:[NSDictionary class]]) result = first[@"result"][@"data"][@"json"];
            }
            if (parseError != nil || ![result isKindOfClass:[NSDictionary class]]) {
                PresentResult(@"Falha na validação", @"A resposta do servidor é inválida.", NO, YES);
                return;
            }

            if ([result[@"valid"] boolValue]) {
                NSInteger daysLeft = [result[@"daysLeft"] integerValue];
                NSString *message = @"Sua KAY foi validada com sucesso.";
                if (daysLeft > 0) message = [NSString stringWithFormat:@"%@\nDias restantes: %ld", message, (long)daysLeft];
                PresentResult(@"Chave validada", message, YES, NO);
            } else {
                NSString *reason = [result[@"reason"] isKindOfClass:[NSString class]] ? result[@"reason"] : nil;
                PresentResult(@"KAY inválida ou expirada", reason.length > 0 ? reason : @"Verifique a chave e tente novamente.", NO, YES);
            }
        });
    }];
    [task resume];
}

void LoginOnlyStart(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gStarted) return;
        gStarted = YES;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        gActiveObserver = [center addObserverForName:UIApplicationDidBecomeActiveNotification
                                              object:nil
                                               queue:[NSOperationQueue mainQueue]
                                          usingBlock:^(__unused NSNotification *note) {
            if (!gAuthenticated && !gPromptVisible) RequestLoginPresentation();
        }];
        gLaunchObserver = [center addObserverForName:UIApplicationDidFinishLaunchingNotification
                                              object:nil
                                               queue:[NSOperationQueue mainQueue]
                                          usingBlock:^(__unused NSNotification *note) {
            if (!gAuthenticated && !gPromptVisible) RequestLoginPresentation();
        }];

        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive ||
            [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
            RequestLoginPresentation();
        } else {
            // Aguarda o UIKit criar a janela/cena do app. As notificações também tentam novamente.
            gPresentationGeneration++;
            PresentLoginAttempt(gPresentationGeneration, 0);
        }
    });
}
