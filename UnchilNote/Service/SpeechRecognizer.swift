//
//  SpeechRecognizer.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/12.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI



struct SpeechRecognizer {

	let assistant:AudioSessionController = AudioSessionController()

	private func relay(_ binding: Binding<String>, message: String) {
		DispatchQueue.main.async {
			binding.wrappedValue = message
		}
	}

	func stopSpeechToText() {
		 assistant.speechRecognizerReset()
	}

	func speechToText(To speech: Binding<String>, isRecordingToFile: Bool = false, isRecognizeFromFile:Bool = false,  URL fileUrl: URL,  Locale locale :Locale ) {

		AudioSessionController.canAccess { authorized in

			guard authorized else { return }

			assistant.speechRecognizer = SFSpeechRecognizer(locale: locale )

			assistant.audioEngine = AVAudioEngine()

			guard let audioEngine = assistant.audioEngine else {
				fatalError("Unable to create audio engine")
			}

			if isRecognizeFromFile {
				assistant.fileRecognitionRequest = SFSpeechURLRecognitionRequest(url: fileUrl)
			} else {
				assistant.bufferRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
			}

			guard let recognitionRequest = isRecognizeFromFile ? assistant.fileRecognitionRequest : assistant.bufferRecognitionRequest
			else {
				fatalError("Unable to create request")
			}


			recognitionRequest.shouldReportPartialResults = true

			AudioSessionController.audioSessionActivate()

			let inputNode = audioEngine.inputNode

			let outputFormat = inputNode.outputFormat(forBus: 0)


			if !isRecognizeFromFile {

				do {

					let settings: [String: Any] = [
						AVFormatIDKey: outputFormat.settings[AVFormatIDKey] ?? kAudioFormatLinearPCM,
						AVNumberOfChannelsKey: outputFormat.settings[AVNumberOfChannelsKey] ?? 2,
						AVSampleRateKey: outputFormat.settings[AVSampleRateKey] ?? 44100,
						AVLinearPCMBitDepthKey: outputFormat.settings[AVLinearPCMBitDepthKey] ?? 16
					]

					let audioFile = try AVAudioFile(forWriting: fileUrl, settings: settings)

					inputNode.installTap(onBus: 0, bufferSize: 1024, format: outputFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
						(recognitionRequest as! SFSpeechAudioBufferRecognitionRequest).append(buffer)

						if isRecordingToFile {
							try! audioFile.write(from: buffer)
						}
					}

				} catch {
					print("Error recording to File: " + error.localizedDescription)
					assistant.speechRecognizerReset()
					return
				}

			}

			audioEngine.prepare()

			do {
				try audioEngine.start()
			} catch {
				print("Error audioEngine.start(): " + error.localizedDescription)
				assistant.speechRecognizerReset()
				return
			}

			assistant.recognitionTask = assistant.speechRecognizer?.recognitionTask(with: recognitionRequest) { (result, error) in

				var isFinal = false

				if let result = result {
					relay(speech, message: result.bestTranscription.formattedString)
					isFinal = result.isFinal
				}

				if error != nil || isFinal {
					audioEngine.stop()
					inputNode.removeTap(onBus: 0)
					assistant.fileRecognitionRequest = nil
					assistant.bufferRecognitionRequest = nil
					AudioSessionController.audioSessionDeactivate()
				}
			}

		}

	}

}
