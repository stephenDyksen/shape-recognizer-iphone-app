//
//  shapeAnalysis.m
//  shapeAnalysis.m implements the shapeAnalysis class functions that modify a given image and determine the shape found in that image.
//
//  Created by Stephen Dyksen (srd22) for CS Final Project
//  May 8, 2013
//

#import "shapeAnalysis.h"



@implementation shapeAnalysis
#include <math.h>                                                               //Used in rotating an image
static inline double radians (double degrees) {return degrees * M_PI/180;}      //Used in rotating an image



/*
 This method returns a string when called, and takes no arguments
 */
- (NSString *) analyzeText {
    return @"Now Analyzing!";
}



//UIImage resize code found at the following discussion page:
//It seriously took me over 5 hours to figure out how to rotate an image like this!!! Ugh!!!
//http://iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-a-photo-to-a-new-uiimage.html
/*
 This function takes in: UIImage *    an image
 width        desired new width for image
 height       desired new height for image
 Returned is a UIImage * that is a resized version of the received image
 */
-(UIImage *)resizeImage:(UIImage *)image :(NSInteger) width :(NSInteger) height {
	
    //Creates an image reference
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap;
	
    //Check for orientation and builds bitmap accordingly
	if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationDown){
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
	}
    
    //Checks for orientation and resets the bitmap orientation accordingly
	if (image.imageOrientation == UIImageOrientationLeft) {
//		NSLog(@"image orientation left");
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -height);
        
    } else if (image.imageOrientation == UIImageOrientationRight) {
//        NSLog(@"image orientation right");
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -width, 0);
        
    } else if (image.imageOrientation == UIImageOrientationUp) {
//        NSLog(@"image orientation up");
        
    } else if (image.imageOrientation == UIImageOrientationDown) {
//        NSLog(@"image orientation down");
        CGContextTranslateCTM (bitmap, width,height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    //Creates new image of desired specifications
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGColorSpaceRelease(colorSpaceInfo);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    //Return resulting image
    return result;
}



//getGrayImage converts an image to grayscale
//pixel data access techniques were modeled after a tutorial from the following:
//http://www.fiveminutes.eu/iphone-image-processing/
/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that is a grayscale version of the received image
 */
-(UIImage *) getGrayImage:(UIImage *) anImage {
    
    //Convert the image to type CGImage
    CGImageRef sourceImage = anImage.CGImage;
    
    //A reference to an immutable CFData object.
	CFDataRef theData;
    //Set equal to CGData of sourceImage
	theData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
    
    //Obtains the length of the pixel data of the CGImage
	int dataLength = CFDataGetLength(theData);
//    NSLog(@"%ld", (long)dataLength);
    
    //Make sure to create a mutable version of the data so it is editable
    //This tip received from https://github.com/esilverberg/ios-image-filters/issues/8
    CFMutableDataRef mutableData = CFDataCreateMutableCopy(NULL, dataLength, theData);
    
    //8-Bit Unsigned Integer pointer to theData
	UInt8 *pixelData = (UInt8 *) CFDataGetMutableBytePtr(mutableData);
    
    //Set for clever way of accessing the rgb values from pixelData
	int red = 0;
	int green = 1;
	int blue = 2;
    
    //Website that teaches rgb to grayscale formula... Interesting!
    //http://www.had2know.com/technology/rgb-to-gray-scale-converter.html
    
    //Adjust pixel values to convert to grayscale
    for (int index = 0; index < dataLength; index += 4) {
        
        float redValue = pixelData[index + red];
        float greenValue = pixelData[index + green];
        float blueValue = pixelData[index + blue];
        float pixelGSValue = 0.299*redValue + 0.587*greenValue + 0.114*blueValue;
        
        pixelData[index + red] = pixelGSValue;
        pixelData[index + green] = pixelGSValue;
        pixelData[index + blue] = pixelGSValue;
        
	}
    
    //Sets up a drawing environment based on our data
	CGContextRef context;
	context = CGBitmapContextCreate(pixelData,
                                    CGImageGetWidth(sourceImage),
                                    CGImageGetHeight(sourceImage),
                                    8,
                                    CGImageGetBytesPerRow(sourceImage),
                                    CGImageGetColorSpace(sourceImage),
                                    kCGImageAlphaPremultipliedLast);
    
    //Creates a UIImage using our defined context
	CGImageRef newCGImage = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:newCGImage];
    
    //Release storage used
	CGContextRelease(context);
	CFRelease(theData);
	CGImageRelease(newCGImage);
    
	return newImage;
}



