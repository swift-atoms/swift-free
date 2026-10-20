import Free_Macro
import Functor_Base_Macro
import Testing

@FunctorBase
@Free
private indirect enum Count {
    case zero
    case successor(Count)
}

private func evaluate(_ value: Count.Free<Int>) -> Int {
    value.fold(
        pure: { $0 },
        suspend: { layer in
            switch layer {
            case .zero: 0
            case .successor(let child): child + 1
            }
        }
    )
}

@Suite
struct `Free boundaries` {
    @Test
    func `a pure value folds through the pure interpretation`() {
        #expect(evaluate(.pure(42)) == 42)
    }

    @Test
    func `a suspended base case folds without a value`() {
        #expect(evaluate(.suspend(.zero)) == 0)
    }

    @Test
    func `flatMap on a pure value applies the transform`() {
        let transform: (Int) -> Count.Free<Int> = { .suspend(.successor(.pure($0 * 2))) }
        #expect(evaluate(Count.Free<Int>.pure(5).flatMap(transform)) == evaluate(transform(5)))
    }

    @Test
    func `map reaches values under suspended layers`() {
        let value = Count.Free<Int>.suspend(.successor(.suspend(.successor(.pure(1)))))
        #expect(evaluate(value.map { $0 + 10 }) == 13)
    }

    @Test
    func `joined flattens nested carriers`() {
        let nested = Count.Free<Count.Free<Int>>.suspend(.successor(.pure(.suspend(.successor(.pure(3))))))
        #expect(evaluate(nested.joined()) == 5)
    }
}
