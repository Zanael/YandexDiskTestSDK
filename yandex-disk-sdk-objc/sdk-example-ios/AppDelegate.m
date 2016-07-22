/* Лицензионное соглашение на использование набора средств разработки
 * «SDK Яндекс.Диска» доступно по адресу: http://legal.yandex.ru/sdk_agreement
 */


#import "AppDelegate.h"
#import "YOAuth2Delegate.h"
#import "YOAuth2ViewController.h"
#import "DirectoryViewController.h"

@interface AppDelegate () <YDSessionDelegate, YOAuth2Delegate>

@property (nonatomic, strong) UINavigationController *navVC;
@property (nonatomic, strong) UIViewController *authVC;
@property (nonatomic, strong) DirectoryViewController *yaDisk;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.session = [[YDSession alloc] initWithDelegate:self];

    self.yaDisk = [[DirectoryViewController alloc] initWithSession:self.session path:@"/"];

    self.yaDisk.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                                     style:UIBarButtonItemStyleBordered
                                                                                    target:self
                                                                                    action:@selector(authenticate:)];

    self.navVC = [[UINavigationController alloc] initWithRootViewController:self.yaDisk];

    self.window.rootViewController = self.navVC;

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)authenticate:(id)sender
{
    [self authenticateAnimated:YES];
}

- (void)authenticateAnimated:(BOOL)animated
{
    if (!self.session.authenticated) {
        self.authVC = [[YOAuth2ViewController alloc] initWithDelegate:self];
        self.authVC = [[UINavigationController alloc] initWithRootViewController:self.authVC];

        [self.navVC presentViewController:self.authVC
                                    animated:animated
                                  completion:nil];
    }
}


#pragma mark - YDSessionDelegate

-(NSString *)userAgent
{
    return @"disk-sdk-example-ios";
}


#pragma mark - YOAuth2Delegate

- (NSString *)clientID
{
//#error Replace the following with the data you got when registering your app at: https://oauth.yandex.ru/
    return @"f337db6f13b6438898a0893eb506e2b3";
}

-(NSString *)redirectURL
{
//#warning Replace the following with the data you got when registering your app at: https://oauth.yandex.ru/
    return @"https://oauth.yandex.ru/verification_code";
}

- (void)OAuthLoginSucceededWithToken:(NSString *)token
{
    self.session.OAuthToken = token;
    //self.yaDisk.navigationItem.rightBarButtonItem = nil;
    
    self.yaDisk.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addFileToDisk)];
    
    [self.authVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)OAuthLoginFailedWithError:(NSError *)error
{
    NSLog(@"It's time to PANIC: %@", error);
    [self.authVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)addFileToDisk {
    
    [self.yaDisk uploadFile];
}

@end
