import Halley

@attached(peer)
public macro HalleyLink(_ name: String?) = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyLinkMacro")

@attached(member, names: named(CodingKeys), named(_links))
@attached(extension, conformances: HalleyCodable)
public macro HalleyModel() = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyModelMacro")
