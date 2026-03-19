#import "AMDAPIKey.h"
#import <objc/runtime.h>

static NSString *const kServerURL = @"https://amdsystem.site/amdapikey/server/ios.php";
static NSString *const kPackageToken = @"app_token";
static NSString *const kAppVersion = @"app_version";
static NSString *const kTargetBundle = @"bundle_app";

static void amd_viewDidAppear(UIViewController *self, SEL _cmd, BOOL animated)
{
    IMP orig = (IMP)[(NSValue *)objc_getAssociatedObject([UIViewController class], (void *)@selector(viewDidAppear:)) pointerValue];

    if (orig) ((void(*)(id,SEL,BOOL))orig)(self, _cmd, animated);

    AMDAPIKey *shared = [AMDAPIKey shared];

    if (shared.validated || shared.validating)
    {
        return;
    }

    if (![self isKindOfClass:[UIAlertController class]] && ![self isKindOfClass:NSClassFromString(@"UIInputWindowController")] && self == self.view.window.rootViewController)
    {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{if (!shared.validated && !shared.validating) [shared startWithViewController:self];});
    }
}

__attribute__((constructor))
static void AMDInit()
{
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundle isEqualToString:kTargetBundle])
    {
        return;
    }

    [[AMDAPIKey shared] configureWithServerURL:kServerURL packageToken:kPackageToken appVersion:kAppVersion targetBundle:kTargetBundle];

    Class cls = [UIViewController class];
    SEL sel = @selector(viewDidAppear:);
    Method method = class_getInstanceMethod(cls, sel);
    IMP orig = method_getImplementation(method);

    objc_setAssociatedObject(cls, (void *)sel, [NSValue valueWithPointer:(void *)orig], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    method_setImplementation(method, (IMP)amd_viewDidAppear);
}