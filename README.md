# Custom Barcode Scanner & Drawing View - SwiftUI

Bu proje, özelleştirilmiş bir barkod okuma ve çizim ekranı deneyimi sunar. Aşağıda kullanılan view'lar, parametre açıklamaları ve örnek kullanım detaylandırılmıştır.

## 📦 Özellikler

- ✅ Özelleştirilmiş barkod okuma sistemi (`ScannerView`)
- ✍️ Çizim yapma özelliği (`DrawingPageView`)
- 📊 Durum bazlı barkod yönetimi (okundu, okunuyor vs.)
- 📃 Kod üstü açıklamalarla kullanım kolaylığı

---

## 🔍 `ScannerView`


### Kullanım

| Parametre     | Tip               | Açıklama |
|---------------|-------------------|----------|
| `isScanning`  | `Binding<Bool>`    | Kameranın açık/kapalı durumu (`true` = açık) |
| `isReadText`  | `Binding<Bool>`    | Barkod yazılarak okutulacak mı? |
| `barcodeList` | `Binding<[AnyBarcodeScannable]>` | Barkod listesi için, `barcode` ve `statusId` içeren dönüşüm |
| `isRead`      | `(Int) -> Bool`    | Barkodun "okundu" olduğunu belirten durum filtresi. Örnek: `{ $0 == 2 }` |
| `isReading`   | `(Int) -> Bool`    | Barkodun "okunuyor" olduğunu belirten filtre. Örnek: `{ $0 == 1 }` |

```swift
ScannerView(
    isScanning: $isScanning,
    isReadText: $isReadText,
    barcodeList: Binding(
        get: { barcodeList.map { AnyBarcodeScannable($0) } },
        set: { _ in } // Optional: Güncelleme gerekirse burada handle edilir
    ),
    isRead: { $0 == 2 },
    isReading: { $0 == 1 }
) { code in
    if lastReadBarcode != code {
        // Listede olan barkod okunma işlemleri + API çağrısı
    } else {
        // Listede olmayan barkod okunması işlemleri
    }
}
```

## 🔍 `DrawingPageView`

```swift
DrawingPageView(isDrawingPage: .constant(true)) { image in
    // Kullanıcı çizim yaptıktan sonra dönen `UIImage`
}
```

| Parametre     | Tip               | Açıklama |
|---------------|-------------------|----------|
| `isDrawingPage`  | `Binding<Bool>`    | Dialog açık kapalı |
