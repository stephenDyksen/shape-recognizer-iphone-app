//
//  shapeAnalysis.h
//  shapeAnalysis.h provides declarations for the functions that will be used in the shapeAnalysis class to modify images and recognize a shape within the image.
//
//  Created by Stephen Dyksen (srd22) for CS Final Project
//  May 8, 2013
//

#import <Foundation/Foundation.h>

@interface shapeAnalysis : NSObject


/*
 This method returns a string when called, and takes no arguments
 */
-(NSString *) analyzeText;


/*
 This function takes in: UIImage *    an image
 width        desired new width for image
 height       desired new height for image
 Returned is a UIImage * that is a resized version of the received image
 */
-(UIImage *)resizeImage:(UIImage *)image :(NSInteger) width :(NSInteger) height;


/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that is a grayscale version of the received image
 */
-(UIImage *) getGrayImage:(UIImage *) anImage;


/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that is a gaussian blurred version of the received image
 */
-(UIImage *) getGaussianImage:(UIImage *) anImage;


/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that displays the edges found in the original picture in black
 */
-(UIImage *) getEdgeImage:(UIImage *) anImage;


/*
 This function takes in: UIImage *    an image
 Returned is an NSString * of the most probable shape found within the image (Circle, Triangle, or Square)
 */
-(NSString *) whatsMyShape:(UIImage *) anImage;


@end