//getGaussianImage creates a blurred version of a given image
/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that is a gaussian blurred version of the received image
 */
-(UIImage *) getGaussianImage:(UIImage *) anImage {
    
    //Convert the image to type CGImage
    CGImageRef sourceImage = anImage.CGImage;
    
    //Create location for image pixel data
    //A reference to an immutable CFData object.
    CFDataRef theData;
    
    //Set equal to CGData of sourceImage
	theData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
    
    //8-Bit Unsigned Integer pointer to theData
	UInt8 *pixelData = (UInt8 *) CFDataGetBytePtr(theData);
    
    //Length of data (should be 4*width*height)
	int dataLength = CFDataGetLength(theData);
    
    //Create location for new image data
    //A reference to an immutable CFData object.
	CFDataRef newData;
    
    //Set equal to CGData of sourceImage
	newData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
    
    //Make sure to create a mutable version of the data so it is editable
    //Help received from https://github.com/esilverberg/ios-image-filters/issues/8
    CFMutableDataRef mutableData = CFDataCreateMutableCopy(NULL, dataLength, newData);
    
    //8-Bit Unsigned Integer pointer to theData
	UInt8 *newPixelData = (UInt8 *) CFDataGetMutableBytePtr(mutableData);
    
    
    //Set for clever way of accessing the rgb values from pixelData
	int red = 0;
	int green = 1;
	int blue = 2;
    
    //Obtains the width of the image
    NSInteger width = CGImageGetWidth(sourceImage);
//    NSLog(@"%ld", (long)width);
    
    //Obtains the height of the image
    NSInteger height = CGImageGetHeight(sourceImage);
//    NSLog(@"%ld", (long)height);
    
    
    //Run through image and apply gaussian blur technique with a 1 pixel width gaussian kernel
    //Learn about Gaussian Blur: http://www.swageroo.com/wordpress/how-to-program-a-gaussian-blur-without-using-3rd-party-libraries/
    for (int row = (dataLength/height)+4; row < dataLength-(dataLength/height); row += dataLength/height){
        for (int index = row; index < (row+(4*(width-2))); index += 4){
            int pixel1 = pixelData[(index - ((dataLength/height)+4)) + red];
            int pixel2 = pixelData[(index - (dataLength/height)) + red];
            int pixel3 = pixelData[(index - ((dataLength/height)-4)) + red];
            int pixel4 = pixelData[(index - 4) + red];
            int pixel5 = pixelData[index + red];
            int pixel6 = pixelData[(index + 4) + red];
            int pixel7 = pixelData[(index + ((dataLength/height)-4)) + red];
            int pixel8 = pixelData[(index + (dataLength/height)) + red];
            int pixel9 = pixelData[(index + ((dataLength/height)+4)) + red];
            
            int newPixelNumber = 0.0947416*pixel1 + 0.118318*pixel2 + 0.0947416*pixel3 +
                                 0.118318*pixel4 + 0.147761*pixel5 + 0.118318*pixel6 +
                                 0.0947416*pixel7 + 0.118318*pixel8 + 0.0947416*pixel9;
            
            newPixelData[index + red] = newPixelNumber;
            newPixelData[index + green] = newPixelNumber;
            newPixelData[index + blue] = newPixelNumber;
        }
    }
    
    //Sets up a drawing environment based on our data
	CGContextRef context;
	context = CGBitmapContextCreate(newPixelData,
                                    CGImageGetWidth(sourceImage),
                                    CGImageGetHeight(sourceImage),
                                    8,
                                    CGImageGetBytesPerRow(sourceImage),
                                    CGImageGetColorSpace(sourceImage),
                                    kCGImageAlphaPremultipliedLast);
    
    //Creates a UIImage using our defined context
	CGImageRef newCGImage = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:newCGImage];
    
    //Release storage used
	CGContextRelease(context);
	CFRelease(theData);
    CFRelease(newData);
	CGImageRelease(newCGImage);
    
	return newImage;
}



