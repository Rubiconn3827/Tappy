//
//  ViewController.swift
//  Tap
//
//  Created by AJ Priola on 7/10/15.
//  Copyright © 2015 AJ Priola. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    var circle:UIView!
    var blue:UIView!
    var thirdCircle:UIView!
    var center:UIView!
    var centerInside:UIView!
    var scoreLabel:UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    var centerPoint:CGPoint!
    
    var rotateForward:CABasicAnimation!
    var rotateBackward:CABasicAnimation!
    var messages = ["Good start","Keep it up","You're doing great","Way to go","Keep going!","Epic!","Legendary!","Go play outside.","Put your phone down.","You're too good at this.","You should go pro."]
    var messages2 = ["Nice!","Great!","Awesome!","Super!","Fantastic!"]
    var playing = true
    var score = 0
    var timeMultiple = 1.0
    var blueTime = 4.5
    var redTime = 3.25
    var greenTime = 3.7
    var radius:CGFloat!
    var highscore = 0
    var replacedHighscore = false
    var interactionEnabled = true
    var overlayDisplayed = false
    var overlay:UIView!
    var blueTotalTimeLostResultingFromSpeedChange:Float = 0
    var currentChangeSpeedTime:CFTimeInterval = 0
    
    var overlayHighscores:[UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-large")!)
        
        if let readHighScore = self.getHighScore() {
            self.highscore = readHighScore
            self.highScoreLabel.text = "High Score: \(highscore)"
        }
        
        overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        overlay.frame.origin.x += self.view.frame.width
        makeOverlayLabels()
        view.addSubview(overlay)
        
        centerPoint = CGPointMake(view.center.x, view.center.y * 1.4)
        scoreProgressView.progress = 0
        radius = (self.view.frame.width * 0.6)
        circle = UIView(frame: CGRectMake(50, 50, 50, 50))
        circle.layer.cornerRadius = 25
        circle.clipsToBounds = true
        circle.backgroundColor = UIColor.whiteColor()
        circle.center = CGPointMake(0, centerPoint.y + radius)
        
        blue = UIView(frame: CGRectMake(50, 50, 50, 50))
        blue.layer.cornerRadius = 25
        blue.clipsToBounds = true
        blue.backgroundColor = UIColor.blackColor()
        blue.center = CGPointMake(centerPoint.x, centerPoint.y - radius/2)
        
        thirdCircle = UIView(frame: CGRectMake(50, 50, 50, 50))
        thirdCircle.layer.cornerRadius = 25
        thirdCircle.clipsToBounds = true
        thirdCircle.backgroundColor = UIColor.lightGrayColor()
        thirdCircle.center = CGPointMake(centerPoint.x, centerPoint.y - radius/2)
        thirdCircle.hidden = true
        
        center = UIView(frame: CGRectMake(view.center.x, view.center.y, radius + 50, radius + 50))
        center.layer.cornerRadius = center.frame.width/2
        center.layer.borderColor = UIColor.blackColor().CGColor
        center.layer.borderWidth = 1
        center.backgroundColor = UIColor.cyanColor().colorWithAlphaComponent(0.5)
        center.clipsToBounds = true
        center.center = centerPoint
        view.addSubview(center)
        
        centerInside = UIView(frame: CGRectMake(view.center.x, view.center.y, radius - 50, radius - 50))
        centerInside.layer.cornerRadius = centerInside.frame.width/2
        centerInside.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        centerInside.layer.borderWidth = 1
        centerInside.clipsToBounds = true
        centerInside.center = centerPoint
        view.addSubview(centerInside)
        
        scoreLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        scoreLabel.text = "\(score)"
        scoreLabel.center = centerPoint
        scoreLabel.textAlignment = .Center
        scoreLabel.font = messageLabel.font.fontWithSize(17)
        view.addSubview(scoreLabel)
        self.statusLabel.text = "Tap to begin"
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        view.addGestureRecognizer(tapRecognizer)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "removeOverlay")
        swipeRight.direction = .Right
        overlay.addGestureRecognizer(swipeRight)
        
        blue.layer.speed = 1
        circle.layer.speed = 1
        
        self.view.addSubview(blue)
        self.view.addSubview(circle)
        self.view.addSubview(thirdCircle)
        animateForwards(blue, radius: radius, time: blueTime, speed:timeMultiple, key:"blue")
        animateBackwards(circle, radius: radius, time: redTime, speed:timeMultiple, key:"red")
        animateForwards(thirdCircle, radius: radius, time: greenTime, speed:timeMultiple, key:"green")
    }
    
    func makeOverlayLabels() {
        let title = UILabel(frame: CGRectMake(self.view.frame.width, self.messageLabel.frame.origin.y, self.view.frame.width - 16, 40))
        title.textAlignment = .Center
        title.textColor = UIColor.whiteColor()
        title.font = self.messageLabel.font.fontWithSize(32)
        title.text = "Game Over"
        overlay.addSubview(title)
        
        let bar = UIView(frame: CGRectMake(self.view.frame.width, title.frame.origin.y + 48, self.view.frame.width - 16, 2))
        bar.backgroundColor = UIColor.whiteColor()
        overlay.addSubview(bar)
    }
    
    func changeBackgroundGradient(bottom:UIColor, top:UIColor) {
        let vista : UIView = UIView(frame: self.view.frame)
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = vista.bounds
        let arrayColors = [top, bottom]
        
        gradient.colors = arrayColors
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func saveHighScore(score:Int) {
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
    }
    
    func getHighScore() -> Int? {
        return NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }
    
    func animateForwards(forwardView:UIView, radius:CGFloat, time:Double, speed:Double, key:String) {
        let rotationPoint = centerPoint
        
        let anchorPoint = CGPointMake((rotationPoint.x + radius/2)/(radius), (rotationPoint.y + radius/2)/(radius))
        forwardView.layer.anchorPoint = anchorPoint
        forwardView.layer.position = rotationPoint
        
        rotateForward = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateForward.toValue = (M_PI) * 2
        rotateForward.duration = time
        rotateForward.repeatCount = Float.infinity
        forwardView.layer.addAnimation(rotateForward, forKey: key)
    }
    
    func updateAnimation(view:UIView, animation:CABasicAnimation, speed:Double, key:String) {
        let layerFrame = view.layer.presentationLayer()?.frame
        blue.frame.origin = (layerFrame?.origin)!
        view.layer.removeAllAnimations()
        animateForwards(blue, radius: radius, time: blueTime, speed: timeMultiple, key: "blue")
        
    }
    
    func animateBackwards(forwardView:UIView, radius:CGFloat, time:Double, speed:Double, key:String) {
        let rotationPoint = centerPoint
        
        let anchorPoint = CGPointMake((rotationPoint.x + radius/2)/(radius), (rotationPoint.y + radius/2)/(radius))
        forwardView.layer.anchorPoint = anchorPoint
        forwardView.layer.position = rotationPoint
        
        rotateBackward = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateBackward.toValue = (-M_PI) * 2
        rotateBackward.duration = time
        rotateBackward.repeatCount = Float.infinity
        forwardView.layer.addAnimation(rotateBackward, forKey: key)
    }
    
    func calculateSpeed() {
        var divisor = 250
        switch score {
        case 0...10:
            divisor = 200
        case 11...20:
            divisor = 450
        case 21...30:
            divisor = 690
        case 31...40:
            divisor = 900
        default:
            divisor = 1100
        }
        self.timeMultiple = (Double(score) / Double(divisor))
        
        self.blueTime += blueTime * timeMultiple
        self.redTime += redTime * timeMultiple
        
        let blueVal = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: blue.layer) - currentChangeSpeedTime
        let blueCurrentTimeLostResultingFromSpeedChange = Float(blueVal) - (Float(blueVal) * blue.layer.speed)
        blueTotalTimeLostResultingFromSpeedChange += blueCurrentTimeLostResultingFromSpeedChange
        
        currentChangeSpeedTime = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: blue.layer)
        blue.layer.timeOffset = CFTimeInterval(Float(currentChangeSpeedTime) - blueTotalTimeLostResultingFromSpeedChange)
        blue.layer.beginTime = CACurrentMediaTime()
        blue.layer.speed += Float(timeMultiple)
        
        circle.layer.timeOffset = CFTimeInterval(Float(currentChangeSpeedTime) - blueTotalTimeLostResultingFromSpeedChange)
        circle.layer.beginTime = CACurrentMediaTime()
        circle.layer.speed += Float(timeMultiple)
    }
    
    func flashScreen() {
        if let wnd = self.view{
            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.whiteColor()
            v.alpha = 0.9
            wnd.addSubview(v)
            UIView.animateWithDuration(0.5, animations: {
                v.alpha = 0.0
                }, completion: {(finished:Bool) in
                    v.removeFromSuperview()
            })
        }
    }
    
    func startGame() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-large")!)
        centerInside.backgroundColor = UIColor.clearColor()
        scoreLabel.textColor = UIColor.blackColor()
        self.blue.hidden = false
        self.circle.hidden = false
        replacedHighscore = false
        playing = true
        timeMultiple = 1
        self.scoreLabel.text = "0"
        blue.layer.speed = 1
        circle.layer.speed = 1
        animateTextChange(statusLabel, text: "Tap when the circles overlap")
        calculateSpeed()
    }
    
    func tapped() {
        if overlayDisplayed { return }
        
        guard playing && interactionEnabled else {
            if !playing { startGame() }
            return
        }
        
        let blueFrame = self.blue.layer.presentationLayer()?.frame
        let redFrame = self.circle.layer.presentationLayer()?.frame
        let greenFrame = self.thirdCircle.layer.presentationLayer()?.frame
        if self.thirdCircle.hidden {
            if CGRectIntersectsRect(blueFrame!, redFrame!) {
                score++
                flashScreen()
                UILabel.animateWithDuration(5, animations: { () -> Void in
                    self.messageLabel.text = ""
                })
            } else {
                gameOver()
                return
            }
        } else {
            
            if CGRectIntersectsRect(blueFrame!, redFrame!) && CGRectIntersectsRect(greenFrame!, redFrame!) && CGRectIntersectsRect(blueFrame!, greenFrame!) {
                score += 6
                self.thirdCircle.hidden = true
                flashScreen()
                animateTextChange(messageLabel, text: "Triple!")
            } else if CGRectIntersectsRect(greenFrame!, redFrame!) || CGRectIntersectsRect(blueFrame!, greenFrame!) {
                score += 3
                self.thirdCircle.hidden = true
                flashScreen()
                let i = Int(arc4random_uniform(UInt32(2)))
                animateTextChange(messageLabel, text: messages2[i])
            } else if CGRectIntersectsRect(redFrame!, blueFrame!) {
                score++
                flashScreen()
            } else {
                gameOver()
                return
            }
        }
        animateTextChange(scoreLabel, text: "\(score)")
        
        if arc4random() % 3 == 0 {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.thirdCircle.hidden = false
            })
            
        }
        var index = score/10
        if index > messages.count - 1 { index = messages.count - 1 }
        if (score % 10 == 0 && score > 9) || (score == 1) {
            animateTextChange(statusLabel, text: messages[index])
        }
        if score <= 10 {
            let progress = Double(score)/10
            scoreProgressView.setProgress(Float(progress), animated: true)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else {
            let progress = (Double(score) % 10) / 10
            scoreProgressView.setProgress(Float(progress), animated: true)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        if score > highscore {
            highscore = score
            self.highScoreLabel.text = "High Score: \(highscore)"
            if !replacedHighscore {
                replaceHighscore()
            }
            saveHighScore(highscore)
        }
        
        if score >= 30 {
            scoreLabel.textColor = UIColor.redColor()
        }
        
        if score >= 45 {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-orange")!)
        }
        
        if score >= 85 {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-red")!)
        }
        
        calculateSpeed()
    }
    
    func displayOverlay() {
        messageLabel.hidden = true
        statusLabel.hidden = true
        highScoreLabel.hidden = true
        scoreLabel.hidden = true
        interactionEnabled = false
        UIView.animateWithDuration(1) { () -> Void in
            self.overlay.frame.origin.x = 0
        }
        overlayDisplayed = true
        for element in overlay.subviews {
            UIView.animateWithDuration(0.8, delay: Double(overlay.subviews.indexOf(element)!), options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                element.frame.origin.x = 8
                }, completion: nil)
        }
    }
    
    func removeOverlay() {
        messageLabel.hidden = false
        statusLabel.hidden = false
        highScoreLabel.hidden = false
        scoreLabel.hidden = false
        interactionEnabled = true
        UIView.animateWithDuration(1) { () -> Void in
            self.overlay.frame.origin.x = self.view.frame.width
            for element in self.overlay.subviews {
                element.frame.origin.x = self.view.frame.width + 8
            }
        }
        
        overlayDisplayed = false
        startGame()
    }
    
    func replaceHighscore() {
        let new = UILabel(frame: self.highScoreLabel.frame)
        new.frame.origin.x += self.view.frame.width + 8
        new.font = highScoreLabel.font
        new.text = "High Score: \(score)"
        UILabel.animateWithDuration(0.5) { () -> Void in
            new.frame.origin.x = self.highScoreLabel.frame.origin.x
        }
        UILabel.animateWithDuration(0.5) { () -> Void in
            self.highScoreLabel.frame.origin.x -= (self.view.frame.width + 8)
        }
        replacedHighscore = true
    }
    
    func gameOver() {
        self.blue.hidden = true
        self.circle.hidden = true
        self.thirdCircle.hidden = true
        score = 0
        playing = false
        animateTextChange(statusLabel, text: "Tap to begin")
        messageLabel.text = ""
        scoreProgressView.setProgress(0, animated: true)
        saveHighScore(highscore)
        displayOverlay()
    }
    
    func animateTextChange(label:UILabel, text:String) {
        label.alpha = 0.0
        label.text = text
        UILabel.animateWithDuration(1) { () -> Void in
            label.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

