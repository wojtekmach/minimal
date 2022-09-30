#import <AppKit/AppKit.h>

@interface AppDelegate : NSApplication
@end

@implementation AppDelegate
@end

int main(int argc, char *argv[]) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    id menubar = [NSMenu new];
    id appMenuItem = [NSMenuItem new];
    [menubar addItem:appMenuItem];
    [NSApp setMainMenu:menubar];
    id appMenu = [NSMenu new];
    id appName = [[NSProcessInfo processInfo] processName];
    id quitTitle = [@"Quit " stringByAppendingString:appName];
    id quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle action:@selector(terminate:) keyEquivalent:@"q"] ;
    [appMenu addItem:quitMenuItem];
    [appMenuItem setSubmenu:appMenu];
    id window = [[NSWindow alloc] initWithContentRect:NSMakeRect(10, 10, 200, 200) styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:NO];
    [window setTitle:appName];
    [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [window makeKeyAndOrderFront:nil];

    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    dispatch_async(dispatch_get_main_queue(), ^{
      [NSApp activateIgnoringOtherApps:YES];
    });

    [NSApp run];
  }
}
