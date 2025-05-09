//
//  SwiftUIView.swift
//  BarcodeESignSpmKit
//
//  Created by Mustafa Alper Aydin on 9.05.2025.
//

import SwiftUI

public struct StartRouteModel: Codable {
    public var Id: Int = -1
    public var Title: String = ""
    public var Value: StartRouteModelValue = .zero
    
    public init() { }
    
    public init(Id: Int, Title: String, Value: StartRouteModelValue) {
        self.Id = Id
        self.Title = Title
        self.Value = Value
    }
    
}

public enum StartRouteModelValue: Int, Codable {
    case zero = 0
    case uygun = 1
    case uygunDegil = 2
    case kapsamDisi = 3
}


struct StartRouteDialogView: View {
    
    @State var array: [StartRouteModel]
    @State var image: UIImage?
    @Binding var isPresented: Bool
    var plate: String
    var headerImage: Image
    let onSave: ((String, UIImage?) -> Void)?
        
    @State private var showSheet: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
        
    public init(array: [StartRouteModel],
                image: UIImage? = nil,
                isPresented: Binding<Bool>,
                plate: String,
                headerImage: Image = Image(systemName: "xmark.circle"),
                onSave: ((String, UIImage?) -> Void)? = nil) {
        self.array = array
        self.image = image
        self._isPresented = isPresented
        self.plate = plate
        self.headerImage = headerImage
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack{
            VStack(spacing: 10) {
                HStack{
                    Spacer()
                    Text("Sefer Başlatma Formu")
                        .font(.custom("fontsMedium", size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    headerImage
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text("Başlamadan Önce İyi Düşün")
                        .font(.custom("fontsRegular", size: 12))
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                VStack {
                    
                    HStack(spacing: 0) {
                        
                        StartRouteDialogBigText(type: 0, text: "\(plate)")
                        
                        Text("")
                            .font(.custom("fontsRegular", size: 12))
                            .frame(maxWidth: .infinity)
                            .frame(height: 25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            StartRouteDialogBigText(type: 1, text: "KONTROL")
                            StartRouteDialogSmallText(type: 1, text: "UYGUN")
                            StartRouteDialogSmallText(type: 1, text: "UYGUN DEĞİL")
                            StartRouteDialogSmallText(type: 1, text: "KAPSAM DIŞI")
                        }
                        
                        HStack(spacing: 0) {
                            
                            StartRouteDialogBigText(type: 2, text: "HEPSİ")
                            StartRouteDialogAllCheckmarkButton(array: $array, checkmarkType: .uygun, color: .green)
                            StartRouteDialogAllCheckmarkButton(array: $array, checkmarkType: .uygunDegil, color: .red)
                            StartRouteDialogAllCheckmarkButton(array: $array, checkmarkType: .kapsamDisi, color: .green)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(0..<array.count, id:\.self) { i in
                                    HStack(spacing: 0) {
                                        StartRouteDialogBigText(type: 0, text: array[i].Title)
                                        
                                        StartRouteCheckmarkButton(value: $array[i].Value, checkmarkType: .uygun, color: .green)
                                        StartRouteCheckmarkButton(value: $array[i].Value, checkmarkType: .uygunDegil, color: .red)
                                        StartRouteCheckmarkButton(value: $array[i].Value, checkmarkType: .kapsamDisi, color: .green)
                                    }
                                }
                            }
                            
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                            
                            Text("Fotoğraf Ekle")
                                .font(.custom("fontsRegular", size: 15))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 0) {
                                Button {
                                    self.showSheet = true
                                } label: {
                                    if image == nil{
                                        HStack(spacing: 0) {
                                            
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                            
                                        }
                                    }else{
                                        if let selectedImage = image {
                                            HStack {
                                                Image(uiImage: selectedImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 25, height: 25)
                                            }.onTapGesture {
                                                self.showSheet = true
                                                /*mainPageVM.imageText = selectedImage.toJpegString(compressionQuality: imageCompression) ?? ""
                                                mainPageVM.showImageDialog = true */
                                            }
                                            
                                        }else{
                                            HStack(spacing: 0) {
                                                
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 25, height: 25)
                                                
                                            }
                                        }
                                    }
                                    
                                }.actionSheet(isPresented: $showSheet){
                                    ActionSheet(title: Text("fotografSec"), message: Text("secenekler"), buttons: [
                                        .default(Text("Kütüphane")){
                                            self.showImagePicker = true
                                            self.sourceType = .photoLibrary
                                        },
                                        .default(Text("Kamera")){
                                            self.showImagePicker = true
                                            self.sourceType = .camera
                                        },
                                        .default(Text("Sil")){
                                            image = nil
                                        },
                                        .cancel(Text("İptal"))]
                                    )}
                                Spacer()
                            }.frame(width: 70)
                        }.padding(.vertical, 3)
                            .padding(.horizontal, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        Text("Sizin veya çevrenizin güvenliğini tehlikeye atabilecek bir durum tespiti halinde sürüç yapmaktan kaçının ve yetkili amirinize bilgi veriniz.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.custom("fontsMedium", size: 8))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    
                    HStack {
                        StartRouteDialogTotalCount(type: 0, color: .black, text: "\(countValue(.zero)) Boş")
                        
                        StartRouteDialogTotalCount(type: 1, color: .green, text: "\(countValue(.uygun) + countValue(.kapsamDisi)) Uygun")
                        
                        StartRouteDialogTotalCount(type: 1, color: .red, text: "\(countValue(.uygunDegil)) Uygun Değil")
                    }
                    
                }
                
                
                Button(action: {
                    
                    var excStr = ""
                    excStr = excStr + getStringStartForm()
                    if let newImage = image, let imageStr = newImage.toJpegString(compressionQuality: imageCompression) {
                        excStr = excStr + "##IMG##" + imageStr
                    }
                    onSave?(excStr, image)
                    
                    /*if checkArrayValues() == 1 || checkArrayValues() == 2 {
                        print("Hepsi başarılı apiye git")
                        mainPageVM.sendRouteRating(routeSequence: -1, easierOperation: -1, performance: -1, explanation: excStr)
                        if checkArrayValues() == 2 {
                            mainPageVM.executionV1MultiBody(executionType: LucyStatus.noNameStatus1, executionStr: "Sefer Başlatıldı - IOS") { result in
                                mainPageVM.isStartRouteDialog = false
                            }
                        }
                    } */

                }){
                    Text("Kaydet ve Sefer Başlat")
                        .font(.custom("fontsMedium", size: 15))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(.blue.opacity(0.5))
                        .cornerRadius(10)
                        //.modifier(RoundedEdge(width: 1, color: Color.MyColor.aboutUsContactBackgorund, cornerRadius: 8))
                        
                }.padding(.horizontal, 50)
                    .padding(.vertical, 20)
                    //.disabled(buttonControll())
                
            }.padding(10)
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 3))
                .cornerRadius(20)
                .padding(.horizontal, 20)
            
            
        }.sheet(isPresented: $showImagePicker){
            ImagePickerView(image: $image, isShown: self.$showImagePicker, sourceType: self.sourceType)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .background(
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation{
                            //mainPageVM.isStartRouteDialog = false
                        }
                    }
            )
            //.customAppearAnimation2()
    }
    
    /*
    func buttonControll() -> Bool {
        
        var filterArray = array.filter { $0.Value == 0 }
        
        if filterArray.count > 0 {
            return true //disable
        } else {
            return false //disable değil
        }
    }
     */
    
    func getStringStartForm() -> String {
        var stringSending = ""
        
        array.forEach { control in
            let valueString = String(describing: control.Value.rawValue)
            stringSending += "\(control.Id)|\(valueString)#"
        }
        
        print("stringSending - \(stringSending)")
        return stringSending
    }
    
    func countValue(_ value: StartRouteModelValue) -> Int {
        return array.filter { $0.Value == value }.count
    }
    
    private func checkArrayValues() -> Int {
        if array.contains(where: { $0.Value == .zero }) {
            //mainPageVM.showToast(message: "Lütfen tüm kontrollerin tamamlayınız. \(countValue(.zero)) adet tamamlanmamış kontrolünüz mevcut.")
            return 0
        }
            
        if array.contains(where: { $0.Value == .uygunDegil }) {
            //mainPageVM.errorDialogCallFunc(response: ResponseResult(data: [], isError: true, errorText: "Uygun değil statüsünde kontrolleriniz mevcut. Uygulamamız test sürecinde olduğu için sefer başlatabilirsiniz.", errorCode: -9876, errorType: ErrorTypes.WARNING))
            return 1
        }
        
        return 2
    }
}

#Preview {
    StartRouteDialogView(array: [StartRouteModel(Id: 1, Title: NSLocalizedString("kontrol1", comment: ""), Value: .zero), StartRouteModel(Id: 2, Title: NSLocalizedString("kontrol2", comment: ""), Value: .zero), StartRouteModel(Id: 3, Title: NSLocalizedString("kontrol3", comment: ""), Value: .zero), StartRouteModel(Id: 4, Title: NSLocalizedString("kontrol4", comment: ""), Value: .zero), StartRouteModel(Id: 5, Title: NSLocalizedString("kontrol5", comment: ""), Value: .zero), StartRouteModel(Id: 6, Title: NSLocalizedString("kontrol6", comment: ""), Value: .zero), StartRouteModel(Id: 7, Title: NSLocalizedString("kontrol7", comment: ""), Value: .zero), StartRouteModel(Id: 8, Title: NSLocalizedString("kontrol8", comment: ""), Value: .zero), StartRouteModel(Id: 9, Title: NSLocalizedString("kontrol9", comment: ""), Value: .zero), StartRouteModel(Id: 10, Title: NSLocalizedString("kontrol10", comment: ""), Value: .zero), StartRouteModel(Id: 11, Title: NSLocalizedString("kontrol11", comment: ""), Value: .zero), StartRouteModel(Id: 12, Title: NSLocalizedString("kontrol12", comment: ""), Value: .zero), StartRouteModel(Id: 13, Title: NSLocalizedString("kontrol13", comment: ""), Value: .zero), StartRouteModel(Id: 14, Title: NSLocalizedString("kontrol14", comment: ""), Value: .zero), StartRouteModel(Id: 15, Title: NSLocalizedString("kontrol15", comment: ""), Value: .zero), StartRouteModel(Id: 16, Title: NSLocalizedString("kontrol16", comment: ""), Value: .zero), StartRouteModel(Id: 17, Title: NSLocalizedString("kontrol17", comment: ""), Value: .zero), StartRouteModel(Id: 18, Title: NSLocalizedString("kontrol18", comment: ""), Value: .zero), StartRouteModel(Id: 19, Title: NSLocalizedString("kontrol19", comment: ""), Value: .zero), StartRouteModel(Id: 20, Title: NSLocalizedString("kontrol20", comment: ""), Value: .zero), StartRouteModel(Id: 21, Title: NSLocalizedString("kontrol21", comment: ""), Value: .zero), StartRouteModel(Id: 22, Title: NSLocalizedString("kontrol22", comment: ""), Value: .zero), StartRouteModel(Id: 23, Title: NSLocalizedString("kontrol23", comment: ""), Value: .zero), StartRouteModel(Id: 24, Title: NSLocalizedString("kontrol24", comment: ""), Value: .zero), StartRouteModel(Id: 25, Title: NSLocalizedString("kontrol25", comment: ""), Value: .zero), StartRouteModel(Id: 26, Title: NSLocalizedString("kontrol26", comment: ""), Value: .zero), StartRouteModel(Id: 27, Title: NSLocalizedString("kontrol27", comment: ""), Value: .zero), StartRouteModel(Id: 28, Title: NSLocalizedString("kontrol28", comment: ""), Value: .zero), StartRouteModel(Id: 29, Title: NSLocalizedString("kontrol29", comment: ""), Value: .zero), StartRouteModel(Id: 30, Title: NSLocalizedString("kontrol30", comment: ""), Value: .zero), StartRouteModel(Id: 31, Title: NSLocalizedString("kontrol31", comment: ""), Value: .zero), StartRouteModel(Id: 32, Title: NSLocalizedString("kontrol32", comment: ""), Value: .zero), StartRouteModel(Id: 33, Title: NSLocalizedString("kontrol33", comment: ""), Value: .zero), StartRouteModel(Id: 34, Title: NSLocalizedString("kontrol34", comment: ""), Value: .zero), StartRouteModel(Id: 35, Title: NSLocalizedString("kontrol35", comment: ""), Value: .zero), StartRouteModel(Id: 36, Title: NSLocalizedString("kontrol36", comment: ""), Value: .zero), StartRouteModel(Id: 37, Title: NSLocalizedString("kontrol37", comment: ""), Value: .zero), StartRouteModel(Id: 38, Title: NSLocalizedString("kontrol38", comment: ""), Value: .zero), StartRouteModel(Id: 39, Title: NSLocalizedString("kontrol39", comment: ""), Value: .zero), StartRouteModel(Id: 40, Title: NSLocalizedString("kontrol40", comment: ""), Value: .zero)], isPresented: .constant(false), plate: "PLAKA")
}

