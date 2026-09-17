import Free_Macro
import Testing

@Free
private indirect enum Natural {
    case zero
    case successor(Natural)
}

@Test
func `free carrier represents pure and suspended layers`() {
    let value = Natural.Free<Int>.suspend(.successor(.pure(42)))
    guard case let .suspend(.successor(.pure(number))) = value else {
        Issue.record("Expected suspended pure successor")
        return
    }
    #expect(number == 42)
}
