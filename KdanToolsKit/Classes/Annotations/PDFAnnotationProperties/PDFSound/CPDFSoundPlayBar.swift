//
//  CPDFSoundPlayBar.swift
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

import UIKit
import AVFAudio
import AVFoundation

public enum CPDFSoundState: Int {
    case record = 0
    case play
}

public enum CPDFAudioState {
    case pause
    case recording
    case playing
    
}

public var SOUND_TMP_DICT = NSTemporaryDirectory()+"soundCache"

@objc public protocol CPDFSoundPlayBarDelegate: AnyObject {
    @objc optional func soundPlayBarRecordFinished(_ soundPlayBar: CPDFSoundPlayBar, withFile filePath: String)
    @objc optional func soundPlayBarRecordCancel(_ soundPlayBar: CPDFSoundPlayBar)
    @objc optional func soundPlayBarPlayClose(_ soundPlayBar: CPDFSoundPlayBar)
}

public class CPDFSoundPlayBar: UIView, AVAudioPlayerDelegate {
    let annotStyle: CAnnotStyle?
    public var soundState: CPDFSoundState = .record
    
    public weak var delegate: CPDFSoundPlayBarDelegate?
    
    private var voiceTimer: Timer?
    private var playButton: UIButton?
    private var closeButton: UIButton?
    private var sureButton: UIButton?
    private var timeDisplayLabel: UILabel?
    private var formatter: DateFormatter?
    private var avAudioRecorder: AVAudioRecorder?
    private var avAudioPlayer: AVAudioPlayer?
    private var state: CPDFAudioState = .recording
    
    // MARK: - Initializers
    
