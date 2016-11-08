//: Playground - noun: a place where people can play

//
//  Created by Tueno on 2016/07/04.
//

import UIKit
import XCPlayground

// MARK: -

class MaterialLoadingIndicator: UIView {
    
    let MinStrokeLength: CGFloat = 0.05
    let MaxStrokeLength: CGFloat = 0.7
    let circleShapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        initShapeLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initShapeLayer() {
        circleShapeLayer.actions = ["strokeEnd" : NSNull(),
                                    "strokeStart" : NSNull(),
                                    "transform" : NSNull(),
                                    "strokeColor" : NSNull()]
        circleShapeLayer.backgroundColor = UIColor.clearColor().CGColor
        circleShapeLayer.strokeColor     = UIColor.blueColor().CGColor
        circleShapeLayer.fillColor       = UIColor.clearColor().CGColor
        circleShapeLayer.lineWidth       = 5
        circleShapeLayer.lineCap         = kCALineCapRound
        circleShapeLayer.strokeStart     = 0
        circleShapeLayer.strokeEnd       = MinStrokeLength
        let center                       = CGPoint(x: bounds.width*0.5, y: bounds.height*0.5)
        circleShapeLayer.frame           = bounds
        circleShapeLayer.path            = UIBezierPath(arcCenter: center,
                                                        radius: center.x,
                                                        startAngle: 0,
                                                        endAngle: CGFloat(M_PI*2),
                                                        clockwise: true).CGPath
        layer.addSublayer(circleShapeLayer)
    }
    
    func startAnimating() {
        if layer.animationForKey("rotation") == nil {
            startColorAnimation()
            startStrokeAnimation()
            startRotatingAnimation()
        }
    }
    
    private func startColorAnimation() {
        let color      = CAKeyframeAnimation(keyPath: "strokeColor")
        color.duration = 10.0
        color.values   = [UIColor(hex: 0x4285F4, alpha: 1.0).CGColor,
                          UIColor(hex: 0xDE3E35, alpha: 1.0).CGColor,
                          UIColor(hex: 0xF7C223, alpha: 1.0).CGColor,
                          UIColor(hex: 0x1B9A59, alpha: 1.0).CGColor,
                          UIColor(hex: 0x4285F4, alpha: 1.0).CGColor]
        color.calculationMode = kCAAnimationPaced
        color.repeatCount     = Float.infinity
        circleShapeLayer.addAnimation(color, forKey: "color")
    }
    
    private func startRotatingAnimation() {
        let rotation            = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue        = M_PI*2
        rotation.duration       = 2.2
        rotation.cumulative     = true
        rotation.additive       = true
        rotation.repeatCount    = Float.infinity
        layer.addAnimation(rotation, forKey: "rotation")
    }
    
    private func startStrokeAnimation() {
        let easeInOutSineTimingFunc = CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1.0)
        let progress: CGFloat     = MaxStrokeLength
        let endFromValue: CGFloat = circleShapeLayer.strokeEnd
        let endToValue: CGFloat   = endFromValue + progress
        let strokeEnd                   = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue             = endFromValue
        strokeEnd.toValue               = endToValue
        strokeEnd.duration              = 0.5
        strokeEnd.fillMode              = kCAFillModeForwards
        strokeEnd.timingFunction        = easeInOutSineTimingFunc
        strokeEnd.beginTime             = 0.1
        strokeEnd.removedOnCompletion   = false
        let startFromValue: CGFloat     = circleShapeLayer.strokeStart
        let startToValue: CGFloat       = fabs(endToValue - MinStrokeLength)
        let strokeStart                 = CABasicAnimation(keyPath: "strokeStart")
        strokeStart.fromValue           = startFromValue
        strokeStart.toValue             = startToValue
        strokeStart.duration            = 0.4
        strokeStart.fillMode            = kCAFillModeForwards
        strokeStart.timingFunction      = easeInOutSineTimingFunc
        strokeStart.beginTime           = strokeEnd.beginTime + strokeEnd.duration + 0.2
        strokeStart.removedOnCompletion = false
        let pathAnim                 = CAAnimationGroup()
        pathAnim.animations          = [strokeEnd, strokeStart]
        pathAnim.duration            = strokeStart.beginTime + strokeStart.duration
        pathAnim.fillMode            = kCAFillModeForwards
        pathAnim.removedOnCompletion = false
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            if self.circleShapeLayer.animationForKey("stroke") != nil {
                self.circleShapeLayer.transform = CATransform3DRotate(self.circleShapeLayer.transform, CGFloat(M_PI*2) * progress, 0, 0, 1)
                self.circleShapeLayer.removeAnimationForKey("stroke")
                self.startStrokeAnimation()
            }
        }
        circleShapeLayer.addAnimation(pathAnim, forKey: "stroke")
        CATransaction.commit()
    }
    
    func stopAnimating() {
        circleShapeLayer.removeAllAnimations()
        layer.removeAllAnimations()
        circleShapeLayer.transform = CATransform3DIdentity
        layer.transform            = CATransform3DIdentity
    }
    
}

extension UIColor {
    
    convenience init(hex: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
}

// MARK: -

let view      = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
let indicator = MaterialLoadingIndicator(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
indicator.center = CGPoint(x: 320*0.5, y: 568*0.5)
view.addSubview(indicator)
XCPlaygroundPage.currentPage.liveView = view
indicator.startAnimating()
