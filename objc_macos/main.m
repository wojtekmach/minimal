#import <AppKit/AppKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign) NSWindow *window;

@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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

    int mask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable; // | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(10, 10, 200, 200) styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    [_window setTitle:appName];
    [_window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
    [_window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        AppDelegate *delegate = [[AppDelegate alloc] init];
        NSApplication *app = [NSApplication sharedApplication];
        app.delegate = delegate;
        NSApplicationMain(argc, argv);
    }
}
