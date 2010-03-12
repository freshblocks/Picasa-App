//
//  AlbumViewController.h
//  Picasa App
//
//  Created by John Wang on 6/15/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataServiceGooglePhotos.h"
#import "GDataEntryPhoto.h"
#import "GDataEntryPhotoAlbum.h"
#import "GDataFeedPhoto.h"
#import "GDataFeedPhotoUser.h"
#import "GData.h"
#import "Three20/Three20.h"
#import "PhotoTest2Controller.h"

@interface AlbumViewController : UITableViewController <UIAlertViewDelegate,UIActionSheetDelegate>
 {
	 IBOutlet UITableViewController *tableViewController;
	 IBOutlet UILabel *label;
	 //IBOutlet UIView *loadingScreen;
	 NSMutableArray *listData;
	 //IBOutlet UINavigationController *navController;
	 GDataFeedPhotoUser *mUserAlbumFeed; // user feed of album entries
	 GDataFeedPhotoAlbum *albumFeed;
	 NSMutableArray *pictures;
	 //NSArray *photos;
	 BOOL hideAccessoryView;
	 PhotoTest2Controller *photosViewController;
}

@property (retain, nonatomic) UILabel *label;
@property (nonatomic, retain) NSMutableArray *listData;
@property (retain, nonatomic) UITableViewController *tableViewController;
@property (retain, nonatomic) GDataFeedPhotoUser *mUserAlbumFeed;
@property (retain, nonatomic) GDataFeedPhotoAlbum *albumFeed;
@property (retain, nonatomic) NSMutableArray *pictures;
@property (retain, nonatomic) PhotoTest2Controller *photosViewController;
@property (nonatomic) BOOL hideAccessoryView;

//@property (retain, nonatomic) NSArray *photos;
//@property (retain, nonatomic) UINavigationController *navController;

- (GDataServiceGooglePhotos *)googlePhotosService;
- (void)alertError;
- (void)fetchAllAlbums;
- (void)fetchSelectedAlbum:(GDataEntryPhotoAlbum *) albumEntry;
@end
