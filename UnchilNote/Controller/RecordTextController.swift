//
//  RecordTextController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/16.
//

import Foundation


class TextFieldData:ObservableObject {
	@Published var data:String

	init(data:String = ""){
		self.data = data
	}
}
