import SwiftUI
import AVKit
import MapKit
import Vision
import VisionKit

struct SplashView: View {
    @State private var isActive = false
    private let player = AVPlayer(url: Bundle.main.url(forResource: "video", withExtension: "mp4")!)
    
    var body: some View {
        if isActive {
            DestinationView()
        } else {
            VideoPlayer(player: player)
                .toolbar(.hidden, for: .tabBar)
                .toolbar(.hidden, for: .bottomBar)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    player.play()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        withAnimation {
                            isActive = true
                        }
                    }
                }
        }
    }
}

struct DestinationView: View {
    @State var isJames = Bool.random()
    @State private var matchScore = Int.random(in: 70...100)
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    @State private var isFaceVerified = false
    @State private var showCamera = false
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("You've matched with")
                    .foregroundStyle(.secondary)
                Text(isJames ? "James Huang" : "Woody Wang")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Image(isJames ? "James" : "Woody")
                    .resizable()
                    .frame(width: 200, height: 300)
                Spacer()
                HStack {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 10)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(matchScore) / 100)
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .foregroundColor(.accent)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: matchScore)
                    }
                    .frame(width: 50, height: 50)
                    .padding()
                    VStack(alignment: .leading) {
                        Text("Match score")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        Text("\(matchScore)%")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
                
                NavigationLink {
                    VStack {
                        Text("Great, let's meet \(isJames ? "James" : "Woody")")
                            .font(.title)
                            .fontWeight(.bold)
                            .cornerRadius(8)
                            .fontWeight(.medium)
                        Text("He will be waiting for you here")
                            .foregroundStyle(.secondary)
                            .cornerRadius(8)
                            .padding(.bottom, 12)
                            .fontWeight(.medium)
                        Map(coordinateRegion: $region)
                            .frame(height: 300)
                            .cornerRadius(12)
                        Text("San Francisco, CA")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .cornerRadius(8)
                            .fontWeight(.medium)
                            .padding(8)
                        Button {
                                        showCamera = true
                                    } label: {
                                        Text("I'm here")
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity)
                                            .background(.accent)
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .sheet(isPresented: $showCamera) {
                                        QRScannerViewWrapper()
                                    }
                        Label("We will confirm their identify with on-device computer vision.", systemImage: "sparkles")
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } label: {
                    Text("Go meet \(isJames ? "James" : "Woody")")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button {
                } label: {
                    Text("Cancel")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(.accent.opacity(0.15))
                        .foregroundColor(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SplashView()
}


struct QRScannerView: UIViewControllerRepresentable {
    @Binding var isVerified: Bool
    var isJames: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        // Check camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            print("Camera access denied.")
            return viewController
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        _ = self.makeUIViewController(context: context) // Restart setup
                    }
                }
            }
            return viewController
        case .authorized:
            break
        @unknown default:
            return viewController
        }

        // Set up camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Error: No video capture device found")
            return viewController
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Error creating video input: \(error.localizedDescription)")
            return viewController
        }

        // Set up metadata output
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Error: Could not add metadata output")
            return viewController
        }

        // Set up preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = viewController.view.bounds
        viewController.view.layer.addSublayer(previewLayer)

        // Start capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }

        context.coordinator.captureSession = captureSession
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        var captureSession: AVCaptureSession?
        var lastScanTime: Date = Date.distantPast // Track last scan time

        init(_ parent: QRScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastScanTime) < 1.0 {
                return // Ignore scans within 1 second
            }
            lastScanTime = currentTime // Update last scan time

            if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let scannedText = metadataObject.stringValue?.lowercased() {
                DispatchQueue.main.async {
                    print("Scanned: \(scannedText)") // Debugging output
                    if (self.parent.isJames && scannedText == "james") || (!self.parent.isJames && scannedText == "woody") {
                        self.parent.isVerified = true
                    }
                }
            }
        }
    }
}
struct QRScannerViewWrapper: View {
    @State private var isVerified = false
    @State private var quizAnswers: [QuizAnswer] = [
            QuizAnswer(title: "Pets", question: "Do you prefer cats over dogs?"),
            QuizAnswer(title: "Debates", question: "Do you enjoy debates?"),
            QuizAnswer(title: "Waking up", question: "Are you a morning person?"),
            QuizAnswer(title: "Pizza", question: "Do you like pineapple on pizza?")
        ]
    @State private var currentIndex: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                QRScannerView(isVerified: $isVerified, isJames: true)
                    .edgesIgnoringSafeArea(.all)
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack(spacing:8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .opacity(0.5)
                            Text("ARKit not available on this device")
                            NavigationLink {
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    
                                    VStack(spacing: 20) {
                                        Text(quizAnswers[currentIndex].question)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        
                                        Button("Next") {
                                            if currentIndex < quizAnswers.count - 1 {
                                                currentIndex += 1
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .padding()
                                }
                            } label: {
                                Text("Continue")
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(.accent)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    )
            }
        }
    }
}
