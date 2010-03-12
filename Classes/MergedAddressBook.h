//
//  MergedAddressBook.h
//  Picasa App
//
//  Created by John Wang on 7/20/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "GData.h"
@interface MergedAddressBook : TTAddressBookDataSource {
	GDataFeedContactGroup* mGroupFeed;
	UIApplication *app;
}
@property (nonatomic, retain) UIApplication *app;
- (void)fetchAllGroupsAndContacts;
- (void)fetchAllContacts;
- (void)setGroupFeed:(GDataFeedContactGroup *)feed;
- (GDataFeedContactGroup *)groupFeed;
@end