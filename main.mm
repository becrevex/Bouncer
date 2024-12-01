#import <Cocoa/Cocoa.h>
//compile: clang++ -o SimpleGame main.mm -framework Cocoa


// Ball structure
struct Ball {
    float x, y;
    float dx, dy;
    float radius;
};

// Global ball instance
Ball ball = {100.0f, 100.0f, 2.0f, 2.0f, 20.0f};

// Game view interface
@interface GameView : NSView
@end

@implementation GameView

- (void)mouseDown:(NSEvent *)event {
    NSPoint location = [event locationInWindow];
    ball.x = location.x;
    ball.y = location.y;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint location = [event locationInWindow];
    ball.x = location.x;
    ball.y = location.y;
    [self setNeedsDisplay:YES];
}


- (void)keyDown:(NSEvent *)event {
    switch ([event keyCode]) {
        case 123: //left
            ball.dx = -2.0f;
            break;
        case 124: //right
            ball.dx = 2.0f;
            break;
        case 125: //down
            ball.dy = -2.0f;
            break;
        case 126: //up
            ball.dy = 2.0f;
            break;
        default:
            [super keyDown:event];
            break;
    }
}

// enabling key press handlling
- (BOOL)acceptFirstResponder {
    return YES;

}

- (void)drawRect:(NSRect)dirtyRect {
    // Set the background color
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);

    // Draw the ball
    [[NSColor whiteColor] setFill];
    NSRect ballRect = NSMakeRect(ball.x - ball.radius, ball.y - ball.radius, ball.radius * 2, ball.radius * 2);
    [[NSBezierPath bezierPathWithOvalInRect:ballRect] fill];
}

@end

// Game logic (updates ball position)
void updateGame() {
    ball.x += ball.dx;
    ball.y += ball.dy;

    // Check for collision with window edges
    if (ball.x - ball.radius < 0 || ball.x + ball.radius > 400) ball.dx = -ball.dx;
    if (ball.y - ball.radius < 0 || ball.y + ball.radius > 400) ball.dy = -ball.dy;
}

// App delegate interface
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSTimer *timer;
@end

@implementation AppDelegate {
    NSWindow *window;
    GameView *view;
    NSSlider *speedSlider;
    NSButton *startButton;
    NSButton *stopButton;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Create the window
    window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 400, 400)
                                          styleMask:(NSWindowStyleMaskTitled |
                                                     NSWindowStyleMaskClosable |
                                                     NSWindowStyleMaskResizable)
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
    [window setTitle:@"Bouncer"];
    [window makeKeyAndOrderFront:nil];

    // Create the game view
    view = [[GameView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
    [window setContentView:view];

    // Add a slider for speed control
    speedSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    [speedSlider setMinValue:0.5];
    [speedSlider setMaxValue:5.0];
    [speedSlider setTarget:self];
    [speedSlider setAction:@selector(sliderValueChanged:)];
    [[window contentView] addSubview:speedSlider];

    // Add start button
    startButton = [[NSButton alloc] initWithFrame:NSMakeRect(325, 10, 30, 30)];
    [startButton setTitle:@"Go"];
    [startButton setTarget:self];
    [startButton setAction:@selector(startGame)];
    [[window contentView] addSubview:startButton];

    // Add stop button
    stopButton = [[NSButton alloc] initWithFrame:NSMakeRect(360, 10, 30, 30)];
    [stopButton setTitle:@"No"];
    [stopButton setTarget:self];
    [stopButton setAction:@selector(stopGame)];
    [[window contentView] addSubview:stopButton];

    // Start the game loop
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0
                                                  target:self
                                                selector:@selector(gameLoop)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)startGame {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0
                                                  target:self
                                                selector:@selector(gameLoop)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopGame {
    [self.timer invalidate];
}


- (void)sliderValueChanged:(NSSlider *)slider {
    ball.dx = slider.floatValue;
    ball.dy = slider.floatValue;
}

- (void)gameLoop {
    updateGame();
    [view setNeedsDisplay:YES];
}
@end

// Main function
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}

