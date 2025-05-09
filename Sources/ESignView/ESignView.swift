//
//  File.swift
//  BarcodeESignSpmKit
//
//  Created by Mustafa Alper Aydin on 29.04.2025.
//

import Foundation
import SwiftUI


public struct DrawingPageView: View {
    
    @Binding var isDrawingPage: Bool
    @State private var points: [CGPoint] = []
    @State private var canvasSize: CGSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 300)
    @State private var paths: [Path] = []
    @State private var signStrokeColor: Color = .black
    @State private var signStrokeWidth: CGFloat = 2.0
    @State private var isSigning: Bool = true
    
    var headerText: String
    var clearText: String
    var saveText: String
    var closeText: String
    var onSaveClick: (_ image: UIImage?) -> Void

    public init(
        isDrawingPage: Binding<Bool>,
        headerText: String = "İmza Oluştur",
        clearText: String = "Temizle",
        saveText: String = "Kaydet",
        closeText: String = "Kapat",
        onSaveClick: @escaping (_ image: UIImage?) -> Void
    ) {
        self._isDrawingPage = isDrawingPage
        self.headerText = headerText
        self.clearText = clearText
        self.saveText = saveText
        self.closeText = closeText
        self.onSaveClick = onSaveClick
    }
    
    public var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Button {
                        withAnimation {
                            points.removeAll()
                            isDrawingPage.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.white)
                            
                    }
                    Spacer()
                    Text(headerText)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Spacer()
                }.padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    .background(.blue.opacity(0.3))
                
                HStack {
                    HStack {
                        
                        Button {
                            signStrokeColor = .red
                        } label: {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(signStrokeColor == .red ? .red.opacity(0.3) : .red)
                        }.disabled(signStrokeColor == .red ? true : false)
                        Button {
                            signStrokeColor = .green
                        } label: {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(signStrokeColor == .green ? .green.opacity(0.3) : .green)
                        }.disabled(signStrokeColor == .green ? true : false)
                        Button {
                            signStrokeColor = .black
                        } label: {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(signStrokeColor == .black ? .black.opacity(0.3) : .black)
                        }.disabled(signStrokeColor == .black ? true : false)

                    }
                    Spacer()
                    HStack {
                        Button {
                            signStrokeWidth = 2.0
                        } label: {
                            Text("2.0")
                                .padding(.all, 3)
                                .background(.gray.opacity(0.2))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .cornerRadius(5)
                        }.disabled(signStrokeWidth == 2.0 ? true : false)
                        Button {
                            signStrokeWidth = 4.0
                        } label: {
                            Text("4.0")
                                .padding(.all, 3)
                                .background(.gray.opacity(0.2))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .cornerRadius(5)
                        }.disabled(signStrokeWidth == 4.0 ? true : false)
                        Button {
                            signStrokeWidth = 6.0
                        } label: {
                            Text("6.0")
                                .padding(.all, 3)
                                .background(.gray.opacity(0.2))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .cornerRadius(5)
                        }.disabled(signStrokeWidth == 6.0 ? true : false)

                    }
                }.padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    .background(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.black, lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
                    
                
                if isSigning {
                    DrawingCanvas(points: $points, canvasSize: $canvasSize, strokeColor: signStrokeColor, strokeWitdh: signStrokeWidth)
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1)
                        )
                        .padding(.horizontal, 5)
                                
                    HStack {
                        Button {
                            points.removeAll()
                        } label: {
                            Text(clearText)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(.yellow)
                                .cornerRadius(10)
                        }
                                        
                        Button {
                            withAnimation {
                                if let image = convertToImage(from: points, size: canvasSize, strokeColor: UIColor(signStrokeColor), lineWidth: signStrokeWidth) {
                                    onSaveClick(image)
                                } else {
                                    onSaveClick(nil) // Hata durumunda nil gönder
                                }
                            }
                        } label: {
                            Text(saveText)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(points == [] ? Color.blue.opacity(0.3) : Color.blue)
                                .cornerRadius(10)
                        }.disabled(points == [] ? true : false)
                                    
                    }.padding(.horizontal, 10)
                                    
                                    
                }
                                
                Button {
                    withAnimation {
                        points.removeAll()
                        isDrawingPage.toggle()
                    }
                } label: {
                    Text(closeText)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }.padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    
            }.frame(width: UIScreen.main.bounds.width * 0.9)
            .cornerRadius(7)
                .background(Color.white
                    .cornerRadius(7))
                .padding(.horizontal, 5)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.gray
                    .ignoresSafeArea()
                    .opacity(0.9)
                    .onTapGesture {
                        withAnimation{
                            //isOrderDetailError = false
                        }
                    }
            )
        
    }
    
    func convertToImage(from points: [CGPoint], size: CGSize, strokeColor: UIColor, lineWidth: CGFloat) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            
            for (index, point) in points.enumerated() {
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            
            strokeColor.setStroke()
            path.stroke()
        }
    }

}


struct DrawingPageView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPageView(isDrawingPage: .constant(false)) { image in
            //
        }
    }
}

struct DrawingCanvas: View {
    
    @Binding var points: [CGPoint]
    
    @Binding var canvasSize: CGSize
    
    var strokeColor: Color
    var strokeWitdh: CGFloat
    
    @State private var currentPoint = CGPoint()
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for (index, point) in points.enumerated() {
                            
                    let x = min(max(point.x, 0), canvasSize.width)
                    let y = min(max(point.y, 0), canvasSize.height)
                            
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(strokeColor, lineWidth: strokeWitdh)
            .background(Color.white)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let currentPoint = value.location
                    points.append(currentPoint)
                }
                .onEnded { _ in
                    // Do any cleanup or finalization if needed
                }
            )
        }
    }
}
