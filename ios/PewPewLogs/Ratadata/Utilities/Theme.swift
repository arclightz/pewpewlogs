import SwiftUI

// MARK: - App Theme

enum AppTheme {
    // MARK: - Brand Colors
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "F093FB"), Color(hex: "F5576C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color(hex: "11998E"), Color(hex: "38EF7D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warningGradient = LinearGradient(
        colors: [Color(hex: "F2994A"), Color(hex: "F2C94C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let dangerGradient = LinearGradient(
        colors: [Color(hex: "EB3349"), Color(hex: "F45C43")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Semantic Colors
    static let cardBackground = Color(.systemBackground).opacity(0.8)
    static let elevatedBackground = Color(.secondarySystemBackground)
    static let subtleText = Color(.secondaryLabel)

    // MARK: - Session Type Colors
    static func sessionTypeColor(_ type: SessionType) -> Color {
        switch type {
        case .kilpailu: Color(hex: "EB3349")
        case .harjoitus: Color(hex: "667EEA")
        case .harjoituskilpailu: Color(hex: "F2994A")
        case .kuivaharjoittelu: Color(hex: "8E8E93")
        case .seuranViikkokisa: Color(hex: "764BA2")
        case .valmennus: Color(hex: "11998E")
        case .muuMerkinta: Color(hex: "636366")
        }
    }

    static func sessionTypeGradient(_ type: SessionType) -> LinearGradient {
        switch type {
        case .kilpailu: dangerGradient
        case .harjoitus: primaryGradient
        case .harjoituskilpailu: warningGradient
        case .kuivaharjoittelu: LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
        case .seuranViikkokisa: LinearGradient(colors: [Color(hex: "764BA2"), Color(hex: "667EEA")], startPoint: .leading, endPoint: .trailing)
        case .valmennus: successGradient
        case .muuMerkinta: LinearGradient(colors: [Color(hex: "636366"), Color(hex: "8E8E93")], startPoint: .leading, endPoint: .trailing)
        }
    }

    // MARK: - Weapon Type Colors
    static func weaponTypeColor(_ type: WeaponType) -> Color {
        switch type {
        case .pistooli: Color(hex: "667EEA")
        case .kivaari: Color(hex: "11998E")
        case .haulikko: Color(hex: "F2994A")
        case .revolveri: Color(hex: "EB3349")
        case .pcc: Color(hex: "764BA2")
        case .ilmaAse: Color(hex: "56CCF2")
        case .deaktivoitu: Color(hex: "8E8E93")
        case .muu: Color(hex: "636366")
        case .yhdistelmaase: Color(hex: "F093FB")
        case .merkinantoase: Color(hex: "F2C94C")
        case .kaasuase: Color(hex: "F45C43")
        }
    }

    // MARK: - Corner Radii
    static let cardRadius: CGFloat = 16
    static let badgeRadius: CGFloat = 8
    static let smallRadius: CGFloat = 10

    // MARK: - Shadows
    static let cardShadow = Color.black.opacity(0.08)
    static let elevatedShadow = Color.black.opacity(0.12)
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable View Modifiers

struct GlassCard: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
}

struct GradientBadge: ViewModifier {
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.badgeRadius, style: .continuous))
    }
}

struct PrimaryButton: ViewModifier {
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

extension View {
    func glassCard(padding: CGFloat = 16) -> some View {
        modifier(GlassCard(padding: padding))
    }

    func gradientBadge(_ gradient: LinearGradient) -> some View {
        modifier(GradientBadge(gradient: gradient))
    }

    func primaryButton(_ gradient: LinearGradient = AppTheme.primaryGradient) -> some View {
        modifier(PrimaryButton(gradient: gradient))
    }
}
