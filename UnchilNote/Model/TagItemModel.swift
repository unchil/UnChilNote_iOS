//
//  TagItemModel.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/06.
//

import Foundation

enum Tag: Int {
	case travel
	case shopping
	case tracking

	var name: String {
		switch self {
		case .travel :   return "여행"
		case .shopping: return "쇼핑"
		case .tracking: return "트레킹"
		}
	}

	var systemImage: String {
		switch self {
		case .travel :   return "airplane.departure"
		case .shopping: return "cart"
		case .tracking: return "figure.walk"
		}
	}
}

struct TagItem: Identifiable {
	var id: String = UUID().uuidString
	var tag:Tag
	var isSelected:Bool 
}

@resultBuilder
enum TagItemsBuilder {
	static func buildBlock(_ components: [TagItem]...) -> [TagItem] {
		return components.flatMap { $0 }
	}
    static func buildExpression(_ expression: TagItem) -> [TagItem] {
        return [expression]
    }
    static func buildExpression(_ expression: ()) -> [TagItem] {
        return []
    }
}

extension TagItem {

	@TagItemsBuilder
	static func all() -> [TagItem] {
		TagItem(tag: .travel, isSelected: false)
		TagItem(tag: .shopping, isSelected: false)
		TagItem(tag: .tracking, isSelected: false)
	}


	@TagItemsBuilder
	static func searchAll() -> [TagItem] {
		TagItem(tag: .travel, isSelected: true)
		TagItem(tag: .shopping, isSelected: true)
		TagItem(tag: .tracking, isSelected: true)
	}

	static let tags: [TagItem] = [ TagItem(tag: Tag.travel, isSelected: false), TagItem(tag: Tag.shopping, isSelected: false), TagItem(tag: Tag.tracking, isSelected: false)]

}
