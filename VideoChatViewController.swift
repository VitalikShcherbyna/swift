//
//  VideoChatViewController.swift
//  Runner
//
//  Created by STLLPT038 on 02/01/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import UIKit
import OpenTok

final class FramSize{
    var width: CGFloat
    var height: CGFloat
    init(_ _width:CGFloat,_height:CGFloat) {
        width = _width
        height = _height
    }
}

class CustomButton: UIButton{

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    func setupButton(){
        layer.cornerRadius = 30
    }
}

final class VideoChatViewController: UIViewController {
    
    var audioOn="UnMute"
    var audioOff="Mute"
    var cameraFront="Front Side"
    var cameraBack="Back Side"

    var frameSize=FramSize(100, _height: 200)
    var buttonSize=FramSize(60,_height: 60)
    var labelSize=FramSize(96,_height: 21)
    var bottomContainerSize=FramSize(0,_height: 160)
    var videoOff="Stop Video"
    var videoOn="Start Video"
    
    @IBOutlet weak var endMeetingLabel: UILabel!
    @IBOutlet weak var stopVideoLabel: UILabel!
    @IBOutlet weak var muteLabel: UILabel!
    //MARK: Session
    var kApiKey = ""
    var kSessionId = ""
    var kToken = ""
    
    @IBOutlet weak var bottomView: UIView!
    var session: OTSession?
    var publisher: OTPublisher?
    var subscribers: [OTSubscriber:Float] = [:]
    var error: OTError?
    var videoTurnOn=true
    var cameraPosition=AVCaptureDevice.Position.front
    var audioTurnOn=true
    
    @IBOutlet weak var videoButton: CustomButton!
    @IBOutlet weak var muteButton: CustomButton!
    @IBOutlet weak var endMeetingButton: CustomButton!
    
    @IBOutlet weak var bottomViewT: UIView!
    var onCloseTap: ((_ callDuration: TimeInterval) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.frame = CGRect(x: 0, y: self.view.frame.height - bottomContainerSize.height , width: self.view.frame.width, height: bottomContainerSize.height)
        
        bottomPanerSetSize()
        self.navigationController?.isNavigationBarHidden = true
        connectToAnOpenTokSession()
    }
    
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self as OTSessionDelegate)
        session?.connect(withToken: kToken, error: &error)
    
        if error != nil {
            print(error!)
        }
    }

    @IBAction func videoManageButton(_ sender: CustomButton) {
        videoTurnOn = !videoTurnOn;
        publisher?.publishVideo = videoTurnOn
        if videoTurnOn {
            sender.setImage(UIImage(named: "video.png"), for: .normal)
            stopVideoLabel.text = videoOff
        }else{
            sender.setImage(UIImage(named: "videoOff.png"), for: .normal)
            stopVideoLabel.text = videoOn
        }
    }
    
    func bottomPanerSetSize(){
        //Check this value on MainBoard
        let yButton=40
        let yLabel=115
        
        let videoButtonPosition=getSmallDevicePosition( y: CGFloat(yButton),elementCount: CGFloat(0),elementSize: buttonSize,isLabel: false)
        videoButton.frame=videoButtonPosition
        
        let muteButtonPosition=getSmallDevicePosition( y: CGFloat(yButton),elementCount: CGFloat(1),elementSize: buttonSize,isLabel: false)
        muteButton.frame=muteButtonPosition
        
        let endMeetingButtonPosition=getSmallDevicePosition( y: CGFloat(yButton),elementCount: CGFloat(2),elementSize: buttonSize,isLabel: false)
        endMeetingButton.frame=endMeetingButtonPosition
        
        stopVideoLabel.frame=getSmallDevicePosition(y: CGFloat(yLabel),elementCount: CGFloat(0),elementSize: labelSize,isLabel: true,button: videoButtonPosition)
        muteLabel.frame=getSmallDevicePosition( y: CGFloat(yLabel),elementCount: CGFloat(1),elementSize: labelSize,isLabel: true,button: muteButtonPosition)
        endMeetingLabel.frame=getSmallDevicePosition( y: CGFloat(yLabel),elementCount: CGFloat(2),elementSize: labelSize,isLabel: true,button: endMeetingButtonPosition)
    }
    
    func getSmallDevicePosition(y:CGFloat,elementCount:CGFloat,elementSize:FramSize,isLabel: Bool, button: CGRect?=nil) -> CGRect{
        var paddingBetween=(self.view.frame.width-(3*elementSize.width))/4
        var x = (elementCount*elementSize.width)+paddingBetween*(elementCount+1)
        if isLabel {
            //get button position
            //find center button and label and subtract change
            let centerButton = CGFloat(button!.minX) + CGFloat(button!.width/2)
            let labelCenter = CGFloat(button!.minX) + elementSize.width/2
            x = CGFloat(button!.minX) - (labelCenter-centerButton)
        }
    
        return CGRect(x: x, y: y , width: elementSize.width, height: elementSize.height)
    }
    
    @IBAction func meetingManageButton(_ sender: CustomButton) {
        let startTime = session?.connection?.creationTime ?? Date()
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        onCloseTap?(duration)
        dismiss(animated: true, completion: nil)
        session?.disconnect(nil)
    }
    
    @IBAction func audioManageButton(_ sender: CustomButton) {
        audioTurnOn = !audioTurnOn;
        publisher?.publishAudio=audioTurnOn
        if audioTurnOn {
            sender.setImage(UIImage(named: "microphone.png"), for: .normal)
            muteLabel.text = audioOff
        }else{
            sender.setImage(UIImage(named: "microphoneOff.png"), for: .normal)
            muteLabel.text = audioOn
        }
    }

    @IBAction func changeCameraSide() {
        if cameraPosition==AVCaptureDevice.Position.front {
            cameraPosition=AVCaptureDevice.Position.back
        }else{
            cameraPosition=AVCaptureDevice.Position.front
        }
        publisher?.cameraPosition=cameraPosition
    }
    
    func getPublisherView(_ publisher: OTPublisher) -> Optional<UIView> {
        publisher.view?.frame = getPublisherFrameBounds(UIScreen.main.bounds)
        publisher.view?.layer.cornerRadius = 10.0
        publisher.view?.clipsToBounds = true
        return publisher.view
    }
    
    func getPublisherFrameBounds(_ bounds:CGRect) -> CGRect {
        return CGRect(x: bounds.width - 100 - 30, y: 100, width: frameSize.width, height: frameSize.height)
    }
    func getOtherSubscriberView(count: Int, view: UIView) -> UIView {
        view.frame = CGRect(x:  UIScreen.main.bounds.width - CGFloat(count) * 63, y: UIScreen.main.bounds.height - 250, width: 43, height: 86)
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }

}

