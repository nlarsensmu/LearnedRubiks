//
//  OpenCVBridge.m
//  LookinLive
//
//  Created by Eric Larson.
//  Copyright (c) Eric Larson. All rights reserved.
//

#import "OpenCVBridge.hh"


using namespace cv;

@interface OpenCVBridge()
@property (nonatomic) cv::Mat image;
@property (strong,nonatomic) CIImage* frameInput;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGAffineTransform inverseTransform;
@property (atomic) cv::CascadeClassifier classifier;

@property NSMutableArray *colorsCublets;
@end

@implementation OpenCVBridge



#pragma mark ===Write Your Code Here===
// alternatively you can subclass this class and override the process image function


#pragma mark Define Custom Functions Here
-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    const int kCannyLowThreshold = 300;
    const int kFilterKernelSize = 5;
    
    
    
    
    switch (self.processType) {
        case 8:
        {
            //============================================
            // contour detector with rectangle bounding
            // Convert captured frame to grayscale
            vector<vector<cv::Point> > contours; // for saving the contours
            vector<cv::Vec4i> hierarchy;
            
            cvtColor(_image, frame_gray, CV_BGRA2GRAY);
            
            // Perform Canny edge detection
            Canny(frame_gray, image_copy,
                  kCannyLowThreshold,
                  kCannyLowThreshold*7,
                  kFilterKernelSize);
            
            // convert edges into connected components
            findContours( image_copy, contours, hierarchy, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
            
            // draw surrounding rect
            cv::Rect outer;
            outer.x = 0;
            outer.y = 0;
            outer.width = _bounds.size.width;
            outer.height = _bounds.size.width;
            
            int cubleWidth = outer.width/3;
            int error = 10;
            
            cv::rectangle(_image, outer, Scalar(255,0,0,100));
            
            // draw boxes around contours in the original image
            for( int i = 0; i< contours.size(); i++ )
            {
                cv::Rect boundingRect = cv::boundingRect(contours[i]);
                
                // if contur is cublet sized
                if(boundingRect.width > cubleWidth-error  && boundingRect.width < cubleWidth + error
                   && boundingRect.height > cubleWidth - error && boundingRect.height < cubleWidth + error) {
                    
                    // check if it is the current square i.e. 0 for now.
                    int x1 = boundingRect.x, x2 = boundingRect.x+boundingRect.width,
                    y1 = boundingRect.y, y2 = boundingRect.y + boundingRect.height;
                    
                    // Test if it is one of the cublet squares
                    /* Below is the order the squares are processed
                     0 1 2
                     3 4 5
                     6 7 8
                     */
                    for (int j = 0; j < 9; j++) {
                        int tx1 = (j%3)*cubleWidth, ty1 = (j/3)*cubleWidth, tx2 = ((j%3)+1)*cubleWidth, ty2 = ((j/3) + 1)*cubleWidth;
                        
                        if ((x1 < tx1+error && x1 > tx1-error) && (y1 < ty1+error && y1 > ty1 - error)
                            && (x2 < tx2+error && x2 > tx2-error) && (y2 < ty2+error && y2 > ty2 - error)
                            && _colorsCublets[j*3] == [NSNumber numberWithDouble:0.0]) {
                            Scalar avgPixelIntensity;
                            
                            cvtColor(_image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
                            
                            cv::Mat cubletImage = cv::Mat(image_copy, boundingRect);
                            
                            avgPixelIntensity = cv::mean( cubletImage );
                            double red = avgPixelIntensity.val[0];
                            double green = avgPixelIntensity.val[1];
                            double blue = avgPixelIntensity.val[2];
                            
                            _colorsCublets[j*3 + 0] = [NSNumber numberWithDouble:red];
                            _colorsCublets[j*3 + 1] = [NSNumber numberWithDouble:green];
                            _colorsCublets[j*3 + 2] = [NSNumber numberWithDouble:blue];
                        }
                        else {
                            cv::rectangle(_image, boundingRect, Scalar(255,255,255,255));
                        }
                    }
                    
                }
            }
            
            for (int i = 0; i < 9; i++) {
                if(_colorsCublets[i*3] != [NSNumber numberWithDouble:0.0]) {
                    int x = i%3, y = i/3;
                    int r = [_colorsCublets[i*3 + 0] intValue];
                    int g = [_colorsCublets[i*3 + 1] intValue];
                    int b = [_colorsCublets[i*3 + 2] intValue];
                    Scalar s = Scalar(r, g, b, 255);
                    cv::rectangle(_image, cv::Rect(x*cubleWidth, y*cubleWidth, cubleWidth, cubleWidth), s);
                }
            }
            
            break;
            
        }
            
        default:
            break;
            
    }
}


#pragma mark ====Do Not Manipulate Code below this line!====
-(void)setTransforms:(CGAffineTransform)trans{
    self.inverseTransform = trans;
    self.transform = CGAffineTransformInvert(trans);
}

-(void)loadHaarCascadeWithFilename:(NSString*)filename{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"xml"];
    self.classifier = cv::CascadeClassifier([filePath UTF8String]);
}

