//
//  PrefrencesItem.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/08.
//

import Foundation

enum Prefrences: Int {
	case secret
	case pin

	var name: String {
		switch self {
		case .secret :   return "보안 설정"
		case .pin: return "위치 등록"
		}
	}

	var systemImage: String {
		switch self {
		case .secret :   return "lock"
		case .pin: return "mappin.and.ellipse"
		}
	}
}

class PrefrencesItem: ObservableObject, Identifiable {
	var id: String = UUID().uuidString
	@Published var prefrences: Prefrences
	@Published var isSelected: Bool

	init(prefrences:Prefrences, isSelected: Bool) {
		self.prefrences = prefrences
		self.isSelected = isSelected
	}
}

extension PrefrencesItem {
	@PrefrencesItemsBuilder
	static func all() -> [PrefrencesItem] {
		PrefrencesItem(prefrences: Prefrences.secret, isSelected: false)
		PrefrencesItem(prefrences: Prefrences.pin, isSelected: false)
	}
}

@resultBuilder
enum PrefrencesItemsBuilder {
	static func buildBlock(_ components: [PrefrencesItem]...) -> [PrefrencesItem] {
		return components.flatMap { $0 }
	}
    static func buildExpression(_ expression: PrefrencesItem) -> [PrefrencesItem] {
        return [expression]
    }
    static func buildExpression(_ expression: ()) -> [PrefrencesItem] {
        return []
    }
}


