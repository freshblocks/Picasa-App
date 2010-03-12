//
//  PhotoInfoViewController.h
//  Picasa App
//
//  Created by John Wang on 7/12/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"
#import <Three20/Three20.h>

@interface PhotoInfoViewController : TTTableViewController {
	GDataEntryPhoto *photo;
	GDataServiceGooglePhotos *googlePhotosService;

}
@property (nonatomic, retain) GDataEntryPhoto *photo;
@property (nonatomic, retain) GDataServiceGooglePhotos *googlePhotosService;

@end