    public init(style annotStyle: CAnnotStyle?) {
        self.annotStyle = annotStyle
        self.soundState = .record
        
        super.init(frame: CGRect.zero)
        
        setDateFormatter()
        initWithView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Accessors
    
    func setDateFormatter() {
        if formatter == nil {
            formatter = DateFormatter()
            formatter?.locale = Locale(identifier: "en_GB")
            formatter?.timeZone = TimeZone(identifier: "GMT")
            formatter?.dateFormat = "HH:mm:ss"
        }
    }
    
    
    public func show(inView subView: UIView, soundState: CPDFSoundState) {
        // Implementation...
        self.soundState = soundState
        if soundState == .play {
            self.frame = CGRect(x: (subView.frame.size.width - 146.0) / 2, y: subView.frame.size.height - 120 - 10, width: 146.0, height: 40)
            self.sureButton?.isHidden = true
            self.closeButton?.frame = CGRect(x: self.frame.size.width - 8 - 24, y: (self.frame.size.height - 24.0) / 2, width: 24, height: 24)
            self.playButton?.setImage(UIImage(named: "CPDFSoundImageNamePlay", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        } else if soundState == .record {
            self.frame = CGRect(x: (subView.frame.size.width - 174.0) / 2, y: subView.frame.size.height - 120 - 10, width: 174.0, height: 40)
            self.sureButton?.isHidden = false
            self.sureButton?.frame = CGRect(x: self.frame.size.width - 8 - 24, y: (self.frame.size.height - 24.0) / 2, width: 24, height: 24)
            self.closeButton?.frame = CGRect(x: self.frame.size.width - 8 - 24 - (self.sureButton?.frame.size.width ?? 0) - 10, y: (self.frame.size.height - 24.0) / 2, width: 24, height: 24)
            self.playButton?.setImage(UIImage(named: "CPDFSoundImageNamePlay", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        }
        self.layer.cornerRadius = 5.0
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        subView.addSubview(self)
    }
    
    public func setURL(_ url: URL?) {
        // Implementation...
        if soundState == .record {
            audioRecorderInit(with: url)
        } else if soundState == .play {
            audioPlayerInit(with: url)
        }
        
        setDateFormatter()
    }
    
    public func startRecord() {
        self.state = .recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord)
            try audioSession.setActive(true)
            
            if avAudioRecorder?.prepareToRecord() == true {
                avAudioRecorder?.record()
            } else {
                print("error: unprepared to record!")
                return
            }
        } catch {
            print("error: \(error)")
            return
        }
        
    }
    
    
    public func startAudioRecord() {
        // Implementation...
        setURL(nil)
        startTimer()
        startRecord()
    }
    
    public func stopRecord() {
        // Implementation...
        self.state = .pause
        stopTimer()
        if avAudioRecorder?.currentTime ?? 0.0 > 0.1 {
            avAudioRecorder?.stop()
            let url = avAudioRecorder?.url
            let path = url?.path ?? ""
            let manager = FileManager.default
            if manager.fileExists(atPath: path) {
                delegate?.soundPlayBarRecordFinished?(self, withFile: path)
            }
            
        } else {
            avAudioRecorder?.stop()
        }
        removeFromSuperview()
        
    }
    
    public func startAudioPlay() {
        // Implementation...
        self.state = .playing
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            startTimer()
            avAudioPlayer?.play()
            
        } catch {
            print("Error setting audio session category: (error)")
        }
        
    }
    
    public func stopAudioPlay() {
        // Implementation...
        self.state = .pause
        if avAudioPlayer?.isPlaying == true {
            avAudioPlayer?.stop()
        }
        stopTimer()
        timeDisplayLabel?.text = "00:00:00"
        playButton?.setImage(UIImage(named: "CPDFSoundImageNameStop", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        
    }
    
    // MARK: - Private Methods
    
    func initWithView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.playButton = UIButton(type: .custom)
        self.playButton?.frame = CGRect(x: 8, y: 8, width: 24, height: 24)
        self.playButton?.setImage(UIImage(named: "CPDFSoundImageNamePlay", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.playButton?.addTarget(self, action: #selector(buttonItemClicked_Play(_:)), for: .touchUpInside)
        self.addSubview(self.playButton!)
        
        self.timeDisplayLabel = UILabel()
        self.timeDisplayLabel?.backgroundColor = UIColor.clear
        self.timeDisplayLabel?.textColor = UIColor.white
        self.timeDisplayLabel?.font = UIFont.systemFont(ofSize: 13.0)
        self.timeDisplayLabel?.text = "00:00:00"
        self.timeDisplayLabel?.sizeToFit()
        self.timeDisplayLabel?.frame = CGRect(x: (self.playButton?.frame.maxX ?? 0) + 10, y: 8, width: (self.timeDisplayLabel?.frame.size.width ?? 0) + 20, height: 24.0)
        self.addSubview(self.timeDisplayLabel!)
        
        self.sureButton = UIButton(type: .custom)
        self.sureButton?.frame = CGRect(x: self.frame.size.width - 8 - 24, y: 8, width: 24, height: 24)
        self.sureButton?.autoresizingMask = [.flexibleLeftMargin]
        self.sureButton?.setImage(UIImage(named: "CPDFSoundImageNameSure", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.sureButton?.addTarget(self, action: #selector(buttonItemClicked_Sure(_:)), for: .touchUpInside)
        self.addSubview(self.sureButton!)
        
        self.closeButton = UIButton(type: .custom)
        self.closeButton?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        self.closeButton?.frame = CGRect(x: self.frame.size.width - 8 - 24 - (self.sureButton?.frame.size.width ?? 0) - 10, y: 8, width: 24, height: 24)
        self.closeButton?.autoresizingMask = [.flexibleLeftMargin]
        self.closeButton?.setImage(UIImage(named: "CPDFSoundImageNameClose", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        self.closeButton?.addTarget(self, action: #selector(buttonItemClicked_Close(_:)), for: .touchUpInside)
        self.addSubview(self.closeButton!)
        
    }
    
    func startTimer() {
        if voiceTimer != nil {
            voiceTimer?.invalidate()
            voiceTimer = nil
        }
        voiceTimer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(reflashAsTimeGoesBy), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if voiceTimer != nil {
            voiceTimer?.invalidate()
            voiceTimer = nil
        }
    }
    
    func audioRecorderInit(with url: URL?) {
        var recordSetting: [String: Any] = [:]
        recordSetting[AVFormatIDKey] = NSNumber(value: kAudioFormatLinearPCM)
        recordSetting[AVSampleRateKey] = NSNumber(value: 11025)
        recordSetting[AVNumberOfChannelsKey] = NSNumber(value: 2)
        recordSetting[AVLinearPCMBitDepthKey] = NSNumber(value: 16)
        recordSetting[AVEncoderAudioQualityKey] = NSNumber(value: AVAudioQuality.high.rawValue)
        
        var m_url = url
        
        if m_url == nil {
            var path: String?
            let manager = FileManager.default
            var isDict: ObjCBool = false
            var dictOK = false
            if manager.fileExists(atPath: SOUND_TMP_DICT, isDirectory: &isDict) && isDict.boolValue {
                dictOK = true
            } else {
                do {
                    try manager.createDirectory(atPath: SOUND_TMP_DICT, withIntermediateDirectories: false, attributes: nil)
                    dictOK = true
                } catch {
                    print("Error creating directory: \(error)")
                }
                
            }
            
            if dictOK {
                for i in 0..<Int.max {
                    path = "\(SOUND_TMP_DICT)/tmp_\(i).wav"
                    if !manager.fileExists(atPath: path!) {
                        break
                    }
                }
            } else {
                print("tmp file directory error!")
            }
            
            m_url = URL(fileURLWithPath: path!)
        }
        
        if avAudioRecorder != nil {
            avAudioRecorder = nil
        }
        if(m_url != nil) {
            do {
                avAudioRecorder = try AVAudioRecorder(url: m_url!, settings: recordSetting)
                avAudioRecorder?.isMeteringEnabled = true
            } catch {
                print("Error creating AVAudioRecorder: \(error)")
            }
        }
        
    }
    
    func audioPlayerInit(with url: URL?) {
        if avAudioPlayer != nil {
            avAudioPlayer = nil
        }
        do {
            avAudioPlayer = try AVAudioPlayer(contentsOf: url!)
            avAudioPlayer?.volume = 1.0
            avAudioPlayer?.delegate = self
        } catch {
            print("Error creating AVAudioPlayer: \(error)")
        }
    }
    
    // MARK: - Action
    
    @objc func buttonItemClicked_Play(_ sender: Any) {
        if self.soundState == .record {
            if self.state == .pause {
                self.playButton?.setImage(UIImage(named: "CPDFSoundImageNamePlay", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                startTimer()
                startRecord()
                self.state = .recording
            } else {
                self.playButton?.setImage(UIImage(named: "CPDFSoundImageNameRec", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                stopTimer()
                avAudioRecorder?.pause()
                self.state = .pause
            }
        } else if self.soundState == .play {
            if self.state == .pause {
                self.playButton?.setImage(UIImage(named: "CPDFSoundImageNamePlay", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                startTimer()
                avAudioPlayer?.play()
                self.state = .playing
            } else {
                self.playButton?.setImage(UIImage(named: "CPDFSoundImageNameStop", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
                stopTimer()
                avAudioPlayer?.pause()
                self.state = .pause
            }
        }
    }
    
    @objc func buttonItemClicked_Sure(_ sender: Any) {
        if self.soundState == .record {
            stopRecord()
        }
    }
    
    @objc func buttonItemClicked_Close(_ sender: Any) {
        removeFromSuperview()
        if self.soundState == .record {
            avAudioRecorder?.stop()
            delegate?.soundPlayBarRecordCancel?(self)
        } else if self.soundState == .play {
            stopAudioPlay()
            delegate?.soundPlayBarRecordCancel?(self)
        }
        
    }
    
    @objc func reflashAsTimeGoesBy() {
        var time: TimeInterval
        if self.soundState == .record {
            time = avAudioRecorder?.currentTime ?? 0.0
            avAudioRecorder?.updateMeters()
            
            let dateToShow = Date(timeIntervalSince1970: time)
            let stringToShow = formatter?.string(from: dateToShow)
            timeDisplayLabel?.text = stringToShow
            
            if time >= 3600 {
                stopRecord()
            }
        } else if self.soundState == .play {
            time = avAudioPlayer?.currentTime ?? 0.0
            
            let dateToShow = Date(timeIntervalSince1970: time)
            let stringToShow = formatter?.string(from: dateToShow)
            timeDisplayLabel?.text = stringToShow
        }
        
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopAudioPlay()
    }
    
    public func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        stopAudioPlay()
    }
    
}

