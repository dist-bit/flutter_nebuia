import Flutter
import UIKit
import NebuIA

public class SwiftNebuiaPlugin: NSObject, FlutterPlugin {
    
    static var nebuIA: NebuIA!
    
    private func buildFingers(index: Finger, middle: Finger, ring: Finger, little: Finger, isSkip: Bool) -> [String : Any] {
        let index: [String : Any] = [
            "image": FlutterStandardTypedData(bytes: index.image!.jpegData(compressionQuality: 1.0)!),
            "score": index.score
        ]
        
        let middle: [String : Any] = [
            "image": FlutterStandardTypedData(bytes: middle.image!.jpegData(compressionQuality: 1.0)!),
            "score": middle.score
        ]
        
        let ring: [String : Any] = [
            "image": FlutterStandardTypedData(bytes: ring.image!.jpegData(compressionQuality: 1.0)!),
            "score": ring.score
        ]
        
        let little: [String : Any] = [
            "image": FlutterStandardTypedData(bytes: little.image!.jpegData(compressionQuality: 1.0)!),
            "score": little.score
        ]
        
        let fingers: [String : Any] = [
            "index" : index,
            "middle" :  middle,
            "ring" :  ring,
            "little" :  little,
            "skip": isSkip,
        ]
        
        return fingers
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nebuia_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftNebuiaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let controller : FlutterViewController = UIApplication.shared.delegate?.window??.rootViewController as! FlutterViewController
        nebuIA = NebuIA(controller: controller)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let data = call.arguments as! Dictionary<String, Any>;
        switch call.method {
        case "setReport":
            let report: String = data["report"] as! String;
            SwiftNebuiaPlugin.nebuIA.setReport(report: report)
            result(true)
            break
        case "setClientURI":
            let uri: String = data["uri"] as! String;
            SwiftNebuiaPlugin.nebuIA.setClientURI(uri: uri)
            result(true)
            break
        case "setTemporalCode":
            let code: String = data["code"] as! String;
            SwiftNebuiaPlugin.nebuIA.setCode(code: code)
            result(true)
            break
        case "createReport":
            SwiftNebuiaPlugin.nebuIA.createReport { report in
                result(report)
            }
            break
        case "faceLiveDetection":
            var response: Bool = false
            SwiftNebuiaPlugin.nebuIA.faceProof {
                if(!response) {
                    result(true)
                    response = true
                }
            }
            break
        case "fingerDetection":
            let hand: Int = data["hand"] as! Int;
            SwiftNebuiaPlugin.nebuIA.fingerprintScanner(hand: hand, completion: { index, middle, ring, little in
                let fingers = self.buildFingers(index: index, middle: middle, ring: ring, little: little, isSkip: false)
                result(fingers)
            }, skipWithFingers: { index, middle, ring, little in
                let fingers = self.buildFingers(index: index, middle: middle, ring: ring, little: little, isSkip: true)
                result(fingers)
            }, skip: {
                result("skip")
            })
            break
        case "generateWSQFingerprint":
            let fingerprint: FlutterStandardTypedData = data["image"] as! FlutterStandardTypedData;
            let file = Data(fingerprint.data)
            SwiftNebuiaPlugin.nebuIA.getFingerprintWSQ(image: UIImage(data: file, scale: 1.0)!) { wsq in
                result(FlutterStandardTypedData(bytes: wsq))
            }
            break
        case "recordActivity":
            let text:  Array<String> = data["text"] as! Array<String>;
            SwiftNebuiaPlugin.nebuIA.signerVideo(text: text) { path in
                result(path)
            }
            break
        case "documentDetection":
            SwiftNebuiaPlugin.nebuIA.idScanner(completion: {
                result(true)
            }, error: {
                result(false)
            })
            break
        case "captureAddressProof":
            SwiftNebuiaPlugin.nebuIA.takeAddress(completion: { data in
                result(data)
            }, error: {
                result(nil)
            })
            break
        case "saveAddress":
            let address: String = data["address"] as! String;
            SwiftNebuiaPlugin.nebuIA.saveAddress(address: address, completion:  { response in
                result(response)
            }, onError: { error in
                result(nil)
            })
            break
        case "saveEmail":
            let email: String = data["email"] as! String;
            SwiftNebuiaPlugin.nebuIA.saveEmail(email: email) { data in
                result(data)
            }
            break
        case "savePhone":
            let phone: String = data["phone"] as! String;
            SwiftNebuiaPlugin.nebuIA.savePhone(phone: phone) { data in
                result(data)
            }
            break
        case "generateOTPEmail":
            SwiftNebuiaPlugin.nebuIA.generateEmailOTP() { data in
                result(data)
            }
            break
        case "generateOTPPhone":
            SwiftNebuiaPlugin.nebuIA.generatePhoneOTP() { data in
                result(data)
            }
            break
        case "verifyOTPEmail":
            let code: String = data["code"] as! String;
            SwiftNebuiaPlugin.nebuIA.verifyEmailOTP(otp: code) { response in
                result(response)
            }
            break
        case "verifyOTPPhone":
            let code: String = data["code"] as! String;
            SwiftNebuiaPlugin.nebuIA.verifyPhoneOTP(otp: code) { response in
                result(response)
            }
            break
        case "getFaceImage":
            SwiftNebuiaPlugin.nebuIA.getDocumentFace { image in
                result(FlutterStandardTypedData(bytes: image.jpegData(compressionQuality: 1.0)!))
            }
            break
        case "getIDFrontImage":
            SwiftNebuiaPlugin.nebuIA.getDocumentIDSide(side: SIDE.front) { image in
                result(FlutterStandardTypedData(bytes: image.jpegData(compressionQuality: 1.0)!))
            }
            break
        case "getIDBackImage":
            SwiftNebuiaPlugin.nebuIA.getDocumentIDSide(side: SIDE.back) { image in
                result(FlutterStandardTypedData(bytes: image.jpegData(compressionQuality: 1.0)!))
            }
            break
        default:
            result("Have you done something new?")
        }
    }
}
