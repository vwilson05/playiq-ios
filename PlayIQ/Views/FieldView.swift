import SwiftUI

struct FieldView: View {
    let setup: GameSetup?
    var compact: Bool = false

    private let fieldSize: CGFloat = 280

    var body: some View {
        let size = compact ? fieldSize * 0.7 : fieldSize

        Canvas { context, canvasSize in
            let scale = min(canvasSize.width, canvasSize.height) / 300
            let centerX = canvasSize.width / 2
            let bottomY = canvasSize.height * 0.85

            // Outfield grass arc
            let outfieldPath = Path { path in
                path.addArc(
                    center: CGPoint(x: centerX, y: bottomY),
                    radius: 130 * scale,
                    startAngle: .degrees(-135),
                    endAngle: .degrees(-45),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: centerX, y: bottomY))
                path.closeSubpath()
            }
            context.fill(outfieldPath, with: .color(PlayIQColors.fieldGreen))

            // Infield dirt diamond
            let diamondScale = 80 * scale
            let home = CGPoint(x: centerX, y: bottomY)
            let first = CGPoint(x: centerX + diamondScale, y: bottomY - diamondScale * 0.6)
            let second = CGPoint(x: centerX, y: bottomY - diamondScale * 1.2)
            let third = CGPoint(x: centerX - diamondScale, y: bottomY - diamondScale * 0.6)

            let infieldPath = Path { path in
                path.move(to: home)
                path.addLine(to: first)
                path.addLine(to: second)
                path.addLine(to: third)
                path.closeSubpath()
            }
            context.fill(infieldPath, with: .color(PlayIQColors.fieldDirt.opacity(0.6)))

            // Baselines
            let lineWidth: CGFloat = 2 * scale
            context.stroke(
                Path { path in
                    path.move(to: home)
                    path.addLine(to: first)
                    path.addLine(to: second)
                    path.addLine(to: third)
                    path.addLine(to: home)
                },
                with: .color(.white.opacity(0.6)),
                lineWidth: lineWidth
            )

            // Foul lines extending to outfield
            let foulExtend = 130 * scale
            context.stroke(
                Path { path in
                    path.move(to: home)
                    let angle1 = -Double.pi / 4
                    path.addLine(to: CGPoint(
                        x: centerX + foulExtend * cos(angle1),
                        y: bottomY + foulExtend * sin(angle1)
                    ))
                },
                with: .color(.white.opacity(0.4)),
                lineWidth: lineWidth * 0.7
            )
            context.stroke(
                Path { path in
                    path.move(to: home)
                    let angle2 = -3 * Double.pi / 4
                    path.addLine(to: CGPoint(
                        x: centerX + foulExtend * cos(angle2),
                        y: bottomY + foulExtend * sin(angle2)
                    ))
                },
                with: .color(.white.opacity(0.4)),
                lineWidth: lineWidth * 0.7
            )

            // Bases
            let baseSize: CGFloat = 8 * scale
            drawBase(context: context, point: first, size: baseSize)
            drawBase(context: context, point: second, size: baseSize)
            drawBase(context: context, point: third, size: baseSize)

            // Home plate (pentagon)
            let homeSize: CGFloat = 10 * scale
            let homePath = Path { path in
                path.move(to: CGPoint(x: home.x, y: home.y + homeSize * 0.4))
                path.addLine(to: CGPoint(x: home.x + homeSize * 0.5, y: home.y))
                path.addLine(to: CGPoint(x: home.x + homeSize * 0.3, y: home.y - homeSize * 0.4))
                path.addLine(to: CGPoint(x: home.x - homeSize * 0.3, y: home.y - homeSize * 0.4))
                path.addLine(to: CGPoint(x: home.x - homeSize * 0.5, y: home.y))
                path.closeSubpath()
            }
            context.fill(homePath, with: .color(.white))

            // Pitcher's mound
            let moundCenter = CGPoint(x: centerX, y: bottomY - diamondScale * 0.55)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: moundCenter.x - 6 * scale,
                    y: moundCenter.y - 3 * scale,
                    width: 12 * scale,
                    height: 6 * scale
                )),
                with: .color(PlayIQColors.fieldDirt)
            )

            // Runner dots
            if let runners = setup?.runners {
                let dotSize: CGFloat = 12 * scale
                if runners.first {
                    drawRunner(context: context, point: first, size: dotSize)
                }
                if runners.second {
                    drawRunner(context: context, point: second, size: dotSize)
                }
                if runners.third {
                    drawRunner(context: context, point: third, size: dotSize)
                }
            }
        }
        .frame(width: size, height: size * 0.85)
    }

    private func drawBase(context: GraphicsContext, point: CGPoint, size: CGFloat) {
        let rect = CGRect(
            x: point.x - size / 2,
            y: point.y - size / 2,
            width: size,
            height: size
        )
        let rotated = Path { path in
            path.addRect(rect)
        }
        context.fill(rotated, with: .color(.white))
    }

    private func drawRunner(context: GraphicsContext, point: CGPoint, size: CGFloat) {
        let offset = CGPoint(x: point.x, y: point.y - size)
        context.fill(
            Path(ellipseIn: CGRect(
                x: offset.x - size / 2,
                y: offset.y - size / 2,
                width: size,
                height: size
            )),
            with: .color(PlayIQColors.gold)
        )
        // Runner outline
        context.stroke(
            Path(ellipseIn: CGRect(
                x: offset.x - size / 2,
                y: offset.y - size / 2,
                width: size,
                height: size
            )),
            with: .color(.white.opacity(0.8)),
            lineWidth: 1.5
        )
    }
}

#Preview {
    FieldView(setup: GameSetup(
        inning: 3,
        topBottom: "bottom",
        outs: 1,
        score: Score(home: 2, away: 1),
        runners: Runners(first: true, second: false, third: true)
    ))
    .background(PlayIQColors.background)
}
