//
//  AppDelegate.m
//  AsynchronousImages
//
//  Created by Max Kramer on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MKImageDownloader.h"

static NSInteger const secondsInMinute = 60;
static NSInteger const minutesInHour = 60;
static NSInteger const hoursInDay = 24;
static NSInteger const numberOfDays = 7;

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"first_run"] == FALSE) {
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"first_run"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        /* Add a timer to empty the cache every 'x' number of days */
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:(((secondsInMinute * minutesInHour) * hoursInDay) * numberOfDays) target:[MKImageDownloader sharedInstance] selector:@selector(dumpCache) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:(NSString *) kCFRunLoopDefaultMode];
        
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
        
    } 
    
    else {
        
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
        
    }
        
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
