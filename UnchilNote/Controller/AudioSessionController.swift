//
//  AudioSessionController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//
import Foundation
import AVFoundation
import Speech
import SwiftUI
import CoreMedia

class AudioSessionController {

	var audioEngine:AVAudioEngine?
	var speechRecognizer:SFSpeechRecognizer?
	var audioRecorder:AVAudioRecorder?
	var audioPlayer:AVAudioPlayer?

	var fileRecognitionRequest: SFSpeechURLRecognitionRequest?
	var bufferRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	var recognitionTask: SFSpeechRecognitionTask?

	deinit {
		reset()
	}


	private func reset() {
		speechRecognizerReset()
		audioRecorderReset()
		audioPlayerReset()
	}

	func speechRecognizerReset(){
		recognitionTask?.cancel()
		audioEngine?.stop()
		audioEngine = nil
		recognitionTask = nil

	}

	func audioRecorderReset(){
		if (audioRecorder?.isRecording ?? false) == true {
			audioRecorder?.stop()
		}
		audioRecorder = nil
		AudioSessionController.audioSessionDeactivate()
	}

	func audioPlayerReset(){
		if (audioPlayer?.isPlaying ?? false) == true {
			audioPlayer?.stop()
		}
		audioPlayer = nil
		AudioSessionController.audioSessionDeactivate()
	}


	static func audioSessionSet() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
		} catch {
			print("Failed to audioSessionSet")
		}
	}


	static func audioSessionActivate() {
		do {
			try AVAudioSession.sharedInstance().setActive(true)
		} catch {
			print("Failed to audioSessionActivate")
		}
	}

	static func audioSessionDeactivate() {
		do{
			try AVAudioSession.sharedInstance().setActive(false)
		}catch{
			print("Failed to  audioSessionDeactivate")
		}
	}

	static func canAccess(withHandler handler: @escaping (Bool) -> Void) {
		SFSpeechRecognizer.requestAuthorization { status in
			if status == .authorized {
				AVAudioSession.sharedInstance().requestRecordPermission { authorized in
					handler(authorized)
				}
			} else {
				handler(false)
			}
		}
	}

}




struct Recorder {
	let assistant:AudioSessionController = AudioSessionController()
	let settings = [
		AVFormatIDKey: Int(kAudioFormatLinearPCM),
		AVSampleRateKey: 44100,
		AVNumberOfChannelsKey: 2,
	//	AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
		AVLinearPCMBitDepthKey: 16
	]


	func startRecording(url:URL){

		AudioSessionController.canAccess { authorized in

			guard authorized else { return }

			AudioSessionController.audioSessionActivate()

			do { assistant.audioRecorder = try AVAudioRecorder(url: url, settings: settings) } catch {
				 print("Could not start recording")
				AudioSessionController.audioSessionDeactivate()
				return
			 }
			assistant.audioRecorder?.record()
		}
	}


	func stopRecording() {
		assistant.audioRecorder?.stop()
		AudioSessionController.audioSessionDeactivate()
	}

}



struct Player {

	let assistant:AudioSessionController = AudioSessionController()

	func preparePlaying(url:URL, binding: Binding<AVAudioPlayer?>){

		guard url.isFileURL  else { return }

		AudioSessionController.audioSessionActivate()

		do {
			assistant.audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: "wav")
		} catch {
			print("Could not start playing")
			AudioSessionController.audioSessionDeactivate()
			return
		}
		assistant.audioPlayer?.prepareToPlay()

		binding.wrappedValue = assistant.audioPlayer!

	}

	func startPlaying(){
		AudioSessionController.audioSessionActivate()
		assistant.audioPlayer?.play()

	}

	func pausePlaying() {
		assistant.audioPlayer?.pause()
		AudioSessionController.audioSessionDeactivate()

	}

	func stopPlaying(){
		assistant.audioPlayerReset()
	}

}
