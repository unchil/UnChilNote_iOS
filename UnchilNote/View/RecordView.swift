//
//  RecordView.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import SwiftUI
import AVFAudio

struct RecordView: View {

	var id:UUID = UUID()
	var fileURL:URL

	@StateObject var recordText:TextFieldData
	@State var audioPlayer:AVAudioPlayer!
	@State var playProgress: Double = 0.0
	@State var isEditing = false
	@State var isPlayState:Bool = false
	@State var isPlayStateBefore:Bool = false

	let bgColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))

	var body: some View {
		VStack(spacing:0){
			HStack(alignment: .center, spacing: 20){
				Button {
					if !self.audioPlayer.isPlaying {
						self.isPlayState = false
					}

					self.isPlayState.toggle()

					if self.isPlayState {
						self.audioPlayer.play()
						self.updateProgress()
					} else {
						self.audioPlayer.pause()
					}

				} label: {
					if let _ = self.audioPlayer {
						if ( !self.isPlayState || !self.audioPlayer.isPlaying){
							Image(systemName:"play.rectangle")
						} else {
							Image(systemName:"pause.rectangle")
						}
					} else { Image(systemName:"play.rectangle") }
				}
				.scaleEffect(ScaleEffectValue.pageViewIcon.rawValue, anchor: .center)


				if let _ = self.audioPlayer {
					Slider(value: self.$playProgress, in: 0...self.audioPlayer.duration) {
					} minimumValueLabel: {
						Text( self.audioPlayer.currentTime.formatmmss() + " / " + self.audioPlayer.duration.formatmmss() )
					} maximumValueLabel: { Text("")
					}onEditingChanged: { editting in
						self.isEditing = editting
						if self.isEditing {
							self.updateAudioSeek()
						}
					}
				} else {Text("00:00 / 00:00")}


			}
			.padding(.vertical, 12)
			.padding(.horizontal, 12)

			TextEditor(text: $recordText.data)
			.onAppear{
				UITextView.appearance().backgroundColor = .clear
			}
			.multilineTextAlignment(.center)
			.clipShape( RoundedRectangle(cornerRadius: 6))
			.background(bgColor)
		}
		.tint(.secondary)
		.onAppear{
			self.prepareToPlay()
		}
		.onDisappear{
			AudioSessionController.audioSessionDeactivate()
		}
	}
}

extension RecordView {

	private func stopPlayer() {
		if self.audioPlayer.isPlaying {
			self.audioPlayer.stop()
			self.audioPlayer = nil
		}
		AudioSessionController.audioSessionDeactivate()
	}

	private func prepareToPlay() {
		self.playProgress = 0
		AudioSessionController.audioSessionActivate()
		DispatchQueue.global(qos: .background).async {
			do { self.audioPlayer = try AVAudioPlayer(contentsOf: self.fileURL)
				self.audioPlayer.prepareToPlay()
			} catch {
				AudioSessionController.audioSessionDeactivate()
				print(error.localizedDescription)
			}
		}
	}

	private func updateProgress(){
		DispatchQueue.global(qos: .background).async {
			while self.audioPlayer.isPlaying {
				self.playProgress = ( self.audioPlayer.currentTime / self.audioPlayer.duration ) *  self.audioPlayer.duration
			}
		}
	}


	private func updateAudioSeek() {
		self.isPlayStateBefore = self.audioPlayer.isPlaying
		if self.isPlayStateBefore {
			self.audioPlayer.pause()
		}
		DispatchQueue.global(qos: .userInitiated).async {
			while self.isEditing { self.audioPlayer.currentTime  = self.playProgress }
			if self.isPlayStateBefore { self.audioPlayer.play() }
		}
	}

}

struct RecordView_Previews: PreviewProvider {


	static var url:URL =  Bundle.main.url(forResource: "test2", withExtension: "wav")!

    static var previews: some View {
		RecordView(fileURL: url, recordText:TextFieldData())
    }
}


