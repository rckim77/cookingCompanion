//
//  RecipeProcedureVC.swift
//  cookingCompanion
//
//  Created by Raymond Kim on 5/23/17.
//  Copyright © 2017 Raymond Kim. All rights reserved.
//

import UIKit
import Speech

class RecipeProcedureVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneBtnPress(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // processes audio stream; gives updates when mic is receiving audio
    let audioEngine = AVAudioEngine()
    // can fail to recognize speech; defaults to device's locale
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    // allocates speech as user speak in real-time and controls buffering
    let request = SFSpeechAudioBufferRecognitionRequest()
    // manage, cancel, or stop current recognition task
    var recognitionTask: SFSpeechRecognitionTask?
    
    let numberOfSteps: Int = 9
    var utterance: String?
    var utteranceSegments = [SFTranscriptionSegment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech() {
        // nodes process bits of audio
        // inputNode creates singleton for incoming audio
        guard let node = audioEngine.inputNode else { return }
        
        let recordingFormat = node.outputFormat(forBus: 0)
        // configures node and sets up request instance with proper buffer on proper bus
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { buffer, _ in
            self.request.append(buffer)
        })
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            // a recognizer isn't supported for current locale
            return
        }
        
        if !myRecognizer.isAvailable {
            // a recognizer isn't available right now
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
                // capture the most recent word(s)
                let mostRecentSegmentsCount = result.bestTranscription.segments.count - self.utteranceSegments.count
                
                // check user has said something new in current audio stream
                if mostRecentSegmentsCount > 0 {
                    let mostRecentSegments = result.bestTranscription.segments.suffix(from: self.utteranceSegments.count)

                    let mostRecentString = mostRecentSegments.flatMap({ $0.substring }).joined(separator: " ")
                    
                    // if there's a valid substring, scroll to next step (until you hit the last step)
                    if mostRecentString.containsValidNextSubstring() {
                        let lastVisibleIndexPath = visibleIndexPaths.sorted(by: { $0.row < $1.row }).last!
                        
                        if lastVisibleIndexPath.row < self.numberOfSteps - 1 {
                            let nextCellIndexPath = IndexPath(row: lastVisibleIndexPath.row + 1, section: 0)
                            self.collectionView.scrollToItem(at: nextCellIndexPath, at: .top, animated: true)
                        } else {
                            print("Last step is visible")
                        }
                        
                        print("Result valid substring: \(mostRecentString)")
                    } else if mostRecentString.containsValidBackSubstring() {
                        let firstVisibleIndexPath = visibleIndexPaths.sorted(by: { $0.row < $1.row }).first!
                        
                        if firstVisibleIndexPath.row > 0 {
                            let prevCellIndexPath = IndexPath(row: firstVisibleIndexPath.row - 1, section: 0)
                            self.collectionView.scrollToItem(at: prevCellIndexPath, at: .top, animated: true)
                        } else {
                            print("First step is visible")
                        }
                    }
                    
                    self.utterance = result.bestTranscription.formattedString
                    self.utteranceSegments = result.bestTranscription.segments
                    
                    print("Result String: \(result.bestTranscription.formattedString)")
                }
                
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func completedBtnPress(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension RecipeProcedureVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfSteps
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeProcedureCell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "recipeProcedureFooter", for: indexPath) as! RecipeProcedureFooterView
            footerView.completedBtn.addTarget(self, action: #selector(completedBtnPress), for: .touchUpInside)
            
            return footerView
        } else {
            assert(false, "Unexpected element kind")
        }
    }
}
