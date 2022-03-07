

import UIKit
import CoreMotion
import AudioToolbox

class TrainVC: UIViewController {
    
    private var _maxForcePerTouch: CGFloat = 0.0
    private var _maxForceSet:[CGFloat] = []
    private var _lightForceMean: CGFloat = 0.0
    private var _hardForceMean: CGFloat = 0.0
    
    private var _maxRadiusPerTouch: CGFloat = 0.0
    private var _maxRadiusSet:[CGFloat] = []
    private var _lightRadiusMean: CGFloat = 0.0
    private var _hardRadiusMean: CGFloat = 0.0
    
    private var _maxTimePerTouch: Double = 0.0
    private var _maxTimeSet:[Double] = []
    private var _lightTimeMean: Double = 0.0
    private var _hardTimeMean: Double = 0.0
    
    private var _gyroPerTouch: [Double] = []
    private var _maxGyroLowSet:[Double] = []
    private var _maxGyroHighSet:[Double] = []
    private var _lightGyroLowMean: Double = 0.0
    private var _lightGyroHighMean: Double = 0.0
    private var _hardGyroLowMean: Double = 0.0
    private var _hardGyroHighMean: Double = 0.0

    
    private var iniX:CGFloat = 0.0
    private var iniY:CGFloat = 0.0
    private var realStartTime:Date? = nil
    private var startTime:Date? = nil

    private var isInside = true
    private var counter = 0
    private let counterMax = 10
    
    private var motionManager: CMMotionManager!
    private var timer: Timer!
    private var coreLog:String = "Time,AccX,AccY,AccZ,GyoX,GyoY,GyoZ\n"

    private var log:[String] = []
    
    @IBOutlet weak var v: ArrowCircle!
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    
    @IBOutlet weak var pButton: UIButton!
    @IBAction func pButtonUpIn(_ sender: Any) {
        saveFile()
        print("Force thres: \(forceThreshold)")
        print("Radius thres: \(radiusThreshold)")
        print("Time thres: \(timeThreshold)")
        print("Gyro low thres: \(gyroLowThreshold)")
        print("Gyro high thres: \(gyroHighThreshold)")
        performSegue(withIdentifier: "TrainToTest", sender: nil)
    }
    @IBOutlet weak var rButton: UIButton!
    @IBAction func rButtonUpIn(_ sender: Any) {
        reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
        realStartTime = Date()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        //timer = Timer.scheduledTimer(timeInterval: 1.0/50.0, target: self, selector: #selector(TrainVC.update), userInfo: nil, repeats: true)

    }
    
