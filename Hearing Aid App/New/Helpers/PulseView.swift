import UIKit

/// Enum which defines the different type of pulse animation
///
/// - radar: Single wave like animation, one at a time
/// - continous: Pulse expands and shrinks continuously
/// - multiRadar: Multiple waves continuously displayed
public enum MMPPulseType {
    case radar
    case continous
    case multiRadar
}

/// Defines the constants used in the library
public struct MMPPulseConstants {
    // MARK: - Layer names
    public struct Layers {
        static let outerLayer = "MMPOuterLayer"
    }
    
    // MARK: - Animation keypaths
    public struct Animations {
        static let scale   = "transform.scale.xy"
        static let opacity = "opacity"
    }
    
    // MARK: - Animation keys
    public struct AnimKeys {
        static let pulseAnimation = "MMP_Pulse_Animation"
    }
}

// MARK: - Class Definition
class MMPPulseLayer: CAReplicatorLayer {
    // MARK: - Properties
    
    // Interval between two pulses
    var pulseInterval     : TimeInterval!
    
    // Indicates whether timing function need to be enabled or not
    var enableTimingFunc  : Bool!
    
    // Layer that shows the animation
    var animationLayer    : CALayer!
    
    // Animation group
    var animationGroup    : CAAnimationGroup!
    
    // Animation type
    var animationType     : MMPPulseType!
    
    // Frame property
    override var frame: CGRect {
        didSet {
            self.animationLayer.frame = self.bounds
        }
    }
    
    // Radius of pulse animation
    var pulseRadius       : CGFloat! {
        didSet {
            self.masksToBounds               = false
            let diameter                     = self.pulseRadius * 2
            self.animationLayer.bounds       = CGRect(x: 0,y: 0,width: diameter,height: diameter)
            self.animationLayer.cornerRadius = self.pulseRadius
        }
    }
    
    // Duration of animation
    var animationDuration : TimeInterval! {
        didSet {
            self.calculateInstanceDelay()
        }
    }
    
    // Number of pulses (Only applicable for Multiradar type)
    var numberOfPulse     : Int! {
        didSet {
            self.instanceCount = numberOfPulse
            self.calculateInstanceDelay()
        }
    }
    
    // Number of repeat type
    var pulseRepeatCount  : Float! {
        didSet {
            super.repeatCount     = pulseRepeatCount
            if let animationGroup = self.animationGroup {
                animationGroup.repeatCount = pulseRepeatCount
            }
        }
    }
    
    // Background color used for pulse
    var bgColor: CGColor? {
        didSet {
            self.animationLayer.backgroundColor = bgColor
        }
    }
    
    required init(type : MMPPulseType) {
        super.init()
        animationLayer               = CALayer()
        animationLayer.contentsScale = UIScreen.main.scale
        animationLayer.opacity       = 0.0
        addSublayer(animationLayer)
        configureAnimation()
        animationType = type
        
    }
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Public functions
extension MMPPulseLayer {
    
    /// Starts the animation
    func startAnimation() {
        self.configureAnimationGroup()
        self.animationLayer.add(self.animationGroup, forKey: MMPPulseConstants.AnimKeys.pulseAnimation)
    }
    
    /// Stops the animation
    func stopAnimation() {
        self.animationLayer.removeAnimation(forKey: MMPPulseConstants.AnimKeys.pulseAnimation)
    }
}


// MARK: - Private functions
extension MMPPulseLayer {
    
    /// Calculates the delay needed between each instances of pulse layer
    fileprivate func calculateInstanceDelay() {
        if let duration = self.animationDuration, let interval = self.pulseInterval, let numberOfPulse = self.numberOfPulse {
            self.instanceDelay = (duration + interval) / Double(numberOfPulse)
        }
    }
    
    /// Configures the initial value for each property
    fileprivate func configureAnimation() {
        animationDuration = 3
        pulseInterval     = 1
        enableTimingFunc  = true
        
        pulseRepeatCount  = Float.greatestFiniteMagnitude
        pulseRadius       = 30
        numberOfPulse     = 1
        bgColor           = UIColor(red: 0.000, green: 0.455, blue: 0.756, alpha: 0.45).cgColor
    }
    