// MARK: - OTSessionDelegate callbacks
extension VideoChatViewController: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        settings.videoTrack=true
        settings.name = UIDevice.current.name
        publisher=OTPublisher(delegate: self, settings: settings)
        guard let publisher = publisher else {
            return
        }
        
        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let publisherView = getPublisherView(publisher) else { return }
        //always insert own screen at 1st index
        view.insertSubview(publisherView, at: 1)
    }

    func sessionDidDisconnect(_ session: OTSession) {
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        let subscriber = OTSubscriber(stream: stream, delegate: self)!
        
        subscriber.audioLevelDelegate = self
        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        
        if subscribers.count>0 {
            let subscriberView = getOtherSubscriberView(count: subscribers.count, view: subscriber.view!)
            // insert other subscriber at 2nd index
            view.insertSubview(subscriberView, at: subscribers.count + 1)
        } else {
            let mainSubscriberView = subscriber.view
            mainSubscriberView?.frame = UIScreen.main.bounds
            view.insertSubview(mainSubscriberView!, at: 0)
        }
        
        subscribers.merge([subscriber:0]) { (current, _) in current }
    }
    
    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        print("VIDEO DISABLE")
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print(stream.streamId)

        let removedSubscriberIndex = subscribers.firstIndex { (sub) -> Bool in sub.key.stream?.streamId == stream.streamId }
        subscribers[removedSubscriberIndex!].key.view?.removeFromSuperview()
        subscribers.remove(at: removedSubscriberIndex!)
        
        let sortedSubscribers = subscribers.sorted { (first, second) -> Bool in first.value > second.value}

        if (sortedSubscribers.count > 0) {
            let newMainView = sortedSubscribers[0].key.view!
            newMainView.frame = UIScreen.main.bounds
            view.insertSubview(newMainView, at: 0)
            if (sortedSubscribers.count > 1) {
                let newSubView = getOtherSubscriberView(count: 1, view: sortedSubscribers[1].key.view!)
                view.insertSubview(newSubView, at: subscribers.count)
            }
        }

    }
}

extension VideoChatViewController:OTSubscriberKitAudioLevelDelegate{
    func subscriber(_ subscriberLevel: OTSubscriberKit, audioLevelUpdated audioLevel: Float) {
        let sub = subscribers.first { (sub) -> Bool in
            sub.key.stream?.streamId == subscriberLevel.stream?.streamId
        }
        subscribers.updateValue(audioLevel, forKey: (sub?.key)!)
        
        print("publisher stream: ",String(subscriberLevel.stream?.streamId ?? "A")+" audio level: "+String(audioLevel));
        
        print("subscribers.count: ", String(subscribers.count))
        
        if (sub != nil && audioLevel > 0.2 && subscribers.count > 1 && subscribers.count < 5) {
            // swap views
            let sortedSubscribers = subscribers.sorted { (first, second) -> Bool in first.value > second.value}
            
            let newMainView = sortedSubscribers[0].key.view!
            let newSubView = getOtherSubscriberView(count: subscribers.count - 1, view: sortedSubscribers[1].key.view!)
            newMainView.frame = UIScreen.main.bounds

            view.insertSubview(newMainView, at: 0)
            view.insertSubview(newSubView, at: 2)
            
        }
    }
}

// MARK: - OTPublisherDelegate callbacks
extension VideoChatViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

// MARK: - OTSubscriberDelegate callbacks
extension VideoChatViewController: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}
