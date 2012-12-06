//
//  AppDelegate.m
//  RAW Importer
//
//  Created by Dave Thorup on 12/4/12.
//  Copyright (c) 2012 Dave Thorup. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define _IN_FLIGHT_ 4

static int s_filesImported = 0;

@interface AppDelegate (private)

//@property (nonatomic) int filesImported;

- (void) incrementImported;
- (void) importNextFile;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    //  import RAW files in the main bundle
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    _fileList = [NSMutableArray arrayWithArray: [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"images"]];
    
    //  begin importing files, each call to importNextFile is asynchronous and will call importNextFile
    //  after each import completes
    for ( int i = 0; i < _IN_FLIGHT_; i++ )
    {
        [self importNextFile];
    }
    
    
//    dispatch_queue_t queue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
//    
//    //  send the RAW import to GCD for asynchronous processing
//    dispatch_async( queue, ^{
//        NSArray *   files = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"images"];
//        
//        for ( NSString * path in files )
//        {
//            //  Read the file into memory using NSData
//            NSData *    data = [NSData dataWithContentsOfFile:path];
//            
//            if ( data != nil )
//            {
//                [self.assetLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock: ^(NSURL * assetUrl, NSError * err ){
//                    if ( err == nil )
//                        [self incrementImported];
//                    else
//                    {
//                        NSLog( @"Error! %@", [err localizedDescription] );
//                        NSLog( @"\tSuggestion: %@", [err localizedRecoverySuggestion] );
//                        NSLog( @"\tUser Info: %@", [[err userInfo] description] );
//                    }
//                }];
//            }
//        }
//    });
    
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

@implementation AppDelegate (private)

- (void) importNextFile
{
    @synchronized( self )
    {
        if ( [_fileList count] > 0 )
        {
            NSString * path = _fileList[0];
            
            //  remove the file from the list
            [_fileList removeObjectAtIndex:0];
            
            //  Read the file into memory using NSData
            NSData *    data = [NSData dataWithContentsOfFile:path];
            
            if ( data != nil )
            {
                //  write it to the asset library
                [self.assetLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock: ^(NSURL * assetUrl, NSError * err ){
                    if ( err == nil )
                    {
                        [self incrementImported];
                        [self importNextFile];
                    }
                    else
                    {
                        NSLog( @"Error! %@", [err localizedDescription] );
                        NSLog( @"\tSuggestion: %@", [err localizedRecoverySuggestion] );
                        NSLog( @"\tUser Info: %@", [[err userInfo] description] );
                    }
                }];
            }
        }
    }
}

- (void) incrementImported
{
    @synchronized( self )
    {
        //        self.filesImported = self.filesImported + 1;
        s_filesImported++;
        self.viewController.fileNumLabel.text = [NSString stringWithFormat:@"%d", s_filesImported];
    }
}

@end
