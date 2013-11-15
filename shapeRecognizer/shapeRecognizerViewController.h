//
//  shapeRecognizerViewController.h
//  shapeRecognizerViewController.h declares the functions and items found within the class for user i/o
//
//  Created by Stephen Dyksen (srd22) for CS Final Project
//  May 8, 2013
//

#import <UIKit/UIKit.h>

@interface shapeRecognizerViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate >

//Link the objects in the GUI with appropriate properties
/*
 weak refers to storage property
 nonatomic refers to not-threadsafe functionality
 IBOutlet is typedef'd to nothing so is skipped by compiler, but is used by X-Code for recognition purposes
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *grayImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gaussianImageView;
@property (weak, nonatomic) IBOutlet UIImageView *edgeImageView;

@property (nonatomic, retain) IBOutlet UIButton *choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *analyzeButton;

@property (weak, nonatomic) IBOutlet UILabel *textOutput;

//Obtains the photo
-(IBAction) getPhoto:(id) sender;

@end
