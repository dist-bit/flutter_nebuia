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
    
    func keyToFillToDictionary(keyToFill: KeyToFill) -> [String: Any] {
        let placeDict: [String: Any] = [
            "w": keyToFill.place.w,
            "x": keyToFill.place.x,
            "h": keyToFill.place.h,
            "y": keyToFill.place.y,
            "page": keyToFill.place.page
        ]
        
        return [
            "description": keyToFill.description,
            "place": placeDict,
            "label": keyToFill.label,
            "key": keyToFill.key
        ]
    }

    // Función para convertir un objeto Template en un diccionario
    func templateToDictionary(template: Template) -> [String: Any] {
        let keysToFillArray = template.keysToFill.map { keyToFillToDictionary(keyToFill: $0) }
        
        return [
            "keysToFill": keysToFillArray,
            "name": template.name,
            "signsTypes": template.signsTypes,
            "description": template.description,
            "id": template.id,
            "requiresKYC": template.requiresKYC
        ]
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nebuia_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftNebuiaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let controller : FlutterViewController = UIApplication.shared.delegate?.window??.rootViewController as! FlutterViewController
        nebuIA = NebuIA()
        
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
            let showID: Bool = data["showID"] as! Bool;
            SwiftNebuiaPlugin.nebuIA.faceProof(useIDShow: showID) {
                if(!response) {
                    result(true)
                    response = true
                }
            }
            break
        case "fingerDetection":
            let hand: Int = data["hand"] as! Int;
            let skip: Bool = data["skip"] as! Bool;
            SwiftNebuiaPlugin.nebuIA.fingerprintScanner(hand: hand, skipStep: skip, completion: { index, middle, ring, little in
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
            let getNameFromId: Bool = data["getNameFromId"] as! Bool;
            SwiftNebuiaPlugin.nebuIA.signerVideo(text: text, getNameFromId: getNameFromId) { path in
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
        case "getReportData":
            SwiftNebuiaPlugin.nebuIA.getReportIDSummary { data in
                result(data)
            }
            break
            
        case "getSignatureTemplates":
            SwiftNebuiaPlugin.nebuIA.getSignatureTemplates { data in
                var dictionariesArray: [[String: Any]] = []
                for item in data {
                    
                    let templateDict = self.templateToDictionary(template: item)
                    dictionariesArray.append(templateDict)
                }
                
                result(dictionariesArray)
            }
            break
            
        case "signDocument":
            let documentId: String = data["documentId"] as! String;
            let email: String = data["email"] as! String;
            let data = data["params"] as! Dictionary<String, String>;
            
            var stringDictionary = data.mapValues { value in
                if let stringValue = value as? String {
                    return stringValue
                } else {
                    return String(describing: value)
                }
            }
            
            SwiftNebuiaPlugin.nebuIA.signDocument(documentId: documentId, email: email, params: &stringDictionary) { status in
               result(status)
            }
            break
            
        default:
            result("Have you done something new?")
        }
    }
}
