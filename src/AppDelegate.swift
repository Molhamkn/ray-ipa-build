//
//  AppDelegate.swift RayAssistant
//
import UIKit
import AVFoundation
import UserNotifications
import Network
import Speech

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var audioEngine: AVAudioEngine!
    var speechRecognizer: SFSpeechRecognizer!
    var inputNode: AVAudioInputNode!
    var wsTask: URLSessionWebSocketTask!
    var isConnected = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.rootViewController?.view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "Ray AI\nListening..."
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        window?.rootViewController?.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: window!.rootViewController!.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: window!.rootViewController!.view.centerYAnchor)
        ])
        
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.startServices()
        }
        
        return true
    }
    
    private func startServices() {
        enableBackgroundModes()
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        startMicrophoneCapture()
        connectWebSocket()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func enableBackgroundModes() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .voiceChat, options: [.duckOthers, .allowBluetooth])
        try? session.setActive(true)
    }

    private func startMicrophoneCapture() {
        do {
            audioEngine = AVAudioEngine()
            inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.sendSTT(text: "placeholder transcript")
            }
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Mic error:", error)
        }
    }

    private func sendSTT(text: String) {
        guard isConnected else { return }
        let payload: [String: Any] = ["text": text]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let json = String(data: data, encoding: .utf8) {
            wsTask.send(.string(json)) { err in
                if let err = err { print("WS send error:", err) }
            }
        }
    }

    private func connectWebSocket() {
        do {
            let url = URL(string: "wss://45.120.55.38:8765")!
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            wsTask = session.webSocketTask(with: url)
            wsTask.resume()
            isConnected = true
            receiveMessages()
        } catch {
            print("WebSocket error:", error)
        }
    }

    private func receiveMessages() {
        wsTask.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                print("WS recv error:", err)
                self.isConnected = false
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.connectWebSocket()
                }
            case .success(let msg):
                if case .string(let txt) = msg {
                    self.handleRouterMessage(txt)
                }
                self.receiveMessages()
            }
        }
    }

    private func handleRouterMessage(_ jsonStr: String) {
        guard let data = jsonStr.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let reply = dict["reply"] as? String else { return }
        speak(text: reply)
        let content = UNMutableNotificationContent()
        content.title = "Ray"
        content.body = reply
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
}

extension AppDelegate: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket closed, reconnecting…")
        isConnected = false
        connectWebSocket()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
