//
//  shapeRecognizerViewController.m
//  shapeRecognizerViewController.m defines the functions and items within the class that deal with user i/o
//
//  Created by Stephen Dyksen (srd22) for CS Final Project
//  May 8, 2013
//

#import "shapeRecognizerViewController.h"
#import "shapeAnalysis.h"
#import <QuartzCore/QuartzCore.h>



@interface shapeRecognizerViewController (){
    //Class Instance Variables
    UIImage *myImage;
    UIImage *gaussianImage;
    UIImage *grayImage;
    UIImage *resizedGrayImage;
    UIImage *edgeImage;
    NSString *shape;
}
@end

@implementation shapeRecognizerViewController

//Creates the setters and getters for the screen i/o items
@synthesize imageView = _imageView;
@synthesize gaussianImageView = _gaussianImageView;
@synthesize grayImageView = _grayImageView;
@synthesize edgeImageView = _edgeImageView;
@synthesize choosePhotoBtn = _choosePhotoBtn;
@synthesize takePhotoBtn = _takePhotoBtn;
@synthesize textOutput = _textOutput;
@synthesize analyzeButton = _analyzeButton;


//The following code sets up the GUI for obtaining an image and outputting it to the screen.
//getPhoto and imagePickerControler were modeled after tutorial code from the following:
//http://www.icodeblog.com/2009/07/28/getting-images-from-the-iphone-photo-library-or-camera-using-uiimagepickercontroller/

//getPhoto deals with user i/o for choosing a photo to analyze
-(IBAction) getPhoto:(id) sender {
    
    //Create a UIImagePickerController instance
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
    
    //Determine what button was chosen (button for choosing photo from library, or from camera)
	if((UIButton *) sender == _choosePhotoBtn) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
	} else {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
	}
    
	[self presentViewController:picker animated:NO completion: nil];
}



//imagePickerController acquires the image chosen by the user and sets it to the value of myImage
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[[picker presentingViewController ]dismissViewControllerAnimated:YES completion:nil];
	_imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    myImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    //Display an initial message to the user
    UILabel *nameDisplay = self.textOutput;
    nameDisplay.text = @"Press to Analyze";
    _analyzeButton.enabled = YES;
}



//analyzePhoto creates an instance of the shapeAnalysis class to analyze myImage and output the resuting shape prediction
- (IBAction)analyzePhoto:(id)sender {
    UILabel *nameDisplay = self.textOutput;
    
    //Create an instance of shapeAnalysis
    shapeAnalysis *aShapeAnalyzer = [[shapeAnalysis alloc]init];
    
    //Resize myImage so that it will not cause memory issues
    myImage = [aShapeAnalyzer resizeImage:myImage :myImage.size.height/10 :myImage.size.width/10 ];
    
    //Convert myImage to grayscale image called grayImage and display it
    grayImage = [aShapeAnalyzer getGrayImage:myImage];
    _grayImageView.image = grayImage;
    
    //Convert grayImage to blurred image called gaussianImage and display it
    gaussianImage = [aShapeAnalyzer getGaussianImage:grayImage];
    _gaussianImageView.image = gaussianImage;
    
    //Locate and draw edges on gaussianImage, resulting in edgeImage and display it
    edgeImage = [aShapeAnalyzer getEdgeImage:gaussianImage];
    _edgeImageView.image = edgeImage;
    
    //Determine the shape found within edgeImage and output the result to the screen
    shape = [aShapeAnalyzer whatsMyShape:edgeImage];
    nameDisplay.text = shape;
    
    _analyzeButton.enabled = NO;
}



@end