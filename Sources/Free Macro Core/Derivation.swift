public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let access = declaration.modifiers.contains {
            $0.name.tokenKind == .keyword(.public)
        } ? "public " : ""

        return ["""
            \(raw: access)indirect enum Free<Value> {
                case pure(Value)
                case suspend(Base<Free<Value>>)

                /// Substitution, the canonical bind of the free carrier.
                \(raw: access)func flatMap<Mapped>(_ transform: (Value) -> Free<Mapped>) -> Free<Mapped> {
                    switch self {
                    case .pure(let value): return transform(value)
                    case .suspend(let layer): return .suspend(layer.map { $0.flatMap(transform) })
                    }
                }
                \(raw: access)func map<Mapped>(_ transform: (Value) -> Mapped) -> Free<Mapped> {
                    flatMap { .pure(transform($0)) }
                }
                /// The unique finite fold for the supplied generator and layer interpretations.
                \(raw: access)func fold<Result>(pure: (Value) -> Result, suspend: (Base<Result>) -> Result) -> Result {
                    switch self {
                    case .pure(let value): return pure(value)
                    case .suspend(let layer): return suspend(layer.map { $0.fold(pure: pure, suspend: suspend) })
                    }
                }
                \(raw: access)func joined<Inner>() -> Free<Inner> where Value == Free<Inner> {
                    flatMap { $0 }
                }
            }
            """]
    }
}
