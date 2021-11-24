//
//  ReadCubeViewController.swift
//  LearnedRubiks
//
//  Created by Nicholas Larsen on 11/22/21.
//

import UIKit
import AVFoundation

class ReadCubeViewController: UIViewController {
    
    // MARK: Class Properties
    
    var videoManager:VideoAnalgesic! = nil
    let bridge = OpenCVBridge()
    var detector:CIDetector! = nil
    
    
    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        // setup the OpenCV bridge nose detector, from file
        
        self.videoManager = VideoAnalgesic(mainView: self.view)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these properties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow,CIDetectorTracking:true] as [String : Any]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                  context: self.videoManager.getCIContext(), // perform on the GPU is possible
            options: (optsDetector as [String : AnyObject]))
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImageSwift)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        self.bridge.processType = 8
    }
    //MARK: Process image output
    func processImageSwift(inputImage:CIImage) -> CIImage{
        
        // detect faces
        let f = getFaces(img: inputImage)
        
        // if no faces, just return original image
//        if f.count == 0 { return inputImage }
        
        var retImage = inputImage
        
        // if you just want to process on separate queue use this code
        // this is a NON BLOCKING CALL, but any changes to the image in OpenCV cannot be displayed real time
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
//            self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//            self.bridge.processImage()
//        }
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCV
        // this is a BLOCKING CALL
//        self.bridge.setTransforms(self.videoManager.transform)
//        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
//        self.bridge.processImage()
//        retImage = self.bridge.getImage()
        
        //HINT: you can also send in the bounds of the face to ONLY process the face in OpenCV
        // or any bounds to only process a certain bounding region in OpenCV
        
        // Get square that is width/2
        let width = retImage.extent.width/2
        let imageWidth = retImage.extent.width
        let imageHeight = retImage.extent.height
        let rect = CGRect(x: imageWidth/2 - width/2, y: imageHeight/2 - width/2, width: width, height: width)
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: rect, // the first face bounds
                             andContext: self.videoManager.getCIContext())
        
        self.bridge.processImage()
        retImage = self.bridge.getImageComposite() // get back opencv processed part of the image (overlayed on original)
        
        return retImage
    }

    //MARK: Setup Face Detection
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
