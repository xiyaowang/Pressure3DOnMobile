

import UIKit

@IBDesignable
class ArrowCircle: UIView {
    var centerX:[CGFloat] = [120.0, 120.0, 600.0, 600.0, 250.0]  { didSet { setNeedsDisplay() } }
    var centerY:[CGFloat] = [120.0, 250.0, 100.0, 250.0, 150.0]  { didSet { setNeedsDisplay() } }
    var endX:[CGFloat] = [500.0, 500.0, 200.0, 500.0, 400.0]  { didSet { setNeedsDisplay() } }
    var endY:[CGFloat] = [250.0, 100.0, 250.0, 100.0, 150.0]  { didSet { setNeedsDisplay() } }
    @IBInspectable
    var index : Int = 0 { didSet { setNeedsDisplay() } }
    var radius:CGFloat = 55.0 { didSet { setNeedsDisplay() } }
    var lineWidth:CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    
    private func getDrawing() -> [UIBezierPath]{
        var path:[UIBezierPath] = []
        let circle = UIBezierPath(arcCenter: CGPoint(x:self.centerX[index],
                                                     y:self.centerY[index]),
                                                     radius: self.radius,
                                                     startAngle: 0.0,
                                                     endAngle:CGFloat(M_PI*2),
                                                     clockwise: true)
        circle.lineWidth = self.lineWidth
        path.append(circle)
        let smallCircle = UIBezierPath(arcCenter: CGPoint(x:self.endX[index],
                                                     y:self.endY[index]),
                                  radius: self.radius - CGFloat(15.0),
                                  startAngle: 0.0,
                                  endAngle:CGFloat(M_PI*2),
                                  clockwise: true)
        smallCircle.lineWidth = self.lineWidth
        path.append(smallCircle)
        let line = UIBezierPath()
        line.move(to: CGPoint(x:self.centerX[index],
                              y:self.centerY[index]))
        line.addLine(to: CGPoint(x:self.endX[index],
                                 y:self.endY[index]))
        line.lineWidth = self.lineWidth
        path.append(line)
        return path
    }
    
    func containsStart(_ point: CGPoint) -> Bool{
        let path = getDrawing()
        return path[0].contains(point)
    }
    
    func containsEnd(_ point: CGPoint) -> Bool{
        let path = getDrawing()
        return path[1].contains(point)
    }
    
    
    override func draw(_ rect: CGRect){
        UIColor.black.set()
        let p = getDrawing()
        for i in 0...p.count-1 {
            p[i].stroke()
        }
    }
}