struct StartRouteCheckmarkButton: View {
    @Binding var value: StartRouteModelValue
    let checkmarkType: StartRouteModelValue
    let color: Color

    var body: some View {
        Button {
            if value == checkmarkType {
                value = .zero
            } else {
                value = checkmarkType
            }
        } label: {
            Image(systemName: value == checkmarkType ? "checkmark.square.fill" : "square")
                .foregroundColor(value == checkmarkType ? color : .black)
                //.frame(maxWidth: UIScreen.main.bounds.width * 0.17)
                .frame(maxWidth: .infinity)
                .frame(height: 25)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(Color.black, lineWidth: 0.5)
                )
        }
    }
}

struct StartRouteDialogAllCheckmarkButton: View {
    @Binding var array: [StartRouteModel]
    let checkmarkType: StartRouteModelValue
    let color: Color

    var body: some View {
        Button {
            toggleAllValues()
        } label: {
            Image(systemName: allValuesEqual(to: checkmarkType) ? "checkmark.square.fill" : "square")
                .foregroundColor(allValuesEqual(to: checkmarkType) ? color : .black)
                //.frame(maxWidth: UIScreen.main.bounds.width * 0.17)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(.blue.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(Color.black, lineWidth: 0.5)
                )
        }
    }
    
    private func allValuesEqual(to value: StartRouteModelValue) -> Bool {
        // Tüm array elemanlarının belirtilen `value` ile eşit olup olmadığını kontrol eder
        return array.allSatisfy { $0.Value == value }
    }
    
    private func toggleAllValues() {
        if allValuesEqual(to: checkmarkType) {
            // Eğer tüm elemanlar aynıysa, hepsini `zero` yapar
            array = array.map { model in
                var model = model
                model.Value = .zero
                return model
            }
        } else {
            // Aksi takdirde, hepsini `checkmarkType` yapar
            array = array.map { model in
                var model = model
                model.Value = checkmarkType
                return model
            }
        }
    }
}