-(instancetype)init{
    self = [super init];
    
    _colorsCublets = [NSMutableArray array];
    for (int i = 0; i <9*3; i++) {
        [_colorsCublets addObject:[[NSNumber alloc] initWithDouble:0.0]];
    }
    
    if(self != nil){
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.transform = CGAffineTransformScale(self.transform, -1.0, 1.0);
        
        self.inverseTransform = CGAffineTransformMakeScale(-1.0,1.0);
        self.inverseTransform = CGAffineTransformRotate(self.inverseTransform, -M_PI_2);
        
        
    }
    return self;
}

#pragma mark Bridging OpenCV/CI Functions
// code manipulated from
// http://stackoverflow.com/questions/30867351/best-way-to-create-a-mat-from-a-ciimage
// http://stackoverflow.com/questions/10254141/how-to-convert-from-cvmat-to-uiimage-in-objective-c


-(void) setImage:(CIImage*)ciFrameImage
      withBounds:(CGRect)faceRectIn
      andContext:(CIContext*)context{
    
    CGRect faceRect = CGRect(faceRectIn);
    faceRect = CGRectApplyAffineTransform(faceRect, self.transform);
    ciFrameImage = [ciFrameImage imageByApplyingTransform:self.transform];
    
    
    //get face bounds and copy over smaller face image as CIImage
    //CGRect faceRect = faceFeature.bounds;
    _frameInput = ciFrameImage; // save this for later
    _bounds = faceRect;
    CIImage *faceImage = [ciFrameImage imageByCroppingToRect:faceRect];
    CGImageRef faceImageCG = [context createCGImage:faceImage fromRect:faceRect];
    
    // setup the OPenCV mat fro copying into
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(faceImageCG);
    CGFloat cols = faceRect.size.width;
    CGFloat rows = faceRect.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    _image = cvMat;
    
    // setup the copy buffer (to copy from the GPU)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                      // Height of bitmap
                                                    8,                         // Bits per component
                                                    cvMat.step[0],             // Bytes per row
                                                    colorSpace,                // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    // do the copy
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), faceImageCG);
    
    // release intermediary buffer objects
    CGContextRelease(contextRef);
    CGImageRelease(faceImageCG);
    
}

-(CIImage*)getImage{
    
    // convert back
    // setup NS byte buffer using the data from the cvMat to show
    NSData *data = [NSData dataWithBytes:_image.data
                                  length:_image.elemSize() * _image.total()];
    
    CGColorSpaceRef colorSpace;
    if (_image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    // setup buffering object
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // setup the copy to go from CPU to GPU
    CGImageRef imageRef = CGImageCreate(_image.cols,                                     // Width
                                        _image.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * _image.elemSize(),                           // Bits per pixel
                                        _image.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    // do the copy inside of the object instantiation for retImage
    CIImage* retImage = [[CIImage alloc]initWithCGImage:imageRef];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.bounds.origin.x, self.bounds.origin.y);
    retImage = [retImage imageByApplyingTransform:transform];
    retImage = [retImage imageByApplyingTransform:self.inverseTransform];
    
    // clean up
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return retImage;
}

-(CIImage*)getImageComposite{
    
    // convert back
    // setup NS byte buffer using the data from the cvMat to show
    NSData *data = [NSData dataWithBytes:_image.data
                                  length:_image.elemSize() * _image.total()];
    
    CGColorSpaceRef colorSpace;
    if (_image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    // setup buffering object
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // setup the copy to go from CPU to GPU
    CGImageRef imageRef = CGImageCreate(_image.cols,                                     // Width
                                        _image.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * _image.elemSize(),                           // Bits per pixel
                                        _image.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    // do the copy inside of the object instantiation for retImage
    CIImage* retImage = [[CIImage alloc]initWithCGImage:imageRef];
    // now apply transforms to get what the original image would be inside the Core Image frame
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.bounds.origin.x, self.bounds.origin.y);
    retImage = [retImage imageByApplyingTransform:transform];
    CIFilter* filt = [CIFilter filterWithName:@"CISourceAtopCompositing"
                          withInputParameters:@{@"inputImage":retImage,@"inputBackgroundImage":self.frameInput}];
    retImage = filt.outputImage;
    
    // clean up
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    retImage = [retImage imageByApplyingTransform:self.inverseTransform];
    
    return retImage;
}




@end
