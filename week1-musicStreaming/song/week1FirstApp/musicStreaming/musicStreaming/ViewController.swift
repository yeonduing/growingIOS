//
//  ViewController.swift
//  musicStreaming
//
//  Created by 송형욱 on 2020/08/16.
//  Copyright © 2020 iosStudy. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var albumView: UIView!
    @IBOutlet weak var albumImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var lyricFirst: UILabel!
    @IBOutlet weak var lyricSecond: UILabel!
    @IBOutlet weak var streamingSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var EndTimeLabel: UILabel!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var playBtnView: UIView!
    @IBOutlet weak var lyricsView: UIView!
    
    var player: AVAudioPlayer!
    var timer: Timer!
    

    // [x] TODO: TIME LABEL (START,END)
    // TODO: BUTTON UI
    // TODO: SLIDER BAR UI
    // [x] TODO: 음악 연결 및 재생
    // TODO: 가사 싱크 맞추기

    // [x] 재생 버튼&기능 구현
    @IBAction func playPauseBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.makeAndFireTimer()
        } else {
            self.invalidateTimer()
        }
    }
    
    // [x] TODO: Slider 변화
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayer()
        layout()
    }
}

extension ViewController {
    func designAlbumView() {
        albumView.layer.cornerRadius = 100
        albumView.backgroundColor = UIColor(displayP3Red: 235/255, green: 237/255, blue: 231/255, alpha: 1)
        albumView.layer.shadowOffset = CGSize(width: -3, height: -3)
        albumView.layer.shadowColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor
        albumView.layer.shadowOpacity = 1.0
        albumView.layer.shadowRadius = 6.0
    }
    func designPlayBtnView() {
        // TODO: Design to PlayBtn
        // ----- 그림자 표현하기
        // 왜 안되는 지 모르겠음 아 짜증나
        playBtnView.layer.cornerRadius = 100
        playBtnView.backgroundColor =  UIColor(displayP3Red: 235/255, green: 237/255, blue: 231/255, alpha: 1)
        playBtnView.layer.shadowOffset = CGSize(width: -3, height: -3)
        playBtnView.layer.shadowColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor
        playBtnView.layer.shadowOpacity = 1.0
        playBtnView.layer.shadowRadius = 6.0
    }
    func designLyricsView() {
        lyricsView.layer.backgroundColor =  UIColor(displayP3Red: 235/255, green: 237/255, blue: 231/255, alpha: 1).cgColor
        lyricFirst.textColor = UIColor(displayP3Red: 145/255, green: 155/255, blue: 167/255, alpha: 1)
        lyricSecond.textColor = UIColor(displayP3Red: 145/255, green: 155/255, blue: 167/255, alpha: 1)
    }
    func designSliderBarView() {
        // TODO: Design to PlayBtn
        // sliderView
        sliderView.layer.cornerRadius = 27
        sliderView.backgroundColor =  UIColor(displayP3Red: 235/255, green: 237/255, blue: 231/255, alpha: 1)
        sliderView.layer.shadowOffset = CGSize(width: -3, height: -3)
        sliderView.layer.shadowColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor
        sliderView.layer.shadowRadius = 6
        sliderView.layer.shadowOpacity = 1.0
        // sliderBar
        // [x] Slider image 등록
        streamingSlider.setThumbImage(UIImage(named: "slide_button"), for: .normal)
        streamingSlider.setThumbImage(UIImage(named: "slide_button"), for: .highlighted)
        streamingSlider.setMaximumTrackImage(UIImage(named: "slide_line"), for: .normal)
        streamingSlider.minimumTrackTintColor = UIColor.darkGray
    }
    func designTitleLabel() {
        titleLabel.textColor = UIColor(displayP3Red: 79/255, green: 88/255, blue: 101/255, alpha: 1)
        titleLabel.font.withSize(21)
        titleLabel.layer.shadowColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8).cgColor
        titleLabel.layer.shadowOffset = CGSize(width: -2, height: 2)
        titleLabel.layer.shadowRadius = 3
        titleLabel.layer.masksToBounds = false
    }
    func designArtistLabel() {
        artistLabel.textColor = UIColor(displayP3Red: 145/255, green: 155/255, blue: 167/255, alpha: 1)
    }
    
    func layout() {
        
        view.backgroundColor = UIColor(displayP3Red: 235/255, green: 237/255, blue: 231/255, alpha: 1)
        
        designAlbumView()
        designPlayBtnView()
        designTitleLabel()
        designLyricsView()
        designSliderBarView()
        designArtistLabel()
    }
}

extension ViewController {
    
    func initializePlayer() {
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다")
            return
        }
        
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
        
        streamingSlider.maximumValue = Float(self.player.duration)
        streamingSlider.minimumValue = 0
        streamingSlider.value = Float(self.player.currentTime)
        
        // [x] END TIME LABEL 곡 정보 읽어서 총 시간 설정
        let endTime = self.player.duration
        let minute: Int = Int(endTime / 60)
        let second: Int = Int(endTime.truncatingRemainder(dividingBy: 60))
        EndTimeLabel.text = String(format: "%02ld:%02ld", minute, second)
    }
    
    // [x] START TIME LABEL 시간이 흘러갈수록 LABEL 변화
    func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        
        let timeText: String = String(format: "%02ld:%02ld", minute, second)
        
        startTimeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
          
            if self.streamingSlider.isTracking { return }
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.streamingSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playBtn.isSelected = false
        streamingSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
}

// TODO: 가사 저장 & 구조체로 표현
struct Track {
    let title: String
    let artist: String
    let timestamp: TimeInterval
}

class LyricsConfiguration {

    enum lyric: String {
        case first
        case second
        
        var time023: String {
            switch self {
            case .first : return "To all the girls around the world"
            case .second : return "Love and be loved from Linda G Lady T Baby baby"
            }
        }
    }
    
    struct DefaultConfig {
        let time023: Int = 1
    }
    
    static let `default` = DefaultConfig()
    
    static var time023first : String {
        let time = LyricsConfiguration.default.time023
        return time == 23 ? "\(lyric.first)" : ""
    }
    
    static var time023second : String {
        let time = LyricsConfiguration.default.time023
        return time == 23 ? "\(lyric.second)" : ""
    }
}
