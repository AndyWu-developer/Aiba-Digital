//
//  CellVIewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import Foundation

class MediaCellViewModel: Hashable, Identifiable {
    
    static func == (lhs: MediaCellViewModel, rhs: MediaCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//protocol DiffableMediaCellViewModel: Hashable, Identifiable where Self: AnyObject{
//    
//}
//
//extension DiffableMediaCellViewModel {
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
