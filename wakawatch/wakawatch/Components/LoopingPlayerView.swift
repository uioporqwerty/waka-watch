import UIKit
import AVFoundation

class LoopingPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(videoName: String,
         player: AVQueuePlayer,
         videoGravity: AVLayerVideoGravity = .resizeAspect) {
        
        super.init(frame: .zero)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                         mode: AVAudioSession.Mode.default,
                                                         options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        guard let fileUrl = createLocalUrl(for: videoName, ofType: "mp4") else { return }
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        player.isMuted = true
        playerLayer.player = player
        playerLayer.videoGravity = videoGravity
        layer.addSublayer(playerLayer)
        
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
    }
    
    func createLocalUrl(for filename: String, ofType: String) -> URL? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(filename).\(ofType)")
        
        guard fileManager.fileExists(atPath: url.path) else {
            guard let video = NSDataAsset(name: filename)  else { return nil }
            fileManager.createFile(atPath: url.path, contents: video.data, attributes: nil)
            return url
        }
        
        return url
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
