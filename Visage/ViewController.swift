//
//  ViewController.swift
//  Facecap
//
//  Created by Tamas Kemenczy on 8/12/21.
//

import UIKit
import ARKit
import SwiftOSC

let addrFace = OSCAddressPattern("/visage")

class ViewController: UIViewController, UITextFieldDelegate, ARSCNViewDelegate, ARSessionDelegate {
    
    private var defaults = UserDefaults.standard
    
    var address : String = "localhost:8080"
    var ipaddr : String = "localhost"
    var port : Int = 8080
    var client = OSCClient(address:"localhost", port: 8080)
    var last : UInt64 = 0
    var delta : Int = 0
    var data : [Float] = [Float](repeating: 0.0, count: 63)
        
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var deltaField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)

        let addr = defaults.string(forKey: "address") ?? "localhost:8080"
        addressField.text = addr
        address = addr
        loadAddress(addr)
        
        sceneView.showsStatistics = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        addressField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.isWorldTrackingEnabled = false
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func loadAddress(_ addr : String) {
        let tokens = addr.components(separatedBy: ":")
        if tokens.count == 2 {
            ipaddr = tokens[0]
            port = Int(tokens[1]) ?? 8080
            client = OSCClient(address:ipaddr, port:port)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func addressFieldEdited(_ sender: UITextField) {
        if let text = sender.text {
            if text != address {
                address = text
                defaults.set(address, forKey: "address")
                loadAddress(address)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return node
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let face = anchors[0] as? ARFaceAnchor else {
            return
        }
        
        let now: UInt64 = DispatchTime.now().uptimeNanoseconds
        delta = Int(now - last) / 1000000
        last = now
        deltaField.text = String(delta)
        
        // blendshapes
        
        data[ 0] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.browInnerUp]!.floatValue
        data[ 1] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.browDownLeft]!.floatValue
        data[ 2] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.browDownRight]!.floatValue
        data[ 3] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.browOuterUpLeft]!.floatValue
        data[ 4] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.browOuterUpRight]!.floatValue
        data[ 5] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookUpLeft]!.floatValue
        data[ 6] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookUpRight]!.floatValue
        data[ 7] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookDownLeft]!.floatValue
        data[ 8] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookDownRight]!.floatValue
        data[ 9] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookInLeft]!.floatValue
        data[10] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookInRight]!.floatValue
        data[11] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookOutLeft]!.floatValue
        data[12] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeLookOutRight]!.floatValue
        data[13] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeBlinkLeft]!.floatValue
        data[14] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeBlinkRight]!.floatValue
        data[15] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintLeft]!.floatValue
        data[16] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeSquintRight]!.floatValue
        data[17] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeWideLeft]!.floatValue
        data[18] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.eyeWideRight]!.floatValue
        data[19] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekPuff]!.floatValue
        data[20] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekSquintLeft]!.floatValue
        data[21] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.cheekSquintRight]!.floatValue
        data[22] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.noseSneerLeft]!.floatValue
        data[23] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.noseSneerRight]!.floatValue
        data[24] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.jawOpen]!.floatValue
        data[25] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.jawForward]!.floatValue
        data[26] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.jawLeft]!.floatValue
        data[27] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.jawRight]!.floatValue
        data[28] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFunnel]!.floatValue
        data[29] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPucker]!.floatValue
        data[30] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLeft]!.floatValue
        data[31] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRight]!.floatValue
        data[32] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRollUpper]!.floatValue
        data[33] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthRollLower]!.floatValue
        data[34] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthShrugUpper]!.floatValue
        data[35] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthShrugLower]!.floatValue
        data[36] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthClose]!.floatValue
        data[37] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthSmileLeft]!.floatValue
        data[38] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthSmileRight]!.floatValue
        data[39] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFrownLeft]!.floatValue
        data[40] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthFrownRight]!.floatValue
        data[41] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthDimpleLeft]!.floatValue
        data[42] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthDimpleRight]!.floatValue
        data[43] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthUpperUpLeft]!.floatValue
        data[44] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthUpperUpRight]!.floatValue
        data[45] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLowerDownLeft]!.floatValue
        data[46] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthLowerDownRight]!.floatValue
        data[47] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPressLeft]!.floatValue
        data[48] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthPressRight]!.floatValue
        data[49] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthStretchLeft]!.floatValue
        data[50] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.mouthStretchRight]!.floatValue
        data[51] = face.blendShapes[ARFaceAnchor.BlendShapeLocation.tongueOut]!.floatValue
        
        // transforms
        
        let eyeLeft = face.leftEyeTransform.eulerAngles
        let eyeRight = face.rightEyeTransform.eulerAngles
        let headRot = face.transform.eulerAngles
        
        data[52] = face.transform.columns.3[0]
        data[53] = face.transform.columns.3[1]
        data[54] = face.transform.columns.3[2]
        data[55] = -headRot.z
        data[56] = headRot.y
        data[57] = headRot.x
        data[58] = -eyeLeft.z
        data[59] = eyeLeft.y
        data[60] = -eyeRight.z
        data[61] = eyeRight.y
        
        // time

        data[62] = Float(now / 1000000) / 1000.0

        client.send(OSCMessage(addrFace, data))
    }
}

extension matrix_float4x4 {
    // Function to convert rad to deg
    func radiansToDegress(radians: Float32) -> Float32 {
        return radians * 180 / (Float32.pi)
    }
    var translation: SCNVector3 {
        get {
            return SCNVector3Make(columns.3.x, columns.3.y, columns.3.z)
        }
    }
    // Retrieve euler angles from a quaternion matrix
    var eulerAngles: SCNVector3 {
        get {
            // Get quaternions
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)

            // Deduce euler angles
            /// yaw (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let yaw = radiansToDegress(radians:atan2(siny, cosy))
            // pitch (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var pitch: Float
            if abs(sinp) >= 1 {
                pitch = radiansToDegress(radians:copysign(Float.pi / 2, sinp))
            } else {
                pitch = radiansToDegress(radians:asin(sinp))
            }
            /// roll (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let roll = radiansToDegress(radians:atan2(sinr, cosr))
            
            /// return array containing ypr values
            return SCNVector3(yaw, pitch, roll)
        }
    }
}