//getEdgeImage finds the horizontal edges located within a given image
/*
 This function takes in: UIImage *    an image
 Returned is a UIImage * that displays the edges found in the original picture in black
 */
-(UIImage *) getEdgeImage:(UIImage *) anImage {
    
    //Convert the image to type CGImage
    CGImageRef sourceImage = anImage.CGImage;
    
    //Obtains the width of the image
    NSInteger width = CGImageGetWidth(sourceImage);
    NSLog(@"Image Width");
    NSLog(@"%ld", (long)width);
   
    //Obtains the height of the image
    NSInteger height = CGImageGetHeight(sourceImage);
    NSLog(@"Image Height");
    NSLog(@"%ld", (long)height);

    
    //A reference to a immutable CFData object.
	CFDataRef theData;
    //Set equal to CGData of sourceImage
	theData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
    
	int dataLength = CFDataGetLength(theData);
    
    //Make sure to create a mutable version of the data so it is editable
    //Help received from https://github.com/esilverberg/ios-image-filters/issues/8
    CFMutableDataRef mutableData = CFDataCreateMutableCopy(NULL, dataLength, theData);
    
    //8-Bit Unsigned Integer pointer to theData
	UInt8 *pixelData = (UInt8 *) CFDataGetMutableBytePtr(mutableData);
    
    //Check for edges using a two pixel kernel and apply black accorgingly, else white.
    for (int index = 0; index < dataLength-4; index += 4) {
        
        int pixel0Value = pixelData[index];
        int pixel1Value = pixelData[index + 4];
        int difference = abs(pixel0Value - pixel1Value);
        
        if(difference > 5){
            pixelData[index + 0] = 0;
            pixelData[index + 1] = 0;
            pixelData[index + 2] = 0;
        }
        else {
            pixelData[index + 0] = 255;
            pixelData[index + 1] = 255;
            pixelData[index + 2] = 255;
        }
        //Whites out the edges of the images (top, left, two pixels on right, bottom)
        if (index <= (dataLength/height) || index%(dataLength/height) == 0 || (index-((width*4)-4))%(dataLength/height) == 0 || (index-((width*4)-8))%(dataLength/height) == 0 || index >= ((dataLength/height)*(height-1))){
            pixelData[index + 0] = 255;
            pixelData[index + 1] = 255;
            pixelData[index + 2] = 255;
        }
        
	}
    
    //Sets up a drawing environment based on our data
	CGContextRef context;
	context = CGBitmapContextCreate(pixelData,
                                    CGImageGetWidth(sourceImage),
                                    CGImageGetHeight(sourceImage),
                                    8,
                                    CGImageGetBytesPerRow(sourceImage),
                                    CGImageGetColorSpace(sourceImage),
                                    kCGImageAlphaPremultipliedLast);
    
    //Creates a UIImage using our defined context
	CGImageRef newCGImage = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:newCGImage];
    
    //Release storage used
	CGContextRelease(context);
	CFRelease(theData);
	CGImageRelease(newCGImage);
    
	return newImage;
}



//whatsMyShape detemines the most probable shape within the image (Circle, Triangle, or Square)
/*
 This function takes in: UIImage *    an image
 Returned is an NSString * of the most probable shape found within the image (Circle, Triangle, or Square)
 */