    /// Configures the animation group
    fileprivate func configureAnimationGroup() {
        let animationGroup         = CAAnimationGroup()
        animationGroup.duration    = self.animationDuration + self.pulseInterval
        animationGroup.repeatCount = self.repeatCount
        
        if enableTimingFunc! {
            let curve                     = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animationGroup.timingFunction = curve
        }
        
        let scaleAnimation          = CABasicAnimation(keyPath: MMPPulseConstants.Animations.scale)
        scaleAnimation.fromValue    = 0.0
        scaleAnimation.toValue      = 1.0
        scaleAnimation.duration     = self.animationDuration
        //scaleAnimation.autoreverses = true
        
        let opacityAnimation        = CAKeyframeAnimation(keyPath: MMPPulseConstants.Animations.opacity)
        opacityAnimation.duration   = self.animationDuration
        if let bgColor              = self.bgColor {
            let alpha               = bgColor.alpha
            opacityAnimation.values = [alpha, (alpha * 0.5), 0]
        } else {
            opacityAnimation.values = [1, 0.5, 0]
            
        }
        opacityAnimation.keyTimes   = [0, 0.5, 1]
        
        var animations              = [CAAnimation]()
        
        if animationType == MMPPulseType.radar {
            animations.append(scaleAnimation)
            animationLayer.opacity       = 1.0
            scaleAnimation.autoreverses  = true
            self.numberOfPulse           = 1
            self.pulseInterval           = self.animationDuration
            self.animationDuration       = self.pulseInterval
            animationGroup.duration      = self.animationDuration + self.pulseInterval
        }
        else if animationType == MMPPulseType.continous {
            animations.append(scaleAnimation)
            animations.append(opacityAnimation)
            self.numberOfPulse = 1
        }
        else if animationType == MMPPulseType.multiRadar {
            animations.append(scaleAnimation)
            animations.append(opacityAnimation)
        }
        
        animationGroup.animations = animations;
        self.animationGroup       = animationGroup;
    }
}

// MARK: - Pulse Functions
public extension UIView {
    
    /// Function for starting the pulse animation
    /// Excepty `type` all other parameters are optional
    /// - Parameters:
    ///   - type: Type of pulse animation (Defined in MMPPulseType)
    ///   - color: Color of pulse(s)
    ///   - pulseCount: Number of pulses need to be shown (Must be 1 for .radar and .continuos for better effect)
    ///   - repeatCount: Number of times the animation need to be repeated
    ///   - frequency: Frequency of consecutive animations
    ///   - radius: Radius of pulse
    ///   - duration: Animation duration
    func startPulse(withType type : MMPPulseType, color : UIColor = UIColor.black, pulseCount : Int = 1, repeatCount : Float = .greatestFiniteMagnitude, frequency : TimeInterval = 1, radius : CGFloat = 50, andDuration duration : TimeInterval = 1.0) {
        let outerLayer               = MMPPulseLayer(type: type)
        outerLayer.frame             = self.frame
        outerLayer.bgColor           = color.cgColor
        outerLayer.numberOfPulse     = pulseCount
        outerLayer.pulseRepeatCount  = repeatCount
        outerLayer.pulseInterval     = frequency
        outerLayer.pulseRadius       = radius
        outerLayer.animationDuration = duration
        outerLayer.name              = MMPPulseConstants.Layers.outerLayer
        self.layer.masksToBounds     = false
        self.layer.superlayer?.insertSublayer(outerLayer, below: self.layer)
        outerLayer.startAnimation()
    }
    
    /// Removes the pulse animation
    func removePulse() {
        if let outerLayer = self.getOuterLayer() {
            outerLayer.stopAnimation()
            outerLayer.removeFromSuperlayer()
        }
    }
}

// MARK: - Utility Functions
extension UIView {
    /// Returns the layer that shows the pulse animation
    ///
    /// - Returns: Pulse animation layer
    func getOuterLayer() -> MMPPulseLayer? {
        var layer : MMPPulseLayer?
        if let subLayers = self.layer.superlayer?.sublayers {
            for sublayer in subLayers {
                if sublayer.name == MMPPulseConstants.Layers.outerLayer {
                    layer = sublayer as? MMPPulseLayer
                    break
                }
            }
        }
        return layer
    }
}
