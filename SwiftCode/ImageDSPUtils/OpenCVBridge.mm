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
@property (nonatomic) NSArray* processedColors;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGAffineTransform inverseTransform;
@property (atomic) cv::CascadeClassifier classifier;
@property (nonatomic) bool capture;
@property (nonatomic) bool captured;
@property NSMutableArray *colorsCublets;
@end

@implementation OpenCVBridge



#pragma mark ===Write Your Code Here===
// alternatively you can subclass this class and override the process image function
-(void) setCapture:(bool) c {
    _capture = c;
}
-(bool) getCaptured {
    return _captured;
}
#pragma mark Define Custom Functions Here
-(void)resetCublets {
    
    for(int i = 0; i < 27; i++) {
        _colorsCublets[i] = [[NSNumber alloc] initWithDouble:0.0];
    }
    _processedColors = nil;
    _captured = false;
}
-(NSMutableArray*)getCublets {
    return _colorsCublets;
}


-(CGRect) getBounds {
    return _bounds;
}
-(CGPoint) getPointInImage:(CGPoint)point {
    return CGPointApplyAffineTransform(point, self.transform);
}
-(CGPoint) getPointInImageInverse:(CGPoint)point {
    return CGPointApplyAffineTransform(point, self.inverseTransform);
}

-(CGRect) getRectTransformation:(CGRect) rect {
    return CGRectApplyAffineTransform(rect, self.transform);
}
-(CGRect) getRectInverseTransformation:(CGRect) rect {
    return CGRectApplyAffineTransform(rect, self.inverseTransform);
}
-(CGAffineTransform) getTransform {
    return self.transform;
}

-(void)setProcessedColors:(NSArray*) colors {
    _processedColors = colors;
}

-(double)getMedian:(cv::Mat) image {
    
    NSMutableArray *redNumbers = [NSMutableArray array];
    NSMutableArray *blueNumbers = [NSMutableArray array];
    NSMutableArray *greenNumbers = [NSMutableArray array];
    
    for (int row = 0; row < image.rows; row ++) {
        for (int col = 0; col < image.cols; col ++) {
            [redNumbers addObject: [[NSNumber alloc] initWithDouble:image.at<double>(row, col, 0)]];
        }
    }
    
    [redNumbers sortUsingSelector:@selector(compare:)];
    
    
    return 0.0;
}
-(void)processImage{
    
    cv::Mat frame_gray,image_copy;
    const int kCannyLowThreshold = 100;
    const int kFilterKernelSize = 5;
    
    switch (self.processType) {
        case 9:
        {
            // draw surrounding rect
            int error2 = 10;
            cv::Rect outer;
            outer.x = 0;
            outer.y = 0;
            outer.width = _bounds.size.width;
            outer.height = _bounds.size.height;
            cv::Rect inner;
            inner.x = error2;
            inner.y = error2;
            inner.width = _bounds.size.width - 2*error2;
            inner.height = _bounds.size.height - 2*error2;
            int cubleWidth = outer.width/3;
            int cubleHeight = outer.height/3;
            
            cv::rectangle(_image, outer, Scalar(0,0,0,255));
            cv::rectangle(_image, inner, Scalar(0,0,0,255));
            
            //============================================
            // contour detector with rectangle bounding
            // Convert captured frame to grayscale
            vector<vector<cv::Point> > contours; // for saving the contours
            vector<cv::Vec4i> hierarchy;
            
            cvtColor(_image, frame_gray, CV_BGRA2GRAY);
            
            // Check if the cut is about in the frame
             
            // Is the contour about cube sized?
            int offset = 10;
            if (_capture){
                // Get the RGB of each 9th of outer
                for(int j = 0; j < 9; j++) {
                    int tx1 = (j%3)*cubleWidth, ty1 = (j/3)*cubleHeight, tx2 = ((j%3)+1)*cubleWidth, ty2 = ((j/3) + 1)*cubleHeight;
                    tx1 += offset;
                    ty1 += offset;
                    tx2 -= offset;
                    ty2 -= offset;
                    cv::Rect cubletRect = cv::Rect(tx1, ty1, cubleWidth - 2*offset, cubleHeight - 2*offset);
                    cv::Mat cubletImage = cv::Mat(_image, cubletRect);
                    Scalar avgPixelIntensity;
                    avgPixelIntensity = cv::mean( cubletImage );
                    double red = avgPixelIntensity.val[0];
                    double green = avgPixelIntensity.val[1];
                    double blue = avgPixelIntensity.val[2];
                    _colorsCublets[j*3 + 0] = [[NSNumber alloc] initWithDouble:red];
                    _colorsCublets[j*3 + 1] = [[NSNumber alloc] initWithDouble:green];
                    _colorsCublets[j*3 + 2] = [[NSNumber alloc] initWithDouble:blue];
                }
                _processedColors = nil;
                _captured = true;
                _capture = false;
            }
            for (int i = 0; i < 9; i++) {
                if(_colorsCublets[i*3] != [NSNumber numberWithDouble:0.0]) {
                    int x = i%3, y = i/3;
                    int r = [_colorsCublets[i*3 + 0] intValue];
                    int g = [_colorsCublets[i*3 + 1] intValue];
                    int b = [_colorsCublets[i*3 + 2] intValue];
                    Scalar s = Scalar(r, g, b, 10);

                    cv::Point * points = new cv::Point[4];
                    points[0] = cv::Point(x*cubleWidth, y*cubleHeight);
                    points[1] = cv::Point(x*cubleWidth + cubleWidth, y*cubleHeight);
                    points[2] = cv::Point(x*cubleWidth +cubleWidth, y*cubleHeight + cubleHeight);
                    points[3] = cv::Point(x*cubleWidth, y*cubleHeight + cubleHeight);

                    cv::fillConvexPoly(_image, points, 4, s);

                    if (_processedColors != nil && ![_processedColors[i]  isEqual: @""]) {

                        cv::Point textPoint = cv::Point(points[0].x, (points[0].y + points[2].y)/2);
                        NSString *ss = _processedColors[i];
                        const char *s = [ss UTF8String];

                        cv::putText(_image, s, textPoint, FONT_HERSHEY_PLAIN, 0.75, Scalar(0,0,0,255), 1, 2);
                    }

                    delete[] points;
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
    std::cout << faceRect.origin.x << " " <<  faceRect.origin.y << " ";
    std::cout << faceRect.size.width << " " << faceRect.size.height << std::endl;
    faceRect = CGRectApplyAffineTransform(faceRect, self.transform);
    std::cout << faceRect.origin.x << " " <<  faceRect.origin.y << " ";
    std::cout << faceRect.size.width << " " << faceRect.size.height << std::endl;
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
