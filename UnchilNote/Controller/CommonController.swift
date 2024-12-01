//
//  CommonController.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/07.
//

import Foundation

struct CommonController {


	static func deleteFile(fileName:String) {
		let fileURL = ConstVar.DocumentPath.appendingPathComponent(fileName)
		if FileManager.default.fileExists(atPath: fileURL.path) {
			do {
				try FileManager.default.removeItem(at: fileURL)
			} catch let error as NSError{
				print(#function, error)
			}
		}
	}

}
