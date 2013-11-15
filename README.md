shapeRecognizer_iPhoneApp
=========================
Created by Stephen Dyksen (srd22) Artificial Intelligence

May 8, 2013

shapeRecognizer is an iPhone application that allows a user to take a photo using their phone of a shape.  After satisfied with the picture, the user can then press analyze and the application will tell the user if the shape in the picture looks most like a triangle, a circle, or a square.  

The shapeRecognizer folder contains all the files required for running shapeRecognizer.xcodeproj.  Note, shapeRecognizer.xcodeproj should be opened and the program can be run via the iPhone simulator.  Most of the files within the shapeRecognizer folder were automatically created by Xcode.  Those that were extensively edited include MainStoryboard.storyboard found in the en.lproj folder, shapeRecognizerViewController.h/m, and shapeAnalysis.h/m.

Documentation within these files specify if help was received, and where it was found.  The only truly "copied" code is the resizeImage function found within shapeAnalysis.m.  This code was found at the following url: http://iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-a-photo-to-a-new-uiimage.html
