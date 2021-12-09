//
//  OpenCVBridge.h
//  LookinLive
//
//  Created by Eric Larson.
//  Copyright (c) Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import "AVFoundation/AVFoundation.h"

#import "PrefixHeader.pch"

@interface OpenCVBridge : NSObject

@property (nonatomic) NSInteger processType;

// reset send squares functons
-(void) resetCublets;

-(NSMutableArray*) getCublets;

-(void) setProcessedColors:(NSArray*)colors;
-(void) setCapture:(bool) c;
-(bool) getCaptured;
// set the image for processing later
-(void) setImage:(CIImage*)ciFrameImage
      withBounds:(CGRect)rect
      andContext:(CIContext*)context;

-(CGRect) getBounds;
-(CGPoint) getPointInImage:(CGPoint)point;
-(CGPoint) getPointInImageInverse:(CGPoint)point;
-(CGRect) getRectTransformation:(CGRect) rect;
-(CGRect) getRectInverseTransformation:(CGRect) rect;
-(CGAffineTransform) getTransform;

//get the image raw opencv
-(CIImage*)getImage;

//get the image inside the original bounds
-(CIImage*)getImageComposite;

// call this to perfrom processing (user controlled for better transparency)
-(void)processImage;

// for the video manager transformations
-(void)setTransforms:(CGAffineTransform)trans;

-(void)loadHaarCascadeWithFilename:(NSString*)filename;

@end
