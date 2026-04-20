import AppKit
import Foundation

struct Palette {
    static let navyA = NSColor(calibratedRed: 8/255, green: 20/255, blue: 44/255, alpha: 1)
    static let navyB = NSColor(calibratedRed: 15/255, green: 45/255, blue: 78/255, alpha: 1)
    static let navyC = NSColor(calibratedRed: 5/255, green: 89/255, blue: 92/255, alpha: 1)
    static let goldA = NSColor(calibratedRed: 247/255, green: 216/255, blue: 126/255, alpha: 1)
    static let goldB = NSColor(calibratedRed: 201/255, green: 153/255, blue: 62/255, alpha: 1)
    static let goldSoft = NSColor(calibratedRed: 1, green: 233/255, blue: 178/255, alpha: 0.24)
    static let mist = NSColor(calibratedRed: 229/255, green: 244/255, blue: 244/255, alpha: 0.9)
    static let emeraldA = NSColor(calibratedRed: 90/255, green: 221/255, blue: 176/255, alpha: 1)
    static let emeraldB = NSColor(calibratedRed: 25/255, green: 166/255, blue: 127/255, alpha: 1)
}

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)

func ensureDir(_ url: URL) throws {
    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
}

func saveRep(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "icon-export", code: 1)
    }
    try png.write(to: url)
}

func drawGradientBackground(in rect: CGRect) {
    let gradient = NSGradient(colors: [Palette.navyA, Palette.navyB, Palette.navyC])!
    gradient.draw(in: NSBezierPath(rect: rect), angle: -48)

    let glowRect = CGRect(
        x: rect.minX + rect.width * 0.18,
        y: rect.minY + rect.height * 0.14,
        width: rect.width * 0.72,
        height: rect.height * 0.72
    )
    let glow = NSGradient(
        starting: Palette.goldSoft,
        ending: NSColor(calibratedWhite: 1, alpha: 0)
    )!
    glow.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)

    let vignette = NSGradient(
        starting: NSColor(calibratedWhite: 0, alpha: 0),
        ending: NSColor(calibratedWhite: 0, alpha: 0.22)
    )!
    vignette.draw(in: NSBezierPath(ovalIn: rect.insetBy(dx: -rect.width * 0.08, dy: -rect.height * 0.08)), relativeCenterPosition: .zero)
}

func circlePoint(center: CGPoint, radius: CGFloat, degrees: CGFloat) -> CGPoint {
    let radians = degrees * .pi / 180
    return CGPoint(x: center.x + cos(radians) * radius, y: center.y + sin(radians) * radius)
}

func strokeArc(
    center: CGPoint,
    radius: CGFloat,
    start: CGFloat,
    end: CGFloat,
    width: CGFloat,
    startColor: NSColor,
    endColor: NSColor,
    addArrow: Bool = false
) {
    let path = NSBezierPath()
    path.appendArc(
        withCenter: center,
        radius: radius,
        startAngle: start,
        endAngle: end,
        clockwise: false
    )
    path.lineWidth = width
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    let strokeColor = startColor.blended(withFraction: 0.55, of: endColor) ?? endColor
    strokeColor.setStroke()
    path.stroke()

    if addArrow {
        let tip = circlePoint(center: center, radius: radius, degrees: end)
        let tangentAngle = (end + 90) * .pi / 180
        let arrowLength = width * 1.1
        let spread: CGFloat = .pi / 7
        let left = CGPoint(
            x: tip.x - cos(tangentAngle - spread) * arrowLength,
            y: tip.y - sin(tangentAngle - spread) * arrowLength
        )
        let right = CGPoint(
            x: tip.x - cos(tangentAngle + spread) * arrowLength,
            y: tip.y - sin(tangentAngle + spread) * arrowLength
        )

        let arrow = NSBezierPath()
        arrow.move(to: tip)
        arrow.line(to: left)
        arrow.line(to: right)
        arrow.close()
        endColor.setFill()
        arrow.fill()
    }
}

func fillRoundedRect(_ rect: CGRect, radius: CGFloat, colors: [NSColor], angle: CGFloat) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    let gradient = NSGradient(colors: colors)!
    gradient.draw(in: path, angle: angle)
}

