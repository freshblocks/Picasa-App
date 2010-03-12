//
//  AddAlbumViewController.h
//  Picasa App
//
//  Created by John Wang on 7/4/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GData.h"

@interface AddAlbumViewController : UIViewController {
	IBOutlet UITextField *albumName;
	IBOutlet UITextField *albumDescription;
	GDataFeedPhotoUser *mUserAlbumFeed; // user feed of album entries
	GDataServiceGooglePhotos *googlePhotosService;
	GDataEntryPhotoAlbum *selectedPhotoAlbum;
	NSNumber *row;
}
@property (retain, nonatomic) UITextField *albumName;
@property (retain, nonatomic) UITextField *albumDescription;
@property (nonatomic, retain) GDataFeedPhotoUser *mUserAlbumFeed;
@property (nonatomic, retain) GDataServiceGooglePhotos *googlePhotosService;
@property (nonatomic, retain) GDataEntryPhotoAlbum *selectedPhotoAlbum;
@property (nonatomic, retain) NSNumber *row;

- (IBAction) cancelClick:(id)sender;
@end
