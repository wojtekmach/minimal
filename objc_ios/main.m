#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)options {
  CGRect mainScreenBounds = [[UIScreen mainScreen] bounds];
  self.window = [[UIWindow alloc] initWithFrame:mainScreenBounds];
  UIViewController *viewController = [[UIViewController alloc] init];
  viewController.view.backgroundColor = [UIColor whiteColor];
  viewController.view.frame = mainScreenBounds;

  UILabel *label = [[UILabel alloc] initWithFrame:mainScreenBounds];
  [label setText:@"Hello, World!"];
  [label setTextAlignment:NSTextAlignmentCenter];
  [viewController.view addSubview: label];

  self.window.rootViewController = viewController;
  [self.window makeKeyAndVisible];

  return YES;
}

@end

int main(int argc, char *argv[]) {
  printf("\n");
  int ret = fork();
  if (ret < 0) {
    fprintf(stderr, "could not fork\n");
    exit(1);
  } else if (ret == 0) {
    printf("[debug] child pid = %d\n", getpid());
    return 0;
  } else {
    printf("[debug] parent pid = %d\n", getpid());
  }

  @autoreleasepool {
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
