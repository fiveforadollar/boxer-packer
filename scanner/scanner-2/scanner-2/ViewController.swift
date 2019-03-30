//
//  ViewController.swift
//  scanner-2
//
//  Created by Michael Cesario on 2019-01-02.
//  Copyright © 2019 Michael Cesario. All rights reserved.
//

import AVFoundation
import Vision
import UIKit
import SceneKit
import ARKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var cameraView: UIView?
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var boxIDLabel: UILabel!
    @IBOutlet weak var setIDLabel: UILabel!
    
    var firstRun = false
    var box_id:Int?
    var set_id:Int?
    var box_ready = false
    var timer = Timer()
    var backButton : UIBarButtonItem!
    
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var lastRectObservation: VNRectangleObservation?
    
    func VNDetectRectanglesRequestCompletionBlock(request: VNRequest, error: Error?) {
        if let array = request.results {
            if array.count > 0 {
                let ob = array.first as? VNRectangleObservation
                //print("count: \(array.count)")
                DispatchQueue.main.async {
                    //let boxRect = ob!.boundingBox
                    //var transformedRect = self.transformRect(fromRect: boxRect, toViewRect: self.cameraView!)
                    //print(ob?.bottomLeft)
                    //print(ob?.bottomRight)
                    //print(ob?.topLeft)
                    //print(ob?.topRight)
                    
                    var transformedRect = ob!.boundingBox
                    transformedRect.origin.y = 1 - transformedRect.origin.y
                    
                    var convertedRect = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
                    
                    convertedRect.origin.y += 0.5 * convertedRect.height
                    convertedRect.origin.x += convertedRect.width
                    self.highlightView?.frame = convertedRect
                    
                    //let width = convertedRect.w topRight.x - ob!.topLeft.x
                    //let height = ob!.topLeft.y - ob!.bottomLeft.y
                    
                    //print("width")
                    //print(self.highlightView.frame.width)
                    //print("height")
                    //print(self.highlightView.frame.height)
                    
                    self.widthLabel.text = String(Int(self.highlightView.frame.width))
                    self.heightLabel.text = String(Int(self.highlightView.frame.height))
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }
        
        let request2 = VNDetectRectanglesRequest { (request, error) in
            self.VNDetectRectanglesRequestCompletionBlock(request: request, error: error)
        }
        
        do {
            request2.minimumConfidence = 0.7
            try self.visionSequenceHandler.perform([request2], on: pixelBuffer)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private lazy var captureSession: AVCaptureSession = {
        //builtInWideAngleCamera
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        
        return session
    }()
    
    // Then handle the button selection
    @objc func goBack() {
        // Here we just remove the back button, you could also disabled it or better yet show an activityIndicator
        self.navigationItem.leftBarButtonItem = nil
        
        let alert = UIAlertController(title: "Are you use you want to exit?", message: "All set data will be lost.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
            // Don't forget to re-enable the interactive gesture
            self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.navigationItem.leftBarButtonItem = self.backButton
        }))
        
        self.present(alert, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BaseColors.yellow
        self.cameraView?.backgroundColor = BaseColors.yellow
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        
        // Replace the default back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        
        //self.widthLabel.text = String(Int(self.view.frame.width))
        //self.heightLabel.text = String(Int(self.view.frame.height))
        
        // make the camera appear on the screen
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        
        // begin the session
        self.captureSession.startRunning()
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        
        scheduledTimerWithTimeInterval()
        
        getCurrent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        
        //Convert Vision Frame to UIKit Frame
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        return toRect
        
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.flow), userInfo: nil, repeats: true)
    }

    @objc func flow() {
        //getCurrent()
    }
    
    func checkBoxSuccess() {
        let parameters = [
            "boxID" : box_id,
            "setID" : set_id
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constants.baseURL + "checkrejected", method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let rejected = json["rejected"].boolValue
                    
                    if (rejected) {
                        self.view.makeToast("REJECTED", duration: 5.0, position: .center)
                    }
                    self.view.makeToast("ACCEPTED", duration: 5.0, position: .center)
                }
        }
    }
    
    func getCurrent() {
        print("getting current box and set")
        Alamofire.request(Constants.baseURL + "current", method: .get)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let currentBox = json["currentBoxID"].intValue
                    let currentSet = json["currentSetID"].intValue
                    
//                    if (!self.firstRun) {
//                        self.firstRun = false
//                        self.checkBoxSuccess()
//                    }
                    
                    if (self.box_id != nil && self.box_id != currentBox) {
                        self.checkBoxSuccess()
                    }
                    
                    self.box_id = currentBox
                    self.set_id = currentSet
                    
                    self.boxIDLabel.text = String(currentBox)
                    self.setIDLabel.text = String(currentSet)
                    
                    self.checkBoxReady(box_id: currentBox, set_id: currentSet)
                }
        }
    }
    
    
    func checkBoxReady(box_id:Int, set_id:Int) {
        let parameters = [
            "boxID" : box_id,
            "setID" : set_id
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constants.baseURL + "boxready", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let isReady = json["boxReady"].boolValue
                    
                    if (!isReady) {
                        print("box not ready!")
                        
                        // delay and loop back to getting current box and set
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.getCurrent()
                        }
                        
                    } else {
                        print("box ready!")
                        self.checkIfDataPopulated()
                    }
                }
        }
    }
    
    func sendDeviceData() {
        
        print("sending device data...")
        
        let parameters = [
            "device" : "p1",
            "CAM1LEN" : self.highlightView.frame.width,
            "CAM1WIDTH" : self.highlightView.frame.height
            ] as [String : Any]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constants.baseURL + "senddata", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let success = json["dataSet"].boolValue
                    if success {
                        print("successfully posted data")
                        
                        // delay and loop back to getting current box and set
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.getCurrent()
                        }
                        
                    } else {
                        self.sendDeviceData()
                    }
                }
        }
        
    }
    
    func checkIfDataPopulated() {
        let parameters = [
            "device" : "p1",
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constants.baseURL + "datacheck", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let populated = json["dataPopulated"].boolValue
                    
                    if (!populated) {
                        print("populating data now!")
                        self.sendDeviceData()
                    } else {
                        // delay and loop back to getting current box and set
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.getCurrent()
                        }
                    }
                }
        }
    }
    
    @IBAction func setDonePressed(_ sender: Any) {
        Alamofire.request(Constants.baseURL + "setdone", method: .get)
            .responseData { response in
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    let json = JSON.init(parseJSON: utf8Text)
                    let currentBox = json["currentBoxID"].intValue
                    let currentSet = json["currentSetID"].intValue
                    
                    self.box_id = currentBox
                    self.set_id = currentSet
            }
        }
    }
    
    @IBAction func boxReadyPressed(_ sender: Any) {
        
        if (self.box_id == nil) {
            print("getting current box data")
            getCurrent()
            return;
        }
        
        Alamofire.request(Constants.baseURL + "setboxready", method: .get)
            .responseData { response in
                if (response.response?.statusCode ?? 0 >= 200 && response.response?.statusCode ?? 0 < 300) {
                    print("set current box to ready")
                }
        }
    }
}