    /*func update() {
        let acc = motionManager.accelerometerData!.acceleration
        let gyo = motionManager.gyroData!.rotationRate
        let time = Date().timeIntervalSince(realStartTime!)
        coreLog.append("\(time),\(acc.x),\(acc.y),\(acc.z),\(gyo.x),\(gyo.y),\(gyo.z)\n")
        

    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TrainToInfo" {
            let infoVC = segue.destination as! InfoVC
            infoVC.receivedString = "Now you are asked to preform hard touch."
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        isInside = v.containsStart((touches.first?.location(in: v))!)
        if !isInside {return}
        
        startTime = Date()
        _maxForcePerTouch = (touches.first?.force)!
        _maxRadiusPerTouch = (touches.first?.majorRadius)!
        _maxTimePerTouch = 0.0
        iniX = (touches.first?.location(in: v).x)!
        iniY = (touches.first?.location(in: v).y)!
        
        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        let acc = motionManager.accelerometerData!.acceleration
        let gyo = motionManager.gyroData!.rotationRate
        let g = sqrt(gyo.x*gyo.x+gyo.y*gyo.y+gyo.z*gyo.z)
        _gyroPerTouch = [g]
        
        log[counter] = "Time,X,Y,Pressure,MajorRadius,Shifting,AccX,AccY,AccZ,GyoX,GyoY,GyoZ\n"
        log[counter].append("0.0,\(iniX),\(iniY),\((touches.first?.force)!),\((touches.first?.majorRadius)!),0.0,\(acc.x),\(acc.y),\(acc.z),\(gyo.x),\(gyo.y),\(gyo.z)\n")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        if !isInside {return}
        
        let force = (touches.first?.force)!
        if force > _maxForcePerTouch {
                _maxForcePerTouch = force
        }
        let radius = (touches.first?.majorRadius)!
        if radius > _maxRadiusPerTouch {
            _maxRadiusPerTouch = radius
        }
        let time = Date().timeIntervalSince(startTime!)
        let x = (touches.first?.location(in: v).x)!
        let y = (touches.first?.location(in: v).y)!
        let shifting = computeShifting(x, y)
        if shifting < shiftingThreshold {
            _maxTimePerTouch = time
        }
        
        let acc = motionManager.accelerometerData!.acceleration
        let gyo = motionManager.gyroData!.rotationRate
        if time < _gyroTimeThres {
            let g = sqrt(gyo.x*gyo.x+gyo.y*gyo.y+gyo.z*gyo.z)
            _gyroPerTouch.append(g)
        }
        log[counter].append("\(time),\(x),\(y),\(force),\(radius),\(shifting),\(acc.x),\(acc.y),\(acc.z),\(gyo.x),\(gyo.y),\(gyo.z)\n")

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if counter >= counterMax {return}
        if !isInside {return}
        isInside = v.containsEnd((touches.first?.location(in: v))!)
        if !isInside {return}

        _maxForceSet.append(_maxForcePerTouch)
        _maxRadiusSet.append(_maxRadiusPerTouch)
        _maxTimeSet.append(_maxTimePerTouch)
        
        let low = lowpass(_gyroPerTouch)
        let high = highpass(_gyroPerTouch)
        _maxGyroLowSet.append(low.max()!)
        _maxGyroHighSet.append(high.max()!)

        
        counter += 1
        var index = 0
        if counter>=counterMax/2 {index=counterMax-counter} else {index=counterMax/2-counter}
        l2.text = "\(index) times left."
        
        if counter == counterMax/2 {
            var forceSum: CGFloat = 0.0
            for i in 0..._maxForceSet.count-1 {
                forceSum += _maxForceSet[i]
            }
            _lightForceMean = forceSum/CGFloat(_maxForceSet.count)
            
            var radiusSum: CGFloat = 0.0
            for i in 0..._maxRadiusSet.count-1 {
                radiusSum += _maxRadiusSet[i]
            }
            _lightRadiusMean = radiusSum/CGFloat(_maxRadiusSet.count)
            
            var timeSum: Double = 0.0
            for i in 0..._maxTimeSet.count-1 {
                timeSum += _maxTimeSet[i]
            }
            _lightTimeMean = timeSum/Double(_maxRadiusSet.count)
            
            var gyroLowSum: Double = 0.0
            for i in 0..._maxGyroLowSet.count-1 {
                gyroLowSum += _maxGyroLowSet[i]
            }
            _lightGyroLowMean = gyroLowSum/Double(_maxGyroLowSet.count)
            
            var gyroHighSum: Double = 0.0
            for i in 0..._maxGyroHighSet.count-1 {
                gyroHighSum += _maxGyroHighSet[i]
            }
            _lightGyroHighMean = gyroHighSum/Double(_maxGyroHighSet.count)
            
            _maxForceSet = []
            _maxRadiusSet = []
            _maxTimeSet = []
            _maxGyroLowSet = []
            _maxGyroHighSet = []
            l1.text = "Please touch the big circle with a heavy force, slide along the the line and end in the small circle."
            performSegue(withIdentifier: "TrainToInfo", sender: nil)
        }
        
        if counter == counterMax {
            var forceSum: CGFloat = 0.0
            for i in 0..._maxForceSet.count-1 {
                forceSum += _maxForceSet[i]
            }
            
            _hardForceMean = forceSum/CGFloat(_maxForceSet.count)
            var radiusSum: CGFloat = 0.0
            for i in 0..._maxRadiusSet.count-1 {
                radiusSum += _maxRadiusSet[i]
            }
            _hardRadiusMean = radiusSum/CGFloat(_maxRadiusSet.count)

            var timeSum: Double = 0.0
            for i in 0..._maxTimeSet.count-1 {
                timeSum += _maxTimeSet[i]
            }
            _hardTimeMean = timeSum/Double(_maxRadiusSet.count)
            
            var gyroLowSum: Double = 0.0
            for i in 0..._maxGyroLowSet.count-1 {
                gyroLowSum += _maxGyroLowSet[i]
            }
            _hardGyroLowMean = gyroLowSum/Double(_maxGyroLowSet.count)
            
            var gyroHighSum: Double = 0.0
            for i in 0..._maxGyroHighSet.count-1 {
                gyroHighSum += _maxGyroHighSet[i]
            }
            _hardGyroHighMean = gyroHighSum/Double(_maxGyroHighSet.count)
            
            l1.text = "Trainning finished."
            pButton.setTitle("FINISH", for: .normal)
            if _lightForceMean < _hardForceMean - 1 {
                forceThreshold = Double(_lightForceMean + _hardForceMean)/2
                l2.text = "Force threshold is \(forceThreshold), max force is \(20.0/3.0)."
            }else{
                l2.text = "Light and hard touch non distinguishable, use default setting."
            }
            radiusThreshold = Double(_lightRadiusMean + _hardRadiusMean)/2
            timeThreshold = (_lightTimeMean + _hardTimeMean)/2
            gyroLowThreshold = (_lightGyroLowMean + _hardGyroLowMean)/2
            gyroHighThreshold = (_lightGyroHighMean + _hardGyroHighMean)/2
        }
        v.index = (v.index+1)%(counterMax/2)
    }

    
    private func reset(){
        counter = 0
        v.index = 0
        
        _maxForcePerTouch = 0.0
        _maxForceSet = []
        _lightForceMean = 0.0
        _hardForceMean = 0.0
        
        _maxRadiusPerTouch = 0.0
        _maxRadiusSet = []
        _lightRadiusMean = 0.0
        _hardRadiusMean = 0.0
        
        _maxTimePerTouch = 0.0
        _maxTimeSet = []
        _lightTimeMean = 0.0
        _hardTimeMean = 0.0
        
        _gyroPerTouch = []
        _maxGyroLowSet = []
        _maxGyroHighSet = []
        _lightGyroLowMean = 0.0
        _lightGyroHighMean = 0.0
        _hardGyroLowMean = 0.0
        _hardGyroHighMean = 0.0
        
        log = Array(repeating: "", count: counterMax)
        startTime = nil
        l1.text = "Please touch the big circle with a small force, slide along the the line and end in the small circle."
        l2.text = "\(counterMax/2-counter) times left."
        pButton.setTitle("PASS", for: .normal)
    }
    
    private func computeShifting(_ x:CGFloat, _ y:CGFloat)->Double{
        let x2 = Double((x-iniX)*(x-iniX))
        let y2 = Double((y-iniY)*(y-iniY))
        return sqrt(x2+y2)
    }
    
    private func saveFile(){
        for i in 0...log.count-1 {
            let file = USER_ID + "_train_\(i).csv"
            var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            path.appendPathComponent(file)
            do {
                try log[i].write(to: path, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }

        }
    }
    
       
    
}

























