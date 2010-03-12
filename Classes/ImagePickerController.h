//
//  ImagePickerController.h
//  Picasa App
//
//  Created by John Wang on 6/29/09.
//  Copyright 2009 Fresh Blocks. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImagePickerController : UIViewController
<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDelegate> {
	IBOutlet UIImageView *imageView;
	IBOutlet UIButton *takePictureButton;
	IBOutlet UIButton *selectFromCameraRollButton;
}
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIButton *takePictureButton;
@property (nonatomic, retain) UIButton *selectFromCameraRollButton;

- (IBAction)getCameraPicture:(id)sender;
- (IBAction)selectExistingPicture;
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end
