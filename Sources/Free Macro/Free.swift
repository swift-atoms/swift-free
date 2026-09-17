@attached(member, names: arbitrary)
public macro Free() = #externalMacro(
    module: "Free_Macro_Plugin",
    type: "Macro"
)
