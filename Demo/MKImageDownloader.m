//
//  MKImageDownloader.m
//  AsynchronousImages
//
//  Created by Max Kramer on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKImageDownloader.h"

#define kAppIdentifier [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleIdentifierKey]

static MKImageDownloader *shared = NULL;
static MKImageDownloadCompletion completionBlock = NULL;

@interface MKImageDownloader (private)

+ (BOOL) writeImageData:(NSData *) data toFilePath:(NSString *) filePath;
+ (BOOL) hasWrittenDataToFilePath:(NSString *) filePath;
+ (void) imageForURL:(NSString *) url callback:(void(^)(UIImage *image))callback;
NSString *filePathForURL(NSURL * url);

@end

@implementation MKImageDownloader

NSString *filePathForURL(NSURL * url) {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageDir = [documentsDirectory stringByAppendingPathComponent:kAppIdentifier];
    NSString *furl = [[[url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    return [imageDir stringByAppendingPathComponent:furl];
}

+ (MKImageDownloader *) sharedInstance {
    
    @synchronized(shared) {
        if (shared == NULL) {
            shared = [[super alloc] init];
        }
    }
    return shared;
    
}

+ (void) imageForURL:(NSString *)url callback:(void (^)(UIImage *))callback { 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:url]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            callback(image); 
        });
    });
}

+ (BOOL) hasWrittenDataToFilePath:(NSString *)filePath { 
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL) writeImageData:(NSData *) data toFilePath:(NSString *) filePath {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageDir = [documentsDirectory stringByAppendingPathComponent:kAppIdentifier];
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error)
            completionBlock(nil, error);
        
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        
        if (error) {
            completionBlock(nil, error);
            return NO;
        }
        
        return YES;
        
    }
    
    return NO;
}


+ (void) downloadImageAtURL:(NSURL *)url completion:(MKImageDownloadCompletion)_block {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if ([self hasWrittenDataToFilePath:filePathForURL(url)]) {
        [self imageForURL:filePathForURL(url) callback:^(UIImage * image) {
            _block(image, nil);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        return;
    }
    
    completionBlock = Block_copy(_block);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    static dispatch_once_t once;
    static const int max_in_flight = 4;  // Also try 4, 8, and maybe some other numbers
    static dispatch_semaphore_t limit = NULL;
    dispatch_once(&once, ^{
        limit = dispatch_semaphore_create(max_in_flight);
    });
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(limit, DISPATCH_TIME_FOREVER);
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self writeImageData:UIImagePNGRepresentation(image) toFilePath:filePathForURL(url)];
            [self imageForURL:filePathForURL(url) callback:^(UIImage *image) {
                completionBlock(image, nil);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
        });
        dispatch_semaphore_signal(limit);
    });
}

- (void) dumpCache {
    
    NSError *error = nil;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:kAppIdentifier] error:&error];
    
    if (error)
        return;
    
    for (NSString *filename in files) {
        NSString *filepath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:kAppIdentifier]  stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
    }
}

@end
