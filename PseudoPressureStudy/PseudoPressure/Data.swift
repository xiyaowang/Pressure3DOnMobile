

import Foundation

var USER_ID = ""

var forceThreshold:Double = 0.0
var radiusThreshold:Double = 0.0
var timeThreshold:Double = 0.0
var shiftingThreshold:Double = 5.0

var gyroLowThreshold:Double = 0.0
var gyroHighThreshold:Double = 0.0
let _gyroTimeThres: Double = 0.5


extension Array {
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                swap(&list[index], &list[newIndex])
            }
        }
        return list
    }
}


func lowpass(_ x: [Double]) -> [Double] {
    let factor = 0.1
    var y = Array(repeating: 0.0, count: x.count)
    y[0] = 0.0 + (1.0 - factor) * x[0]
    for i in 1...x.count-1 {
        y[i] = factor * y[i-1] + (1.0 - factor) * x[i]
    }
    return y
}

func highpass(_ x: [Double]) -> [Double] {
    let factor = 0.5
    var y = Array(repeating: 0.0, count: x.count)
    y[0] = y[0] - (0.0 + (1.0 - factor) * x[0])
    for i in 1...x.count-1 {
        y[i] = factor * y[i-1] + (1.0 - factor) * x[i]
    }
    for i in 1...x.count-1 {
        y[i] = x[i] - y[i]
    }
    return y
    
}