func drawShield(scale: CGFloat) {
    let shield = NSBezierPath()
    shield.move(to: CGPoint(x: 512 * scale, y: 750 * scale))
    shield.curve(
        to: CGPoint(x: 686 * scale, y: 650 * scale),
        controlPoint1: CGPoint(x: 596 * scale, y: 748 * scale),
        controlPoint2: CGPoint(x: 668 * scale, y: 710 * scale)
    )
    shield.line(to: CGPoint(x: 686 * scale, y: 456 * scale))
    shield.curve(
        to: CGPoint(x: 512 * scale, y: 272 * scale),
        controlPoint1: CGPoint(x: 686 * scale, y: 378 * scale),
        controlPoint2: CGPoint(x: 610 * scale, y: 304 * scale)
    )
    shield.curve(
        to: CGPoint(x: 338 * scale, y: 456 * scale),
        controlPoint1: CGPoint(x: 414 * scale, y: 304 * scale),
        controlPoint2: CGPoint(x: 338 * scale, y: 378 * scale)
    )
    shield.line(to: CGPoint(x: 338 * scale, y: 650 * scale))
    shield.curve(
        to: CGPoint(x: 512 * scale, y: 750 * scale),
        controlPoint1: CGPoint(x: 356 * scale, y: 710 * scale),
        controlPoint2: CGPoint(x: 428 * scale, y: 748 * scale)
    )
    shield.close()

    let shieldGradient = NSGradient(colors: [
        Palette.mist.withAlphaComponent(0.18),
        Palette.mist.withAlphaComponent(0.05)
    ])!
    shieldGradient.draw(in: shield, angle: -90)

    Palette.mist.withAlphaComponent(0.18).setStroke()
    shield.lineWidth = 10 * scale
    shield.stroke()
}

func drawOrbit(scale: CGFloat) {
    NSGraphicsContext.saveGraphicsState()
    strokeArc(
        center: CGPoint(x: 512 * scale, y: 512 * scale),
        radius: 326 * scale,
        start: 124,
        end: 396,
        width: 40 * scale,
        startColor: Palette.goldA,
        endColor: Palette.goldB,
        addArrow: true
    )
    NSGraphicsContext.restoreGraphicsState()
}

func drawGrowthMark(scale: CGFloat) {
    let baseY = 392 * scale
    let barWidth = 58 * scale
    fillRoundedRect(
        CGRect(x: 406 * scale, y: baseY, width: barWidth, height: 118 * scale),
        radius: 18 * scale,
        colors: [Palette.goldA, Palette.goldB],
        angle: -90
    )
    fillRoundedRect(
        CGRect(x: 483 * scale, y: baseY, width: barWidth, height: 168 * scale),
        radius: 18 * scale,
        colors: [Palette.goldA, Palette.goldB],
        angle: -90
    )
    fillRoundedRect(
        CGRect(x: 560 * scale, y: baseY, width: barWidth, height: 228 * scale),
        radius: 18 * scale,
        colors: [Palette.emeraldA, Palette.emeraldB],
        angle: -90
    )

    let path = NSBezierPath()
    path.move(to: CGPoint(x: 392 * scale, y: 426 * scale))
    path.line(to: CGPoint(x: 474 * scale, y: 510 * scale))
    path.line(to: CGPoint(x: 538 * scale, y: 494 * scale))
    path.line(to: CGPoint(x: 646 * scale, y: 628 * scale))
    path.lineWidth = 24 * scale
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    Palette.mist.setStroke()
    path.stroke()

    let tip = CGPoint(x: 646 * scale, y: 628 * scale)
    let left = CGPoint(x: 646 * scale - 66 * scale, y: 628 * scale - 12 * scale)
    let right = CGPoint(x: 646 * scale - 16 * scale, y: 628 * scale - 62 * scale)
    let arrow = NSBezierPath()
    arrow.move(to: tip)
    arrow.line(to: left)
    arrow.line(to: right)
    arrow.close()
    Palette.mist.setFill()
    arrow.fill()
}

func drawVMonogram(scale: CGFloat) {
    let v = NSBezierPath()
    v.move(to: CGPoint(x: 392 * scale, y: 706 * scale))
    v.line(to: CGPoint(x: 500 * scale, y: 482 * scale))
    v.line(to: CGPoint(x: 558 * scale, y: 594 * scale))
    v.line(to: CGPoint(x: 632 * scale, y: 430 * scale))
    v.lineWidth = 38 * scale
    v.lineCapStyle = .round
    v.lineJoinStyle = .round
    let gradient = NSGradient(colors: [Palette.goldA, Palette.goldB])!
    NSGraphicsContext.saveGraphicsState()
    v.setClip()
    gradient.draw(in: CGRect(x: 340 * scale, y: 410 * scale, width: 340 * scale, height: 320 * scale), angle: -82)
    NSGraphicsContext.restoreGraphicsState()
    Palette.goldA.withAlphaComponent(0.25).setStroke()
    v.stroke()
}