struct StartRouteDialogBigText: View {
    
    var type: Int
    var text: String

    var body: some View {
        Text(text)
            .font(.custom("fontsRegular", size: type == 0 ? 8 : 10))
            .foregroundStyle(type == 0 ? .black : .white)
            .frame(width: UIScreen.main.bounds.width * 0.4, alignment: type == 0 ? .leading : .center)
            .frame(height: type == 0 ? 25 : 30)
            //.multilineTextAlignment(type == 0 ? .leading : .center)
            .padding(.horizontal, 3)
            .background(type == 1 ? .blue : type == 2 ? .blue.opacity(0.5) : .white)
            
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
}

struct StartRouteDialogSmallText: View {
    
    var type: Int
    var text: String

    var body: some View {
        Text(text)
            .font(.custom("fontsRegular", size: type == 0 ? 8 : 10))
            .foregroundStyle(type == 0 ? .black : .white)
            //.frame(maxWidth: UIScreen.main.bounds.width * 0.17)
            .frame(maxWidth: .infinity)
            .frame(height: type == 0 ? 25 : 30)
            .multilineTextAlignment(.center)
            .background(type == 1 ? .blue : type == 2 ? .blue.opacity(0.5) : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
}

struct StartRouteDialogTotalCount: View {
    
    var type: Int
    var color: Color
    var text: String

    var body: some View {
        HStack {
            Image(systemName: type == 0 ? "circle" : "circle.fill")
                .resizable()
                .foregroundStyle(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .font(.custom("fontsRegular", size: 8))
                .foregroundStyle(.black)
        }.frame(width: UIScreen.main.bounds.width * 0.3)
    }
}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    
    init(image: Binding<UIImage?>, isShown: Binding<Bool>){
        _image = image
        _isShown = isShown
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = uiImage
            isShown = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerViewCoordinator
    
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    var sourceType: UIImagePickerController.SourceType
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
        
    }
    
    func makeCoordinator() -> ImagePickerView.Coordinator {
        return ImagePickerViewCoordinator(image: $image, isShown: $isShown)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
}
