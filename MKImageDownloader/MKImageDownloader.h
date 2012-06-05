//
//  MKImageDownloader.h
//  AsynchronousImages
//
//  Created by Max Kramer on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MKImageDownloadCompletion)(UIImage * image, NSError *error);

@interface MKImageDownloader : NSObject 

+ (void) downloadImageAtURL:(NSURL *) url completion:(MKImageDownloadCompletion) _block;

+ (MKImageDownloader *) sharedInstance;

- (void) dumpCache;

@end
