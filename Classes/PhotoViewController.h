//
//  PhotoViewController.h
//  Picasa App
//
//  Created by John Wang on 7/8/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//
#import "Three20/Three20.h"
#import <UIKit/UIKit.h>
#import "GData.h"

@interface PhotoViewController : TTPhotoViewController <UIAlertViewDelegate,UIActionSheetDelegate,UITableViewDelegate> {
	GDataEntryPhoto *photo;
	GDataServiceGooglePhotos *googlePhotosService;
	NSMutableArray *pictures;
	GDataEntryPhotoAlbum *albumEntry;
	GDataFeedPhotoAlbum *albumFeed;
	NSArray *albums;
	NSNumber *currentAlbum;
}

@property (nonatomic, retain) GDataEntryPhoto *photo;
@property (nonatomic, retain) GDataServiceGooglePhotos *googlePhotosService;
@property (nonatomic, retain) NSMutableArray *pictures;
@property (nonatomic, retain) GDataEntryPhotoAlbum *albumEntry;
@property (nonatomic, retain) GDataFeedPhotoAlbum *albumFeed;
@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, retain) NSNumber *currentAlbum;

-(void)moveSelectedPhotoToAlbum:(GDataEntryPhotoAlbum *)albumEntry;
@end
