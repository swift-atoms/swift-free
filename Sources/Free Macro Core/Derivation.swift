import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        do { return try derive(declaration) }
        catch { return [DeclSyntax(stringLiteral: "#error(\(String(reflecting: String(describing: error))))")] }
    }

    private static func derive(_ declaration: EnumDeclSyntax) throws -> [DeclSyntax] {
        let variable = Type.Variable("Recursion")
        let layer = try Type.Syntax.Recursion.polynomial(of: declaration, variable: variable)
        let carrier = try Type.Recursion.free(layer: layer.expression, variable: variable, returning: .atom(.init("Value")))

        let representation = Type.Syntax.Interpretation(
            atoms: [.init("Value"): TypeSyntax(stringLiteral: "Value")],
            representations: [layer.expression: TypeSyntax(stringLiteral: "Base<Free<Value>>")])
        let access = Type.Syntax.Recursion.access(of: declaration)

        guard case .sum(let alternatives) = carrier.body else { throw Type.Failure("free carrier requires a sum") }
        let cases = try zip(["pure", "suspend"], alternatives).map {
            "case \($0)(\(try representation.type($1)))"
        }.joined(separator: "\n")
        return ["""
            \(raw: access)indirect enum Free<Value> {
                \(raw: cases)

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
