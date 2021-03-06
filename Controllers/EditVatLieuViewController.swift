//
//  EditVatLieuViewController.swift
//  Quan Ly Ban Hang Vat Lieu Xay
//
//  Created by MacOS on 5/30/21.
//  Copyright © 2021 DoAnIOS. All rights reserved.
//

import UIKit

class EditVatLieuViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, PickerDelegate {
    
    //Anh xa view
    @IBOutlet weak var imageVatLieu: UIImageView!
    @IBOutlet weak var tfTen: CustomTextField!
    @IBOutlet weak var tvThongTin: CustomTextView!
    @IBOutlet weak var tfSoLuong: CustomTextField!
    @IBOutlet weak var tfDonGia: CustomTextField!
    @IBOutlet weak var pkDVT: UIPickerView!
    @IBOutlet weak var pkNCC: UIPickerView!
    
    var nhaCungCap = ""
    var donViTinh = ""
    var id = "KCTRLyk232erHOgcYFIl"
    
    //Set data cho picker view
    private let dataDVT = DataPickerDVT()
    private let dataNCC = DataPickerNCC()
    
    var arrNCC = [NhaCungCap]()
    var arrDVT = [
        "Lit",
        "KG",
        "Met"
    ]
    
    func setDataPicker() {
        let db = DBNhaCungCap()
        
        //Set data source
        pkNCC.dataSource = dataNCC.self
        pkDVT.dataSource = dataDVT.self
        
        //set delegate
        pkNCC.delegate = dataNCC.self
        pkDVT.delegate = dataDVT.self
        
        //set protocol
        dataDVT.picker = self
        dataNCC.picker = self
        
        let dispatch = DispatchGroup()
        
        dispatch.enter()
        //Set data cho ncc
        if arrNCC.count == 0 {
            db.getAll { (arr) in
                if let arr = arr {
                    self.dataNCC.arrNhaCungCap = arr
                    self.arrNCC = arr
                    DispatchQueue.main.async {
                        self.pkNCC.reloadAllComponents()
                        dispatch.leave()
                    }
                }
                
            }
        }
        
        dispatch.enter()
        //set data cho dvt
        self.dataDVT.arr = arrDVT
        DispatchQueue.main.async {
            self.pkDVT.reloadAllComponents()
            dispatch.leave()
        }
        
        dispatch.notify(queue: .main) {
            self.loadData()
        }
    }
    
    //Set su kien cua image view
    func setImageView() {
        //Tao gesture
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(actionImageClick(_:)))
        
