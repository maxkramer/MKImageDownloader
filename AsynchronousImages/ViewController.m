//
//  ViewController.m
//  AsynchronousImages
//
//  Created by Max Kramer on 05/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MKImageDownloader.h"

@implementation ViewController
@synthesize urls;

- (void)viewDidLoad
{
    self.urls = [NSArray arrayWithObjects:@"http://www.iphone-prix.com/wp-content/uploads/2012/05/iphone-5-apple.png", @"http://worldissmall.fr/blog/wp-content/uploads/2011/06/iphone5.jpg", @"http://www.gagneriphone.com/wp-content/themes/www.gagneriphone.com/iphone2.jpg", @"http://www.unsimpleclic.com/wp-content/uploads/2011/06/110623_iphone5_00.jpg", @"http://houstin.info/wp-content/uploads/2010/05/iphone_ultra_4g_concept.jpg", @"http://www.blogageek.com/wp-content/uploads/2010/06/iphone.jpg", @"http://www.sizlopedia.com/wp-content/uploads/iphone-concept-side.jpg", @"http://fc01.deviantart.net/fs70/f/2009/347/d/e/iPhone_4G_Concept_by_WilDchilDD.jpg", @"http://4.bp.blogspot.com/-sGgG7PxsAB4/T3Cm_a8mWlI/AAAAAAAAIWc/cQCbdGDiQ3w/s1600/iphone-concept.jpg", nil];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.urls count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView.frame.size.height / [self.urls count]);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const MKCellReusableIdentifier = @"MKCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MKCellReusableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKCellReusableIdentifier] autorelease];
    }
    
    if (cell.imageView.image == nil) {
    
        [MKImageDownloader downloadImageAtURL:[NSURL URLWithString:[self.urls objectAtIndex:indexPath.row]] completion:^(UIImage *image, NSError *error){
            
            if (error) {
                NSLog(@"CELL FOR ROW AT INDEX PATH ERROR ->%@<-", error.localizedDescription);
            }
            
            [cell.imageView setClipsToBounds:YES];
            
            [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
            
            [cell.imageView setImage:image];
            
            [cell setNeedsLayout];;
            
        }];
    
    }
    
    return cell;
    
}

- (void) dealloc {
    [urls release];
    [super dealloc];
}

@end
