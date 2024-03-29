//
//  ViewController.swift
//  ASiC Midterm-Exam
//
//  Created by Fu-Chiung HSU on 2019/3/29.
//  Copyright © 2019 Fu-Chiung HSU. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var statusLebel: UILabel!
    
    @IBOutlet weak var videoView: VideoView!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var fullScreenBtn: UIButton!
    
    @IBOutlet weak var muteBtn: UIButton!
    
    @IBOutlet weak var backwardBtn: UIButton!
    
    @IBOutlet weak var forwardBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        JQButton.shared.buttonBorder(button: searchBtn)
        
        JQButton.shared.setImage(button: playBtn, normalImage: UIImage.asset(.stop), selectedImage: UIImage.asset(.play_button))
        
        JQButton.shared.setImage(button: fullScreenBtn, normalImage: UIImage.asset(.full_screen_button), selectedImage: UIImage.asset(.full_screen_exit))
        
        JQButton.shared.setImage(button: muteBtn, normalImage: UIImage.asset(.volume_up), selectedImage: UIImage.asset(.volume_off))
        
        timeSlider.value = 0
        
        determineMyDeviceOrientation()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            if UIApplication.shared.statusBarOrientation.isLandscape {
                // activate landscape changes
                self.landscapeModeLayout()
                self.fullScreenBtn.isSelected = true
            } else {
                // activate portrait changes
                self.portraitModeLayout()
                self.fullScreenBtn.isSelected = false
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let playerlayer = self.videoView.playerLayer else { return }
        playerlayer.frame = videoView.bounds
    }
    
    func determineMyDeviceOrientation() {
        if UIDevice.current.orientation.isLandscape {
            landscapeModeLayout()
            fullScreenBtn.isSelected = true
        } else {
            portraitModeLayout()
            fullScreenBtn.isSelected = false
        }
    }

    func portraitModeLayout(){
        self.statusLebel.textColor = UIColor.gray
        self.videoView.backgroundColor = UIColor.white
        self.durationLabel.textColor = UIColor.gray
        self.currentTimeLabel.textColor = UIColor.gray
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.playBtn.tintColor = UIColor.black
        self.muteBtn.tintColor = UIColor.black
        self.fullScreenBtn.tintColor = UIColor.black
        self.backwardBtn.tintColor = UIColor.black
        self.forwardBtn.tintColor = UIColor.black
    }
    
    func landscapeModeLayout() {
        self.statusLebel.textColor = UIColor.white
        self.videoView.backgroundColor = UIColor.gray
        self.durationLabel.textColor = UIColor.white
        self.currentTimeLabel.textColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.playBtn.tintColor = UIColor.white
        self.muteBtn.tintColor = UIColor.white
        self.fullScreenBtn.tintColor = UIColor.white
        self.backwardBtn.tintColor = UIColor.white
        self.forwardBtn.tintColor = UIColor.white
    }
    
    func addTimeObserver() {
        guard let player = videoView.player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = player.currentItem else {return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.videoView.getTimeString(from: currentItem.currentTime())
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = videoView.player else { return }
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLabel.text = videoView.getTimeString(from: player.currentItem!.duration)
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        videoView.stop()
        playBtn.isSelected = false
        muteBtn.isSelected = false
        
        if searchTextField.text?.isEmpty == true {
            
            //hard code for test
            statusLebel.isHidden = true
            videoView.configure(url: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")
            videoView.player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            videoView.play()

//            videoView.isHidden = true
//            statusLebel.text = "請輸入欲播放影片網址"
    
        } else {
            guard let searchUrl: String = searchTextField.text else { return }
            statusLebel.isHidden = true
            videoView.configure(url: searchUrl)
            videoView.player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            videoView.play()
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        if playBtn.isSelected == true {
            videoView.play()
            playBtn.isSelected = false
        } else {
            videoView.pause()
            playBtn.isSelected = true
        }
    }
    
    @IBAction func muteBtn(_ sender: Any) {
        guard let player = videoView.player else { return }
        if muteBtn.isSelected == true {
            player.isMuted = false
            muteBtn.isSelected = false
        } else {
            player.isMuted = true
            muteBtn.isSelected = true
        }
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        videoView.forward(time: 10.0)
    }

    
    @IBAction func backwardPressed(_ sender: Any) {
        videoView.backward(time: 10.0)
    }
    
    @IBAction func silderValueChange(_ sender: UISlider) {
        videoView.seek(to: CMTimeMake(value: Int64(sender.value * 1000), timescale: 1000))
    }
    
    @IBAction func fullscreenAction(_ sender: Any) {
        if fullScreenBtn.isSelected == false {
            fullScreenBtn.isSelected = true
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            landscapeModeLayout()
        } else {
            fullScreenBtn.isSelected = false
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            portraitModeLayout()
        }
    }
}