        //set image click
        imageVatLieu.isUserInteractionEnabled = true
        imageVatLieu.addGestureRecognizer(gesture)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageVatLieu.image = selectedImage
            dismiss(animated: true, completion: nil)
        }
    }
    
    //Ham su kien cua image view qua gesture
    @objc func actionImageClick(_ sender: UITapGestureRecognizer) {
        //Tao ra Image picker
        print("sda")
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        
        //set image delegate
        imagePicker.delegate = self
        
        //Chay view controller
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    //Potocol
    func select(index: Int, picker: Picker) {
        switch picker {
        case .DVT:
            donViTinh = arrDVT[index]
            print(arrDVT[index])
        case .NCC:
            nhaCungCap = arrNCC[index].ten
            print(arrNCC[index].ten)
        }
        
        
    }
    
    //Bien can tao
    var arrNhaCungCap = [NhaCungCap]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading(title: "Đang tai dữ liệu.")
        setDataPicker()
        setImageView()
    }
    
    func loadData() {
        let db = DBVatLieu()
        if self.id != "" {
            db.getVatLieuID(id: id) { (vatLieu) in
                if let vl = vatLieu {
                    self.tfTen.text = vl.ten
                    self.tfDonGia.text = String(vl.donGia)
                    self.tfSoLuong.text = String(vl.soLuong)
                    self.tvThongTin.text = vl.thongTin
                    self.imageVatLieu.loadImage(url: vl.hinh)
                    self.nhaCungCap = vl.nhaCungCap
                    self.donViTinh = vl.donViTinh
                    self.pkDVT.selectRow(self.arrDVT.firstIndex(of: vl.donViTinh) ?? 0, inComponent: 0, animated: true)
                    
                    var checkChanger = true
                    
                    for (i, value) in self.arrNCC.enumerated() {
                        if value.ten == vl.nhaCungCap {
                            self.pkNCC.selectRow(i, inComponent: 0, animated: true)
                            checkChanger = false
                        }
                    }
                    
                    if checkChanger { self.pkNCC.selectRow(0, inComponent: 0, animated: true) }
                    self.hideLoading()
                }
            }
        }
    }
    
    @IBAction func btnSua(_ sender: Any) {
        
        let db = DBVatLieu()
        if let data = getVatLieu() {
            showLoading(title: "Đợi xíu đi đừng vội...")
            data.id = id
            db.uploadImage(image: imageVatLieu.image!, name: data.ten + ".jpg") {
                url in
                if let url = url {
                    data.hinh = url
                    db.editVatLieu(vl: data) { (error) in
                        if error == nil {
                            self.showAlert(title: "Thành công", message: "sửa vật liệu thành công"){
                                _ in
                                self.navigationController?.popViewController(animated: true)
                                self.hideLoading()
                            }
                        }else {
                            self.showAlert(title: "Lôi sửa vật liệu", message: "sửa vật liệu không thành công"){
                                _ in
                                self.hideLoading()
                            }
                        }
                    }
                }else {
                    self.showAlert(title: "Lỗi up ảnh", message: "sửa vật liệu thất bại"){
                        _ in
                        self.hideLoading()
                    }
                }
            }
        }
    }
    
    private class DataPickerNCC: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate {
        var picker: PickerDelegate?
        var arrNhaCungCap = [NhaCungCap]()
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.arrNhaCungCap.count
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            picker?.select(index: row, picker: .NCC)
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.arrNhaCungCap[row].ten
        }
    }
    
    private class DataPickerDVT: UIViewController ,UIPickerViewDataSource, UIPickerViewDelegate {
        var picker: PickerDelegate?
        var arr = [String]()
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.arr.count
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            picker?.select(index: row, picker: .DVT)
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.arr[row]
        }
    }
    
    //Get data
    func getVatLieu() -> VatLieu? {
        if tfTen.text == "" || tvThongTin.text == "" || tfSoLuong.text == "" || tfDonGia.text == "" || nhaCungCap == "" || donViTinh == "" {
            showAlert(title: "Chú ý", message: "Chưa nhập đầy đủ thông tin", action: nil)
            return nil
        }
        
        if !tfSoLuong.text!.isValidSDT() || !tfDonGia.text!.isValidSDT() {
            showAlert(title: "Chú ý", message: "Đơn giá hoặc số lượng sai", action: nil)
            return nil
        }
        
        if imageVatLieu.image!.isEqual(UIImage(named: "Image")){
            showAlert(title: "Chú ý", message: "Bạn chưa chọn hình", action: nil)
            return nil
        }
        
        return VatLieu(id: "", hinh: "", ten: tfTen.text!, thongTin: tvThongTin.text!, soLuong: Int(tfSoLuong.text!) ?? 0, donViTinh: donViTinh, donGia: Double(tfDonGia.text!) ?? 0, nhaCungCap: nhaCungCap)
    }
    
    
    var viewLoading: UIView?
    var lable: UILabel?
    func showLoading(title: String) {
        if let viewLoading = viewLoading, let lable = lable {
            lable.text = title
            viewLoading.isHidden = false
        } else {
            viewLoading = UIView()
            viewLoading!.frame = view.frame
            viewLoading!.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.5)
            
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            
            lable = UILabel()
            lable!.frame = CGRect(x: (width * 0.2) / 2, y: (height * 0.9) / 2, width: width * 0.8, height: height * 0.1)
            lable!.text = title
            lable!.textAlignment = .center
            lable!.textColor = .white
            lable!.font = UIFont.boldSystemFont(ofSize: 20.0)
            
            viewLoading?.addSubview(lable!)
            view.addSubview(viewLoading!)
        }
    }
    
    func hideLoading() {
        if let viewLoading = viewLoading {
            viewLoading.isHidden = true
        }
    }
    
    //hien thi thong bao
    func showAlert(title: String, message: String, action: ((UIAlertAction)->())?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) {
            ac in
            action?(ac)
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIImageView {
    func loadImage(url: String) {
        self.image = UIImage(named: "Loading")
        if let ul = URL(string: url){
            URLSession.shared.dataTask(with: ul) { (data, repon, error) in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.image = UIImage(named: "Image")
                    }
                }
                }.resume()
        } else {
            self.image = UIImage(named: "Loi")
        }
    }
}
