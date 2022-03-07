

import UIKit
import CoreMotion
import AudioToolbox

class TestVC: UIViewController {

    
    private var iniX:CGFloat = 0.0
    private var iniY:CGFloat = 0.0
    private var startTime:Date? = nil
    
    private var isInside = true
    private var counter = 0
    private let counterMax = 20
    private var indexList:[Int] = []
    
    private var gyroData: [Double] = []
    
    private var radiusOK = false
    private var timeOK = false
    private var gyroHighOK = false
    private var gyroLowOk = false
    
    private var ROL:[Bool] = []
    private var TOL:[Bool] = []
    private var GLOL:[Bool] = []
    private var GHOL:[Bool] = []

    private var log:String = ""
    private var standards:[Bool] = []

    private var motionManager: CMMotionManager!

    
    @IBOutlet weak var v: ArrowCircle!
    @IBOutlet weak var l: UILabel!
    
    @IBOutlet weak var b: UIButton!
    @IBAction func bUpIn(_ sender: Any) {
        if counter == 0 { return }
        counter -= 1
        v.index = indexList[counter]/2
        radiusOK = false
        timeOK = false
        gyroHighOK = false
        gyroLowOk = false
        l.text = standards[counter] ? "\(counter+1): hard" : "\(counter+1): light"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        isInside = v.containsStart((touches.first?.location(in: v))!)
        if !isInside {return}
        
        startTime = Date()
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let acc = motionManager.accelerometerData!.acceleration
        let gyo = motionManager.gyroData!.rotationRate
        let g = sqrt(gyo.x*gyo.x+gyo.y*gyo.y+gyo.z*gyo.z)
        gyroData.append(g)
        iniX = (touches.first?.location(in: v).x)!
        iniY = (touches.first?.location(in: v).y)!
        log = "Time,X,Y,Pressure,MajorRadius,Shifting,AccX,AccY,AccZ,GyoX,GyoY,GyoZ\n"
        log.append("0.0,iniX,iniY,\((touches.first?.force)!),\((touches.first?.majorRadius)!),0.0,\(acc.x),\(acc.y),\(acc.z),\(gyo.x),\(gyo.y),\(gyo.z)\n")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToInfo" {
            let infoVC = segue.destination as! InfoVC
            infoVC.receivedString = "All Finished."
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        if !isInside {return}
        
        let force = (touches.first?.force)!
        let radius = Double((touches.first?.majorRadius)!)
        let time = Date().timeIntervalSince(startTime!)
        let x = (touches.first?.location(in: v).x)!
        let y = (touches.first?.location(in: v).y)!
        let shifting = computeShifting(x, y)

        if !radiusOK {
            if radius > radiusThreshold {
                radiusOK = true
            }
        }
        
        if !timeOK {
            if shifting<=shiftingThreshold && time>timeThreshold {
                timeOK = true
            }
        }
        let acc = motionManager.accelerometerData!.acceleration
        let gyo = motionManager.gyroData!.rotationRate
        if time < _gyroTimeThres {
            let g = sqrt(gyo.x*gyo.x+gyo.y*gyo.y+gyo.z*gyo.z)
            gyroData.append(g)
        }
        
        if !gyroLowOk && time >= _gyroTimeThres{
            let low = lowpass(gyroData).max()!
            if low > gyroLowThreshold {
                gyroLowOk = true
            }
        }
        
        if !gyroLowOk && time >= _gyroTimeThres{
            let low = lowpass(gyroData).max()!
            if low > gyroLowThreshold {
                gyroLowOk = true
            }
        }
        if !gyroHighOK && time >= _gyroTimeThres{
            let high = highpass(gyroData).max()!
            if high < gyroHighThreshold {
                gyroHighOK = true
            }
        }
        log.append("\(time),\(x),\(y),\(force),\(radius),\(shifting),\(acc.x),\(acc.y),\(acc.z),\(gyo.x),\(gyo.y),\(gyo.z)\n")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        if !isInside {return}
        isInside = v.containsEnd((touches.first?.location(in: v))!)
        if !isInside {return}
        
        TOL[counter] = timeOK
        ROL[counter] = radiusOK
        GLOL[counter] = gyroLowOk
        GHOL[counter] = gyroHighOK
        
        saveFile()
        radiusOK = false
        timeOK = false
        gyroHighOK = false
        gyroLowOk = false
        counter += 1
        gyroData = []
        if counter == counterMax {
            saveResults()
            performSegue(withIdentifier: "MainToInfo", sender: nil)
        }else {
            v.index = indexList[counter]/2
            l.text = standards[counter] ? "\(counter+1): hard" : "\(counter+1): light"
        }
    }

    
    private func reset() {
        v.centerX = [212, 311, 489, 574, 267, 473, 331, 516, 329, 566, 384,278, 316, 418, 139, 108, 372, 327, 124, 523]
        v.centerY = [213, 256, 175, 54, 119, 218, 54, 295, 149, 63, 145, 183, 160, 222, 261, 249, 242, 266, 82, 284]
        v.endX = [602, 615, 326, 259, 388, 325, 408, 259, 635, 277, 137, 181, 110, 103, 416, 336, 622, 453, 345, 565]
        v.endY = [59, 73, 198, 124, 109, 170, 155, 65, 138, 263, 147, 140, 111, 117, 267, 269, 237, 253, 181, 101]
        
        log = ""
        counter = 0
        radiusOK = false
        timeOK = false
        indexList = Array(0...counterMax-1).shuffle()
        while(indexList[0]%2 == 1) {
            indexList = Array(0...counterMax-1).shuffle()
        }
        standards = Array(repeating: false, count: counterMax)
        for i in 0...counterMax-1 {
            if indexList[i]%2 == 0 {
                standards[i] = true
            }
        }
        TOL = Array(repeating: false, count: counterMax)
        ROL = Array(repeating: false, count: counterMax)
        GLOL = Array(repeating: false, count: counterMax)
        GHOL = Array(repeating: false, count: counterMax)

        l.text = standards[0] ? "\(counter+1): hard" : "\(counter+1): light"
        v.index = indexList[counter]/2

    }
    
    private func computeShifting(_ x:CGFloat, _ y:CGFloat)->Double{
        let x2 = Double((x-iniX)*(x-iniX))
        let y2 = Double((y-iniY)*(y-iniY))
        return sqrt(x2+y2)
    }
    
    private func saveFile(){
        let file = USER_ID + "_test_\(counter).csv"
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path.appendPathComponent(file)
        do {
            try log.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    private func saveResults(){
        var res = "User ID;,\(USER_ID) \n"
        res.append("Force thres: \(forceThreshold)\n")
        res.append("Radius thres: \(radiusThreshold)\n")
        res.append("Time thres: \(timeThreshold)\n")
        res.append("Gyro low thres: \(gyroLowThreshold)\n")
        res.append("Gyro high thres: \(gyroHighThreshold)\n")
        res.append("Counter,Standard,timeRight,RadiusRight,GyroLowRight,GyroHighRight\n")
        for i in 0...counterMax-1{
            res.append("\(i),\(standards[i]),\(TOL[i]==standards[i]),\(ROL[i]==standards[i]),\(GLOL[i]==standards[i]),\(GHOL[i]==standards[i])\n")
        }
        let file = USER_ID + "_test_res.csv"
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        path.appendPathComponent(file)
        do {
            try res.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }

    }

    
    
}
