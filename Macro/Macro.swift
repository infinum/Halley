@attached(member)
public macro HalleyLink(_ name: String?) = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyLinkMacro")

@attached(member, names: named(CodingKeys), named(_links))
@attached(conformance)
public macro HalleyModel() = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyModelMacro")
