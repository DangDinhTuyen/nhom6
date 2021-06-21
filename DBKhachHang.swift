//
//  DBKhachHang.swift
//  Quan Ly Ban Hang Vat Lieu Xay
//
//  Created by MacOS on 5/29/21.
//  Copyright © 2021 DoAnIOS. All rights reserved.
//

import Firebase

class DBKhachHang {
    var db = Firestore.firestore().collection("KhachHang")
    
    func addKhachHang(kh: KhachHang, completion: @escaping (Error?)->()) {
        let id = db.document().documentID
        kh.id = id
        
        db.document(id).setData(kh.getData()){
            error in
            completion(error)
        }
    }
    
    func delKhachHang(id: String, completion: @escaping (Error?)->()) {
        db.document(id).delete(){
            error in
            completion(error)
        }
    }
    
    func editKhachHang(kh: KhachHang, completion: @escaping (Error?)->()) {
        db.document(kh.id).setData(kh.getData()){
            error in
            completion(error)
        }
    }
    
    func getKhachHang(completion: @escaping ([KhachHang]?)->()) {
        db.getDocuments { (snap, error) in
            if let snap = snap?.documents, error == nil {
                var arr = [KhachHang]()
                for item in snap {
                    arr.append(KhachHang(data: item.data()))
                }
                completion(arr)
            }
        }
    }
}
