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
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
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
    
    let numberOfSteps: Int = 7
    var utterance: String?
    var utteranceSegments = [SFTranscriptionSegment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordAndRecognizeSpeech()
        
        let margin: CGFloat = 4
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - margin, height: 400)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeProcedureCell", for: indexPath) as! RecipeProcedureStepCell
        
        switch indexPath.row {
        case 0:
            cell.directionsLabel.text = "1. Heat sous vide to 140F (or 60C) in a container of water."
            cell.descriptionLabel.text = ""
            cell.imageView.image = #imageLiteral(resourceName: "charsiuporksousvide")
        case 1:
            cell.directionsLabel.text = "2. Slice pork into steaks"
            cell.descriptionLabel.text = "Slice pork shoulder into steaks about 1.5\" (38mm) thick."
            cell.imageView.isHidden = true
        case 2:
            cell.directionsLabel.text = "3. Season pork"
            cell.descriptionLabel.text = "Season pork with salt and let rest, allowing salt to dissolve into meat for 20 to 30 minutes."
            cell.imageView.image = #imageLiteral(resourceName: "charsiuporksalt")
        case 3:
            cell.directionsLabel.text = "4. Bag it up"
            cell.descriptionLabel.text = "Fill sous vide bag with sauce, then add meat. You can cook meat right away or store in the fridge for up to 24 hours."
            cell.imageView.image = #imageLiteral(resourceName: "charsiuporkbag")
        case 4:
            cell.directionsLabel.text = "5. Cook for 8 hours"
            cell.descriptionLabel.text = "Lower the bag into the cooking water and cook for 8 hours."
            cell.imageView.image = #imageLiteral(resourceName: "charsiuporkbag2")
        case 5:
            cell.directionsLabel.text = "6. Finish"
            cell.descriptionLabel.text = "Sear steaks on each side until they reach a deep mahogany color. Remove right away."
            cell.imageView.image = #imageLiteral(resourceName: "charsiuporkfinish")
        case 6:
            cell.directionsLabel.text = "7. Serve"
            cell.descriptionLabel.text = "Serve your pork right away–we like to offer it alongside little dipping bowls of mustard, green onions, and sesame seeds."
            cell.imageView.image = #imageLiteral(resourceName: "charsiupork")
        default:
            cell.directionsLabel.text = ""
            cell.imageView.isHidden = true
        }
        
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
