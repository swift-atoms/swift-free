import Free_Macro_Core
import SwiftSyntax
import SwiftSyntaxMacros

public struct Macro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Free applies to an enum declaration only.")
        }
        return Derivation.expansion(of: declaration)
    }
}