-(NSString *) whatsMyShape:(UIImage *) anImage {
    
    //Convert the image to type CGImage
    CGImageRef sourceImage = anImage.CGImage;
    
    //Obtains the width of the image
    NSInteger width = CGImageGetWidth(sourceImage);
    
    //Obtains the height of the image
    NSInteger height = CGImageGetHeight(sourceImage);
    
    //A reference to an immutable CFData object.
	CFDataRef theData;
    //Set equal to CGData of sourceImage
	theData = CGDataProviderCopyData(CGImageGetDataProvider(sourceImage));
    
    //Obtain length of data
    int dataLength = CFDataGetLength(theData);
    
    //8-Bit Unsigned Integer pointer to theData
	UInt8 *pixelData = (UInt8 *) CFDataGetBytePtr(theData);
    
    //Set for accessing the red value from pixelData
	int red = 0;
    
    //This mutable array will hold width values of the shape present in the image
    NSMutableArray *leftToRightScan = [NSMutableArray array];
    
    //Scan each row of the image looking for horizontal slices of a shape
    //If a slice is present, the slice's width is added to the array, leftToRightScan
    int counter = 0;
	for (int row = (dataLength/height)+4; row < dataLength-(dataLength/height); row += dataLength/height) {
        int minimumBlack = 0;
        int maximumBlack = 0;
        int totalLength = 0;
        for (int index = row; index < (row+(4*(width-2))); index += 4) {
            if (pixelData[index + red] == 0){
                if(minimumBlack == 0){
                    minimumBlack = counter;
                    maximumBlack = counter;
                }
                else{
                    maximumBlack = counter;
                }
            }
            counter+=4;
        }
        totalLength = (maximumBlack - minimumBlack)/4;
        if(totalLength > 0){
            [leftToRightScan addObject: [NSNumber numberWithInt: totalLength]];
        }
    }
    
    
    //Obtain array length
    int arrayLength = [leftToRightScan count];
    
    //Create new arrays with optimal shape model values for the three shapes
    
    //Array to model a circle
    //Add incrementing values
    NSMutableArray* circleArray = [NSMutableArray array];
    for(double i = -1.0*(arrayLength/2.0)+0.5; i < 0.0; i+=1.0){
        double circleValue = 2.0*sqrt(((arrayLength/2.0)*(arrayLength/2.0)) - (i*i));
//        NSLog(@"%ld", (long)circleValue);
        [circleArray addObject:[NSNumber numberWithDouble:(double)circleValue]];
    }
    //Add decrementing values
    for(double i = 0.0; i <= 1.0*(arrayLength/2.0)-0.5; i+=1.0){
        double circleValue = 2.0*sqrt(((arrayLength/2.0)*(arrayLength/2.0)) - (i*i));
//        NSLog(@"%ld", (long)circleValue);
        [circleArray addObject:[NSNumber numberWithDouble:(double)circleValue]];
    }
    
    
    //Array to model a triangle
    NSMutableArray* triangleArray = [NSMutableArray array];
    //Add values
    double triangleValue = 2.0;
    for(int i = 0; i<(arrayLength); i+=1){
//        NSLog(@"%ld", (long)triangleValue);
        [triangleArray addObject:[NSNumber numberWithDouble:(double)triangleValue]];
        triangleValue+=1.15;
    }

    
    //Array to model a square
    NSMutableArray* squareArray = [NSMutableArray array];
    //Add values
    int squareValue = arrayLength-4;
    for(int i = 0; i<(arrayLength); i+=1){
//        NSLog(@"%ld", (long)squareValue);
        [squareArray addObject:[NSNumber numberWithDouble:(double)squareValue]];
    }

    
    //Variables for the model-based prediction
    double circleModelDifference = 0;
    double triangleModelDifference = 0;
    double squareModelDifference = 0;
    
    //Calculate the differences between the values in leftToRightScan and the model arrays
    double cd, td, sd;
    for(int i=0; i<arrayLength; i++){
        double arrayValue = [[leftToRightScan objectAtIndex:i]doubleValue];
        double circleValue = [[circleArray objectAtIndex:i]doubleValue];
        double triangleValue = [[triangleArray objectAtIndex:i]doubleValue];
        double squareValue = [[squareArray objectAtIndex:i]doubleValue];
        cd = abs(arrayValue - circleValue);
        td = abs(arrayValue - triangleValue);
        sd = abs(arrayValue - squareValue);
        
        circleModelDifference  = circleModelDifference + cd;
        triangleModelDifference = triangleModelDifference + td;
        squareModelDifference = squareModelDifference + sd;
    }
    
    //Output width values to output-log in X-Code
    NSLog(@"Circle Difference");
    NSLog(@"%lu", (long)circleModelDifference);
    NSLog(@"Triangle Difference");
    NSLog(@"%lu", (long)triangleModelDifference);
    NSLog(@"Square Difference");
    NSLog(@"%lu", (long)squareModelDifference);
    
    //Based on the best match, return the predicted shape's name (looking for the lowest difference value)
    if(circleModelDifference < triangleModelDifference && circleModelDifference < squareModelDifference){
        return @"Circle!";
    }
    else if (triangleModelDifference < circleModelDifference && triangleModelDifference < squareModelDifference){
        return @"Triangle!";
    }
    else{
        return @"Square!";
    }
    
}

@end
