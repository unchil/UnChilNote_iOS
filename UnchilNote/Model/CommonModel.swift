//
//  CommonModel.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation
import SwiftUI

enum SessionStatus {
	case success(title:String, message: String, buttonTitle: String)
	case notAuthorized(title:String, message: String, buttonTitle: String)
	case configurationFailed(title:String, message: String, buttonTitle: String)
}

struct AlertError {
	var title: String = ""
	var message: String = ""
	var primaryButtonTitle: String = ""
	var secondaryButtonTitle: String? = nil
	var primaryAction: (()->())? = nil
	var secondaryAction: (()->())? = nil
}

enum MapType: String, CaseIterable, Identifiable {
		 case normal, hybrid, terrain
		 var id: Self { self }
}

enum ImageViewMode:Int {
	case frame
	case full
}

enum CustomSwipeMode:Int {
	case previous
	case next
	case hold
}

enum ScaleEffectValue:CGFloat {
	case two = 1.2
	case four = 1.4
	case six = 1.6
	case pageViewIcon = 1.8
	case double = 2
	case doubleHalf = 2.5
	case triple = 3
}

enum WriteDataType: String, CaseIterable, Identifiable {
		 case snapshot, record, photo
		 var id: Self { self }

	var name: String {
		switch self {
		case .snapshot :   return "Snapshot"
		case .record: return "Record"
		case .photo: return "Photo"
		}
	}

	var systemImage: String {
		switch self {
		case .snapshot :   return "hand.draw.fill"
		case .record: return "mic.fill"
		case .photo: return "camera.fill"
		}
	}

	var deleteMessage: String {
		switch self {
			case .snapshot :   return "Are you sure you want to clear the snapshot file?"
			case .record: return "Are you sure you want to clear the record file?"
			case .photo: return "Are you sure you want to clear the photo file?"
		}
	}

	var deleteTitle: String {
		switch self {
			case .snapshot :   return "Delete Snapshot"
			case .record: return "Delete Record"
			case .photo: return "Delete Photo"
		}}

	var alertMessage: String {
	switch self {
		case .snapshot :   return "Default Snapshot cannot be deleted"
		case .record: return "Default Record cannot be deleted"
		case .photo: return "Default Photo cannot be deleted"
	}}
}