func drawForeground(canvas: CGFloat) {
    let baseScale = canvas / 1024
    let safeScale: CGFloat = 0.8
    NSGraphicsContext.saveGraphicsState()
    let transform = NSAffineTransform()
    transform.translateX(by: canvas * (1 - safeScale) / 2, yBy: canvas * (1 - safeScale) / 2)
    transform.scale(by: safeScale)
    transform.concat()
    let scale = baseScale
    drawOrbit(scale: scale)
    drawShield(scale: scale)
    drawGrowthMark(scale: scale)
    drawVMonogram(scale: scale)
    NSGraphicsContext.restoreGraphicsState()
}

func makeRep(size: CGFloat, includeBackground: Bool, includeForeground: Bool) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = context
    context.imageInterpolation = .high

    if includeBackground {
        drawGradientBackground(in: CGRect(x: 0, y: 0, width: size, height: size))
    }

    if includeForeground {
        drawForeground(canvas: size)
    }

    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func imageFromRep(_ rep: NSBitmapImageRep) -> NSImage {
    let image = NSImage(size: rep.size)
    image.addRepresentation(rep)
    return image
}

func resize(_ image: NSImage, to size: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size),
        pixelsHigh: Int(size),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func writeAndroidLegacy(baseImage: NSImage) throws {
    let outputs: [(String, CGFloat)] = [
        ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
        ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
        ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
        ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
        ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
        ("android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png", 48),
        ("android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png", 72),
        ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png", 96),
        ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png", 144),
        ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png", 192),
    ]

    for (path, size) in outputs {
        let url = root.appendingPathComponent(path)
        try ensureDir(url.deletingLastPathComponent())
        try saveRep(resize(baseImage, to: size), to: url)
    }
}

func writeIOS(baseImage: NSImage) throws {
    let outputs: [(String, CGFloat)] = [
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", 20),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", 40),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", 60),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", 29),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", 58),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", 87),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", 40),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", 80),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", 120),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@1x.png", 50),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-50x50@2x.png", 100),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@1x.png", 57),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-57x57@2x.png", 114),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", 120),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", 180),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@1x.png", 72),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-72x72@2x.png", 144),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", 76),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", 152),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", 167),
        ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", 1024),
    ]

    for (path, size) in outputs {
        let url = root.appendingPathComponent(path)
        try saveRep(resize(baseImage, to: size), to: url)
    }
}

func writeWeb(baseImage: NSImage) throws {
    let outputs: [(String, CGFloat)] = [
        ("web/favicon.png", 64),
        ("web/icons/Icon-192.png", 192),
        ("web/icons/Icon-512.png", 512),
        ("web/icons/Icon-maskable-192.png", 192),
        ("web/icons/Icon-maskable-512.png", 512),
    ]

    for (path, size) in outputs {
        let url = root.appendingPathComponent(path)
        try ensureDir(url.deletingLastPathComponent())
        try saveRep(resize(baseImage, to: size), to: url)
    }
}

func writeDesignSources(baseRep: NSBitmapImageRep, foregroundRep: NSBitmapImageRep, backgroundRep: NSBitmapImageRep) throws {
    let baseImage = imageFromRep(baseRep)
    let foregroundImage = imageFromRep(foregroundRep)
    let outputs: [(NSBitmapImageRep, String)] = [
        (baseRep, "design/app-icon/master/varlik360-icon-master-1024.png"),
        (resize(baseImage, to: 512), "design/app-icon/master/varlik360-icon-playstore-512.png"),
        (foregroundRep, "design/app-icon/android/varlik360-adaptive-foreground-1024.png"),
        (backgroundRep, "design/app-icon/android/varlik360-adaptive-background-1024.png"),
        (resize(foregroundImage, to: 432), "android/app/src/main/res/drawable/ic_launcher_foreground.png"),
        (baseRep, "assets/icon/app_icon_1024.png"),
    ]

    for (rep, path) in outputs {
        let url = root.appendingPathComponent(path)
        try ensureDir(url.deletingLastPathComponent())
        try saveRep(rep, to: url)
    }
}

let baseRep = makeRep(size: 1024, includeBackground: true, includeForeground: true)
let foregroundRep = makeRep(size: 1024, includeBackground: false, includeForeground: true)
let backgroundRep = makeRep(size: 1024, includeBackground: true, includeForeground: false)
let baseImage = imageFromRep(baseRep)

do {
    try writeDesignSources(baseRep: baseRep, foregroundRep: foregroundRep, backgroundRep: backgroundRep)
    try writeAndroidLegacy(baseImage: baseImage)
    try writeIOS(baseImage: baseImage)
    try writeWeb(baseImage: baseImage)
    print("Exported Varlik360 icon set.")
} catch {
    fputs("Icon export failed: \(error)\n", stderr)
    exit(1)
}
