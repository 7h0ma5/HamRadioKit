//
//  Modes.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 15.05.22.
//

import Foundation

public enum Mode: String, CaseIterable, Codable, CustomStringConvertible {
    case cw = "CW"
    case ssb = "SSB"
    case am = "AM"
    case fm = "FM"
    case psk = "PSK"
    case rtty = "RTTY"
    case mfsk = "MFSK"
    case olivia = "OLIVIA"
    case jt65 = "JT65"
    case jt9 = "JT9"
    case ft8 = "FT8"
    case hell = "HELL"
    case contestia = "CONTESTIA"
    case domino = "DOMINO"
    case mt63 = "MT63"
    case jt6m = "JT6M"
    case jtmsk = "JTMSK"
    case msk144 = "MSK144"
    case fsk441 = "FSK441"
    case digitalVoice = "DIGITALVOICE"
    case dstar = "DSTAR"
    case pkt = "PKT"
    case atv = "ATV"
    case sstv = "SSTV"
    case chip = "CHIP"
    case tor = "TOR"
    case jt4 = "JT4"
    case pac = "PAC"
    case pax = "PAX"
    case thrb = "THRB"
    
    static let legacyModes: [String: (Mode, String)] = [
        "AMTORFEC": (Mode.tor, "AMTORFEC"),
        "ASCI": (Mode.rtty, "ASCI"),
        "CHIP64": (Mode.chip, "CHIP64"),
        "CHIP128": (Mode.chip, "CHIP128"),
        "DOMINOF": (Mode.domino, "DOMINOOF"),
        "FMHELL": (Mode.hell, "FMHELL"),
        "FSK31": (Mode.psk, "FSK31"),
        "GTOR": (Mode.tor, "GTOR"),
        "HELL80": (Mode.hell, "HELL80"),
        "HFSK": (Mode.hell, "HFSK"),
        "JT4A": (Mode.jt4, "JT4A"),
        "JT4B": (Mode.jt4, "JT4B"),
        "JT4C": (Mode.jt4, "JT4C"),
        "JT4D": (Mode.jt4, "JT4D"),
        "JT4E": (Mode.jt4, "JT4E"),
        "JT4F": (Mode.jt4, "JT4F"),
        "JT4G": (Mode.jt4, "JT4G"),
        "JT65A": (Mode.jt4, "JT65A"),
        "JT65B": (Mode.jt4, "JT65B"),
        "JT65C": (Mode.jt4, "JT65C"),
        "MFSK8": (Mode.mfsk, "MFSK8"),
        "MFSK16": (Mode.mfsk, "MFSK16"),
        "PAC2": (Mode.pac, "PAC2"),
        "PAC3": (Mode.pac, "PAC3"),
        "PAX2": (Mode.pax, "PAX2"),
        "PCW": (Mode.cw, "PCW"),
        "PSK10": (Mode.psk, "PSK10"),
        "PSK31": (Mode.psk, "PSK31"),
        "PSK63": (Mode.psk, "PSK63"),
        "PSK63F": (Mode.psk, "PSK63F"),
        "PSK125": (Mode.psk, "PSK125"),
        "PSKAM10": (Mode.psk, "PSKAM10"),
        "PSKAM31": (Mode.psk, "PSKAM31"),
        "PSKAM50": (Mode.psk, "PSKAM50"),
        "PSKFEC31": (Mode.psk, "PSKFEC31"),
        "PSKHELL": (Mode.hell, "PSKHELL"),
        "QPSK31": (Mode.psk, "QPSK31"),
        "QPSK63": (Mode.psk, "QPSK63"),
        "QPSK125": (Mode.psk, "QPSK125"),
        "THRBX": (Mode.thrb, "THRBX"),
        "USB": (Mode.ssb, "USB"),
        "LSB": (Mode.ssb, "LSB"),
        "FT4": (Mode.mfsk, "FT4")
    ]
    
    public static func find(byName name: String) -> Mode? {
        Mode(rawValue: name)
    }
    
    public var description: String {
        return self.name
    }
    
    public var name: String {
        return self.rawValue
    }
    
    public var defaultReport: String? {
        switch self {
        case .cw, .rtty: return "599"
        case .ssb, .am, .fm:
            return "59"
        case .jt65, .jt9, .ft8:
            return "-1"
        default: return nil
        }
    }

    public var submodes: [String] {
        switch self {
        case .ssb: return ["LSB", "USB"]
        case .psk: return [
            "PSK31",
            "PSK63",
            "PSK63F",
            "PSK125",
            "PSK250",
            "PSK500",
            "PSK1000",
            "QPSK31",
            "QPSK63",
            "QPSK125",
            "QPSK250",
            "QPSK500"
        ]
        case .mfsk: return [
            "FT4",
            "MFSK4",
            "MFSK8",
            "MFSK11",
            "MFSK16",
            "MFSK22",
            "MFSK31",
            "MFSK32"
        ]
        case .olivia: return [
            "OLIVIA 4/125",
            "OLIVIA 4/250",
            "OLIVIA 8/250",
            "OLIVIA 8/500",
            "OLIVIA 16/500",
            "OLIVIA 16/1000",
            "OLIVIA 32/1000"
        ]
        case .jt65: return [
            "JT65A",
            "JT65B",
            "JT65B2",
            "JT65C",
            "JT65C2"
        ]
        case .jt9: return [
            "JT9-1",
            "JT9-2",
            "JT9-5",
            "JT9-10",
            "JT9-30"
        ]
        default:
            return []
        }
    }
    
    public var dxccMode: DXCCMode {
        switch self {
        case .cw: return .cw
        case .ssb: return .phone
        case .fm: return .phone
        case .am: return .phone
        case .digitalVoice: return .phone
        case .dstar: return .phone
        default: return .digital
        }
    }
}
