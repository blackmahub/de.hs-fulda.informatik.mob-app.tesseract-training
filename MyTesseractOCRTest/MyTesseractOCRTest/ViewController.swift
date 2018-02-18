//
//  ViewController.swift
//  MyTesseractOCRTest
//
//  Created by mahbub on 2/13/18.
//  Copyright © 2018 Fulda University Of Applied Sciences. All rights reserved.
//

import UIKit
import TesseractOCR
import CoreImage
import CoreGraphics

class ViewController: UIViewController {

    @IBOutlet weak var floorPlanView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var floorPlanCIImage = CIImage(contentsOf: Bundle.main.url(forResource: "E1", withExtension: "png")!)!
        
        let orginalFloorPlanWidth = floorPlanCIImage.extent.width
        let orginalFloorPlanHeight = floorPlanCIImage.extent.height
        
        let imageContext = CIContext()
        let textDetectorInFloorPlan = CIDetector(ofType: CIDetectorTypeText, context: imageContext, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
        
//        let rectDetectorInFloorPlan = CIDetector(ofType: CIDetectorTypeRectangle, context: imageContext, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!

        let textFeatures = textDetectorInFloorPlan.features(in: floorPlanCIImage)
//        let rectFeatures = rectDetectorInFloorPlan.features(in: floorPlanImage)
        
//        print("Detected Rectangles: \(rectFeatures)\n")
        
        // doing image transformation in device coordinate system
        let scaleX = floorPlanView.frame.width / orginalFloorPlanWidth
        let scaleY = floorPlanView.frame.height / orginalFloorPlanHeight
        let affineScaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        var i = 0

//        for rectIndex in rectFeatures.indices {
        
//            let rectFeature = rectFeatures[rectIndex] as! CIRectangleFeature
        
            for textIndex in textFeatures.indices {
                
                let textFeature = textFeatures[textIndex] as! CITextFeature
                
//                if !rectFeature.bounds.contains(textFeature.bounds) {
//
//                    continue
//                }
                
                i += 1
                
//                print("Rectangle \(i): \(rectFeature.bounds)\n")
                
                print("For Text Rect \(i): Before Rect Increase: \(textFeature.bounds)\n")
                let textRect = textFeature.bounds.insetBy(dx: CGFloat(-5), dy: CGFloat(-5))
                print("For Text Rect \(i): After Rect Increase: \(textRect)\n")
                
                let textCGImage = imageContext.createCGImage(floorPlanCIImage, from: textRect)!
                
                do {
                    
                    try imageContext.writePNGRepresentation(of: CIImage(cgImage: textCGImage), to: URL(fileURLWithPath: "/Users/mahbub/Pictures/Raum-\(i).png"), format: kCIFormatRGBA8, colorSpace: floorPlanCIImage.colorSpace!, options: [:])
                    
                } catch let err {
                    print("\nERROR: " + err.localizedDescription + "\n")
                }
                
                if let tesseract = G8Tesseract(language: "eng") {
                    
                    let image = UIImage(cgImage: textCGImage).scaleImage(640)!
                    
                    tesseract.engineMode = .tesseractCubeCombined
                    tesseract.pageSegmentationMode = .auto
                    tesseract.image = image.g8_blackAndWhite()
                    tesseract.recognize()
                    let ocrText = tesseract.recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("Image \(i): OCR Result: " + ocrText + "\n")
                    
                    print("Image \(i): Rect Origin (X,Y): (\(textRect.origin.x), \(textRect.origin.y))\n")
                    print("Image \(i): Rect Min (X,Y): (\(textRect.minX), \(textRect.minY))\n")
                    print("Image \(i): Rect Max (X,Y): (\(textRect.maxX), \(textRect.maxY))\n")
                    
                    let buttonOrigin = CGPoint(x: textRect.origin.x, y: textRect.maxY)
                    let translationX = CGFloat(0)
                    let translationY = orginalFloorPlanHeight - (CGFloat(2) * buttonOrigin.y)
                    let affineTranslationTransform = CGAffineTransform(translationX: translationX, y: translationY)
                    
                    let textButton = UIButton(frame: CGRect(origin: buttonOrigin, size: textRect.size))
                    
                    textButton.backgroundColor = UIColor.green
                    textButton.setTitle(ocrText, for: .normal)
                    textButton.titleLabel!.font = textButton.titleLabel!.font.withSize(CGFloat(30))
                    textButton.setTitleColor(UIColor.black, for: .normal)
                    
                    // doing button transformation in device coordinate system
                    textButton.frame = textButton.frame
                                                    .applying(affineTranslationTransform)
                                                    .applying(affineScaleTransform)
                    
                    textButton.frame.origin.x += floorPlanView.frame.origin.x
                    textButton.frame.origin.y += floorPlanView.frame.origin.y
                    
                    textButton.addTarget(self, action: #selector(ViewController.navigateMeInThisRaum(_:)), for: .touchUpInside)
                    
                    view.addSubview(textButton)
//                    floorPlanView.addSubview(textButton)
                    
//                    let roomNumberView = UIImageView(image: UIImage(cgImage: textCGImage))
//                    roomNumberView.frame = CGRect(x: textRect.origin.x, y: floorPlanView.frame.height - textRect.maxY, width: textRect.width, height: textRect.height)
//
//                    floorPlanView.addSubview(roomNumberView)
                }
                
//                break
            }
//        }
        
        floorPlanCIImage = floorPlanCIImage.transformed(by: affineScaleTransform)
        
        // In UI Collection View Cell, start from (0,0)
        //        floorPlanView.frame = CGRect(x: CGFloat(10), y: CGFloat(30), width: floorPlanUIImage.size.width, height: floorPlanUIImage.size.height)
        floorPlanView.image = UIImage(ciImage: floorPlanCIImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func navigateMeInThisRaum(_ sender: UIButton) {
    
        print("\nHello Mahbub, I am here ...\n")
        
        let alert = UIAlertController(title: "Navigate Me", message: "Hello Mahbub, I am here ...", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

