#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <Security/Security.h>

#define API_CHECK_UDID @"https://key.gmvmoba.com/udid/api/done"
#define BASE_URL       @"https://key.gmvmoba.com/connect" 
#define PROFILE_URL    @"https://key.gmvmoba.com/udid/profile"
#define GAME_NAME      @"PUBG" 
#define GET_KEY_URL    @"https://key.gmvmoba.com/gmvmoba/getkeyapp"
#define ZALO_INFO      @"Mua Key Zalo: 0965870531"

static NSString *const kSavedUDID = @"GMV_UDID_DEVICE";
static NSString *const kKeychainKey = @"GMV_PERMANENT_KEY";

@interface RotateViewController : UIViewController @end
@implementation RotateViewController
- (BOOL)shouldAutorotate { return YES; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
@end

@interface KeyManager : NSObject
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, assign) BOOL isChecking; 
+ (instancetype)shared;
+ (void)checkDeviceAndStart;
@end

@implementation KeyManager

+ (instancetype)shared {
    static KeyManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[KeyManager alloc] init]; });
    return shared;
}

+ (void)savePermanentKey:(NSString *)key {
    if (!key) return;
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount: kKeychainKey, (__bridge id)kSecValueData: data};
    SecItemDelete((__bridge CFDictionaryRef)query);
    SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

+ (NSString *)getPermanentKey {
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount: kKeychainKey, (__bridge id)kSecReturnData: @YES, (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne};
    CFTypeRef dataTypeRef = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef) == errSecSuccess) {
        NSData *data = (__bridge_transfer NSData *)dataTypeRef;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (void)showToast:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareWindow];
        UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [[KeyManager shared].alertWindow.rootViewController presentViewController:toast animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

+ (void)checkDeviceAndStart {
    if ([KeyManager shared].isChecking) return;
    [KeyManager shared].isChecking = YES;

    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:API_CHECK_UDID] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:8];
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KeyManager shared].isChecking = NO;
            if (data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json[@"status"] boolValue] && json[@"udid"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:json[@"udid"] forKey:kSavedUDID];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *storedKey = [self getPermanentKey];
                    if (storedKey) [self verifyKey:storedKey]; 
                    else [self showMainAlert:nil];
                    return;
                }
            }
            [self showGetUDIDAlert];
        });
    }] resume];
}

+ (void)showGetUDIDAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareWindow];
        [KeyManager shared].alertWindow.hidden = NO; 

        UIViewController *root = [KeyManager shared].alertWindow.rootViewController;
        
        if (root.presentedViewController && [root.presentedViewController isKindOfClass:[UIAlertController class]]) {
             UIAlertController *currentAlert = (UIAlertController *)root.presentedViewController;
             if ([currentAlert.title isEqualToString:@"💥XÁC MINH THIẾT BỊ💥"]) return;
             [root dismissViewControllerAnimated:NO completion:nil];
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"💥XÁC MINH THIẾT BỊ💥" message:@"Vui lòng cài đặt hồ sơ để xác minh UDID thiết bị." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Lấy UDID (Safari)" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PROFILE_URL] options:@{} completionHandler:nil];
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self checkDeviceAndStart]; 
            });
        }]];
        [root presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)showMainAlert:(NSString *)initialKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareWindow];
        [KeyManager shared].alertWindow.hidden = NO;
        UIViewController *root = [KeyManager shared].alertWindow.rootViewController;
        if (root.presentedViewController) [root dismissViewControllerAnimated:NO completion:nil];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"💥ĐĂNG NHẬP💥" message:nil preferredStyle:UIAlertControllerStyleAlert];
        NSString *msg = ZALO_INFO;
        NSMutableAttributedString *attrMsg = [[NSMutableAttributedString alloc] initWithString:msg];
        [attrMsg addAttribute:NSForegroundColorAttributeName value:[UIColor systemRedColor] range:NSMakeRange(0, msg.length)];
        [attrMsg addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(0, msg.length)];
        [alert setValue:attrMsg forKey:@"attributedMessage"];

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Dán key vào đây...";
            textField.textAlignment = NSTextAlignmentCenter;
            textField.text = initialKey ?: [self getPermanentKey]; 
            UIButton *pasteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [pasteBtn setTitle:@"Dán " forState:UIControlStateNormal];
            pasteBtn.frame = CGRectMake(0, 0, 45, 30);
            [pasteBtn addTarget:self action:@selector(handlePaste:) forControlEvents:UIControlEventTouchUpInside];
            textField.rightView = pasteBtn;
            textField.rightViewMode = UITextFieldViewModeAlways;
            objc_setAssociatedObject(pasteBtn, "targetField", textField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];

        [alert addAction:[UIAlertAction actionWithTitle:@"Lấy Key" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GET_KEY_URL] options:@{} completionHandler:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self showMainAlert:alert.textFields.firstObject.text]; });
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"Xác Nhận" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self verifyKey:alert.textFields.firstObject.text];
        }]];
        [root presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)handlePaste:(UIButton *)sender {
    UITextField *t = (UITextField *)objc_getAssociatedObject(sender, "targetField");
    if (t) t.text = [UIPasteboard generalPasteboard].string;
}

+ (void)verifyKey:(NSString *)userKey {
    if (!userKey || userKey.length == 0) {
        [self showToast:@"⚠️ Vui lòng nhập mã!"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self showMainAlert:nil]; });
        return;
    }
    NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedUDID] ?: @"UNKNOWN";
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
    req.HTTPMethod = @"POST";
    NSString *params = [NSString stringWithFormat:@"game=%@&user_key=%@&serial=%@", GAME_NAME, userKey, udid];
    req.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!data) { [self showToast:@"⛔ Lỗi kết nối!"]; [self showMainAlert:userKey]; return; }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"status"] boolValue]) {
                [self savePermanentKey:userKey];
                [self showToast:[NSString stringWithFormat:@"✅ Thành Công!\nHạn: %@", json[@"data"][@"EXP"]]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [KeyManager shared].alertWindow.hidden = YES;
                    [KeyManager shared].alertWindow = nil;
                });
            } else {
                [self showToast:[@"⛔ " stringByAppendingString:json[@"reason"] ?: @"Mã sai!"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ [self showMainAlert:userKey]; });
            }
        });
    }] resume];
}

+ (void)prepareWindow {
    if (![KeyManager shared].alertWindow) {
        [KeyManager shared].alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [KeyManager shared].alertWindow.windowLevel = UIWindowLevelStatusBar + 999.0;
        [KeyManager shared].alertWindow.rootViewController = [RotateViewController new];
        [KeyManager shared].alertWindow.backgroundColor = [UIColor clearColor];
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    [KeyManager shared].alertWindow.windowScene = scene; break;
                }
            }
        }
    }
    [[KeyManager shared].alertWindow makeKeyAndVisible];
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self checkDeviceAndStart];
    });

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self prepareWindow];
        [KeyManager shared].alertWindow.hidden = NO;
        [self checkDeviceAndStart];
    }];
}
@end