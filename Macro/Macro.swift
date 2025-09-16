import Halley

@attached(peer)
public macro HalleyCodingKey(_ name: String?) = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyCodingKeyMacro")

@attached(member, names: named(CodingKeys), named(_links))
@attached(extension, conformances: HalleyCodable)
public macro HalleyModel() = #externalMacro(module: "HalleyMacroPlugin", type: "HalleyModelMacro")
