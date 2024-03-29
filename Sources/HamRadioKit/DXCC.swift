//
//  DXCC.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 17.05.22.
//

import Foundation

public enum DXCCMode: String, Codable {
    case cw = "CW"
    case phone = "PHONE"
    case digital = "DIGITAL"
}

#if !os(Linux)
extension DXCCMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cw: return String(localized: "CW")
        case .phone: return String(localized: "Phone")
        case .digital: return String(localized: "Digital")
        }
    }
}
#endif

public typealias DXCC = UInt16

public extension DXCC {
    var iso: String? {
        switch self {
        case 1: return "CA"
        case 3: return "AF"
        case 4: return "MP"
        case 5: return "AX"
        case 6: return "US"
        case 7: return "AL"
        case 8: return "SC"
        case 9: return "AS"
        case 10: return "FR"
        case 11: return "IN"
        case 12: return "AI"
        case 13: return "AQ"
        case 14: return "AM"
        case 15: return "RU"
        case 16: return "NZ"
        case 17: return "VE"
        case 18: return "AZ"
        case 19: return "CO"
        case 20: return "US"
        case 21: return "ES"
        case 22: return "PW"
        case 23: return "MU"
        case 24: return "NO"
        case 25: return "GB"
        case 26: return "GB"
        case 27: return "BY"
        case 29: return "IC"
        case 30: return "ID"
        case 31: return "KI"
        case 32: return "ES"
        case 33: return "GB"
        case 34: return "NZ"
        case 35: return "CX"
        case 36: return "FR"
        case 37: return "CR"
        case 38: return "CC"
        case 40: return "GR"
        case 41: return "FR"
        case 43: return "PR"
        case 45: return "GR"
        case 46: return "MY"
        case 47: return "CL"
        case 48: return "KI"
        case 49: return "GQ"
        case 50: return "MX"
        case 51: return "ER"
        case 52: return "EE"
        case 53: return "ET"
        case 54: return "RU"
        case 55: return "SC"
        case 56: return "BR"
        case 57: return "FR"
        case 58: return "FR"
        case 59: return "FR"
        case 60: return "BS"
        case 61: return "RU"
        case 62: return "BB"
        case 63: return "FR"
        case 64: return "BM"
        case 65: return "VG"
        case 66: return "BZ"
        case 67: return "FR"
        case 69: return "KY"
        case 70: return "CU"
        case 71: return "EC"
        case 72: return "DO"
        case 74: return "SV"
        case 75: return "GE"
        case 76: return "GT"
        case 77: return "GD"
        case 78: return "HT"
        case 79: return "FR"
        case 80: return "HN"
        case 81: return "DE"
        case 82: return "JM"
        case 84: return "MQ"
        case 86: return "NI"
        case 88: return "PA"
        case 89: return "TC"
        case 90: return "TT"
        case 91: return "AW"
        case 94: return "AG"
        case 95: return "DM"
        case 96: return "MS"
        case 97: return "LC"
        case 98: return "VC"
        case 99: return "FR"
        case 100: return "AR"
        case 103: return "GU"
        case 104: return "BO"
        case 105: return "US"
        case 106: return "GG"
        case 107: return "GN"
        case 108: return "BR"
        case 109: return "GW"
        case 110: return "US"
        case 111: return "AU"
        case 112: return "CL"
        case 114: return "IM"
        case 115: return "IT"
        case 116: return "CO"
        case 117: return "CH"
        case 118: return "NO"
        case 120: return "EC"
        case 122: return "JE"
        case 123: return "US"
        case 124: return "FR"
        case 125: return "CL"
        case 126: return "RU"
        case 129: return "GY"
        case 130: return "KZ"
        case 131: return "FR"
        case 132: return "PY"
        case 133: return "NZ"
        case 134: return "US"
        case 135: return "KG"
        case 136: return "PE"
        case 137: return "KR"
        case 138: return "US"
        case 140: return "SR"
        case 141: return "FK"
        case 142: return "IN"
        case 143: return "LA"
        case 144: return "UY"
        case 145: return "LV"
        case 146: return "LT"
        case 147: return "AU"
        case 148: return "VE"
        case 149: return "PT"
        case 150: return "AU"
        case 152: return "MO"
        case 153: return "AU"
        case 157: return "NR"
        case 158: return "VU"
        case 159: return "MV"
        case 160: return "TO"
        case 161: return "CO"
        case 162: return "NC"
        case 163: return "PG"
        case 165: return "MU"
        case 166: return "US"
        case 167: return "SE"
        case 168: return "MH"
        case 169: return "YT"
        case 170: return "NZ"
        case 171: return "AU"
        case 172: return "PN"
        case 173: return "FM"
        case 174: return "US"
        case 175: return "PF"
        case 176: return "FJ"
        case 177: return "JP"
        case 179: return "MD"
        case 180: return "GR"
        case 181: return "MZ"
        case 182: return "US"
        case 185: return "SB"
        case 187: return "NE"
        case 188: return "NU"
        case 189: return "NF"
        case 190: return "WS"
        case 191: return "NZ"
        case 192: return "JP"
        case 195: return "GQ"
        case 197: return "US"
        case 199: return "NO"
        case 201: return "ZA"
        case 202: return "PR"
        case 203: return "AD"
        case 204: return "MX"
        case 205: return "GB"
        case 206: return "AT"
        case 207: return "MU"
        case 209: return "BE"
        case 211: return "CA"
        case 212: return "BG"
        case 213: return "FR"
        case 214: return "FR"
        case 215: return "CY"
        case 216: return "NI"
        case 217: return "CL"
        case 219: return "ST"
        case 221: return "DK"
        case 222: return "FO"
        case 223: return "GB-ENG"
        case 224: return "FI"
        case 225: return "IT"
        case 227: return "FR"
        case 229: return "DE"
        case 230: return "DE"
        case 232: return "SO"
        case 233: return "GI"
        case 234: return "GS"
        case 235: return "GS"
        case 236: return "GR"
        case 237: return "GL"
        case 238: return "GB"
        case 239: return "HU"
        case 240: return "GS"
        case 241: return "GB"
        case 242: return "IS"
        case 245: return "IE"
        case 246: return "MT"
        case 247: return "PH"
        case 248: return "IT"
        case 249: return "KN"
        case 250: return "SH"
        case 251: return "LI"
        case 252: return "CA"
        case 253: return "BR"
        case 254: return "LU"
        case 255: return "NL"
        case 256: return "PT"
        case 257: return "MT"
        case 259: return "NO"
        case 260: return "MC"
        case 262: return "TJ"
        case 263: return "NL"
        case 265: return "GB-NIR"
        case 266: return "NO"
        case 269: return "PL"
        case 270: return "TK"
        case 272: return "PT"
        case 273: return "BR"
        case 274: return "GB"
        case 275: return "RO"
        case 276: return "FR"
        case 277: return "CA"
        case 278: return "SM"
        case 279: return "GB-SCT"
        case 280: return "TM"
        case 281: return "ES"
        case 282: return "TV"
        case 283: return "CY"
        case 284: return "SE"
        case 285: return "VI"
        case 286: return "UG"
        case 287: return "CH"
        case 288: return "UA"
        case 289: return "united-nations"
        case 291: return "US"
        case 292: return "UZ"
        case 293: return "VN"
        case 294: return "CB-WLS"
        case 295: return "VA"
        case 296: return "RS"
        case 297: return "US"
        case 298: return "WF"
        case 299: return "MY"
        case 301: return "KI"
        case 302: return "EH"
        case 303: return "AU"
        case 304: return "BH"
        case 305: return "BD"
        case 306: return "BT"
        case 308: return "CR"
        case 309: return "MM"
        case 312: return "KH"
        case 315: return "LK"
        case 318: return "CN"
        case 321: return "HK"
        case 324: return "IN"
        case 327: return "ID"
        case 330: return "IR"
        case 333: return "IQ"
        case 336: return "IL"
        case 339: return "JP"
        case 342: return "JO"
        case 344: return "KP"
        case 345: return "BN"
        case 348: return "KW"
        case 354: return "LB"
        case 363: return "MN"
        case 369: return "NP"
        case 370: return "OM"
        case 372: return "PK"
        case 375: return "PH"
        case 376: return "QA"
        case 378: return "SA"
        case 379: return "SC"
        case 381: return "SG"
        case 382: return "DJ"
        case 384: return "SY"
        case 386: return "TW"
        case 387: return "TH"
        case 390: return "TR"
        case 391: return "AE"
        case 400: return "DZ"
        case 401: return "AO"
        case 402: return "BW"
        case 404: return "BI"
        case 406: return "CM"
        case 408: return "CF"
        case 409: return "CV"
        case 410: return "TD"
        case 411: return "KM"
        case 412: return "CG"
        case 414: return "CD"
        case 416: return "BJ"
        case 420: return "GA"
        case 422: return "GM"
        case 424: return "GH"
        case 428: return "CI"
        case 430: return "KE"
        case 432: return "LS"
        case 434: return "LR"
        case 436: return "LY"
        case 438: return "MG"
        case 440: return "MW"
        case 442: return "ML"
        case 444: return "MR"
        case 446: return "MA"
        case 450: return "NG"
        case 452: return "ZW"
        case 453: return "FR"
        case 454: return "RW"
        case 456: return "SN"
        case 458: return "SL"
        case 460: return "FJ"
        case 462: return "ZA"
        case 464: return "NA"
        case 466: return "SD"
        case 468: return "SZ"
        case 470: return "TZ"
        case 474: return "TN"
        case 478: return "EG"
        case 480: return "BF"
        case 482: return "ZM"
        case 483: return "TG"
        case 489: return "FJ"
        case 490: return "KI"
        case 492: return "YE"
        case 497: return "HR"
        case 499: return "SI"
        case 501: return "BA"
        case 502: return "MK"
        case 503: return "CZ"
        case 504: return "SK"
        case 505: return "TW"
        case 506: return "PH"
        case 507: return "SB"
        case 508: return "PF"
        case 509: return "FR"
        case 510: return "PS"
        case 511: return "TL"
        case 512: return "GB"
        case 513: return "PN"
        case 514: return "ME"
        case 515: return "US"
        case 516: return "FR"
        case 517: return "CW"
        case 518: return "NL"
        case 519: return "AN"
        case 520: return "NL"
        case 521: return "SS"
        default: return nil
        }
    }
    
    var name: String? {
        switch (self) {
        case 0: return "None"
        case 1: return "CANADA"
        case 2: return "ABU AIL IS."
        case 3: return "AFGHANISTAN"
        case 4: return "AGALEGA & ST. BRANDON IS."
        case 5: return "ALAND IS."
        case 6: return "ALASKA"
        case 7: return "ALBANIA"
        case 8: return "ALDABRA"
        case 9: return "AMERICAN SAMOA"
        case 10: return "AMSTERDAM & ST. PAUL IS."
        case 11: return "ANDAMAN & NICOBAR IS."
        case 12: return "ANGUILLA"
        case 13: return "ANTARCTICA"
        case 14: return "ARMENIA"
        case 15: return "ASIATIC RUSSIA"
        case 16: return "NEW ZEALAND SUBANTARCTIC ISLANDS"
        case 17: return "AVES I."
        case 18: return "AZERBAIJAN"
        case 19: return "BAJO NUEVO"
        case 20: return "BAKER & HOWLAND IS."
        case 21: return "BALEARIC IS."
        case 22: return "PALAU"
        case 23: return "BLENHEIM REEF"
        case 24: return "BOUVET"
        case 25: return "BRITISH NORTH BORNEO"
        case 26: return "BRITISH SOMALILAND"
        case 27: return "BELARUS"
        case 28: return "CANAL ZONE"
        case 29: return "CANARY IS."
        case 30: return "CELEBE & MOLUCCA IS."
        case 31: return "C. KIRIBATI (BRITISH PHOENIX IS.)"
        case 32: return "CEUTA & MELILLA"
        case 33: return "CHAGOS IS."
        case 34: return "CHATHAM IS."
        case 35: return "CHRISTMAS I."
        case 36: return "CLIPPERTON I."
        case 37: return "COCOS I."
        case 38: return "COCOS (KEELING) IS."
        case 39: return "COMOROS"
        case 40: return "CRETE"
        case 41: return "CROZET I."
        case 42: return "DAMAO, DIU"
        case 43: return "DESECHEO I."
        case 44: return "DESROCHES"
        case 45: return "DODECANESE"
        case 46: return "EAST MALAYSIA"
        case 47: return "EASTER I."
        case 48: return "E. KIRIBATI (LINE IS.)"
        case 49: return "EQUATORIAL GUINEA"
        case 50: return "MEXICO"
        case 51: return "ERITREA"
        case 52: return "ESTONIA"
        case 53: return "ETHIOPIA"
        case 54: return "EUROPEAN RUSSIA"
        case 55: return "FARQUHAR"
        case 56: return "FERNANDO DE NORONHA"
        case 57: return "FRENCH EQUATORIAL AFRICA"
        case 58: return "FRENCH INDO-CHINA"
        case 59: return "FRENCH WEST AFRICA"
        case 60: return "BAHAMAS"
        case 61: return "FRANZ JOSEF LAND"
        case 62: return "BARBADOS"
        case 63: return "FRENCH GUIANA"
        case 64: return "BERMUDA"
        case 65: return "BRITISH VIRGIN IS."
        case 66: return "BELIZE"
        case 67: return "FRENCH INDIA"
        case 68: return "KUWAIT/SAUDI ARABIA NEUTRAL ZONE"
        case 69: return "CAYMAN IS."
        case 70: return "CUBA"
        case 71: return "GALAPAGOS IS."
        case 72: return "DOMINICAN REPUBLIC"
        case 74: return "EL SALVADOR"
        case 75: return "GEORGIA"
        case 76: return "GUATEMALA"
        case 77: return "GRENADA"
        case 78: return "HAITI"
        case 79: return "GUADELOUPE"
        case 80: return "HONDURAS"
        case 81: return "GERMANY"
        case 82: return "JAMAICA"
        case 84: return "MARTINIQUE"
        case 85: return "BONAIRE, CURACAO"
        case 86: return "NICARAGUA"
        case 88: return "PANAMA"
        case 89: return "TURKS & CAICOS IS."
        case 90: return "TRINIDAD & TOBAGO"
        case 91: return "ARUBA"
        case 93: return "GEYSER REEF"
        case 94: return "ANTIGUA & BARBUDA"
        case 95: return "DOMINICA"
        case 96: return "MONTSERRAT"
        case 97: return "ST. LUCIA"
        case 98: return "ST. VINCENT"
        case 99: return "GLORIOSO IS."
        case 100: return "ARGENTINA"
        case 101: return "GOA"
        case 102: return "GOLD COAST, TOGOLAND"
        case 103: return "GUAM"
        case 104: return "BOLIVIA"
        case 105: return "GUANTANAMO BAY"
        case 106: return "GUERNSEY"
        case 107: return "GUINEA"
        case 108: return "BRAZIL"
        case 109: return "GUINEA-BISSAU"
        case 110: return "HAWAII"
        case 111: return "HEARD I."
        case 112: return "CHILE"
        case 113: return "IFNI"
        case 114: return "ISLE OF MAN"
        case 115: return "ITALIAN SOMALILAND"
        case 116: return "COLOMBIA"
        case 117: return "ITU HQ"
        case 118: return "JAN MAYEN"
        case 119: return "JAVA"
        case 120: return "ECUADOR"
        case 122: return "JERSEY"
        case 123: return "JOHNSTON I."
        case 124: return "JUAN DE NOVA, EUROPA"
        case 125: return "JUAN FERNANDEZ IS."
        case 126: return "KALININGRAD"
        case 127: return "KAMARAN IS."
        case 128: return "KARELO-FINNISH REPUBLIC"
        case 129: return "GUYANA"
        case 130: return "KAZAKHSTAN"
        case 131: return "KERGUELEN IS."
        case 132: return "PARAGUAY"
        case 133: return "KERMADEC IS."
        case 134: return "KINGMAN REEF"
        case 135: return "KYRGYZSTAN"
        case 136: return "PERU"
        case 137: return "REPUBLIC OF KOREA"
        case 138: return "KURE I."
        case 139: return "KURIA MURIA I."
        case 140: return "SURINAME"
        case 141: return "FALKLAND IS."
        case 142: return "LAKSHADWEEP IS."
        case 143: return "LAOS"
        case 144: return "URUGUAY"
        case 145: return "LATVIA"
        case 146: return "LITHUANIA"
        case 147: return "LORD HOWE I."
        case 148: return "VENEZUELA"
        case 149: return "AZORES"
        case 150: return "AUSTRALIA"
        case 151: return "MALYJ VYSOTSKIJ I."
        case 152: return "MACAO"
        case 153: return "MACQUARIE I."
        case 154: return "YEMEN ARAB REPUBLIC"
        case 155: return "MALAYA"
        case 157: return "NAURU"
        case 158: return "VANUATU"
        case 159: return "MALDIVES"
        case 160: return "TONGA"
        case 161: return "MALPELO I."
        case 162: return "NEW CALEDONIA"
        case 163: return "PAPUA NEW GUINEA"
        case 164: return "MANCHURIA"
        case 165: return "MAURITIUS"
        case 166: return "MARIANA IS."
        case 167: return "MARKET REEF"
        case 168: return "MARSHALL IS."
        case 169: return "MAYOTTE"
        case 170: return "NEW ZEALAND"
        case 171: return "MELLISH REEF"
        case 172: return "PITCAIRN I."
        case 173: return "MICRONESIA"
        case 174: return "MIDWAY I."
        case 175: return "FRENCH POLYNESIA"
        case 176: return "FIJI"
        case 177: return "MINAMI TORISHIMA"
        case 178: return "MINERVA REEF"
        case 179: return "MOLDOVA"
        case 180: return "MOUNT ATHOS"
        case 181: return "MOZAMBIQUE"
        case 182: return "NAVASSA I."
        case 183: return "NETHERLANDS BORNEO"
        case 184: return "NETHERLANDS NEW GUINEA"
        case 185: return "SOLOMON IS."
        case 186: return "NEWFOUNDLAND, LABRADOR"
        case 187: return "NIGER"
        case 188: return "NIUE"
        case 189: return "NORFOLK I."
        case 190: return "SAMOA"
        case 191: return "NORTH COOK IS."
        case 192: return "OGASAWARA"
        case 193: return "OKINAWA (RYUKYU IS.)"
        case 194: return "OKINO TORI-SHIMA"
        case 195: return "ANNOBON I."
        case 196: return "PALESTINE"
        case 197: return "PALMYRA & JARVIS IS."
        case 198: return "PAPUA TERRITORY"
        case 199: return "PETER 1 I."
        case 200: return "PORTUGUESE TIMOR"
        case 201: return "PRINCE EDWARD & MARION IS."
        case 202: return "PUERTO RICO"
        case 203: return "ANDORRA"
        case 204: return "REVILLAGIGEDO"
        case 205: return "ASCENSION I."
        case 206: return "AUSTRIA"
        case 207: return "RODRIGUEZ I."
        case 208: return "RUANDA-URUNDI"
        case 209: return "BELGIUM"
        case 210: return "SAAR"
        case 211: return "SABLE I."
        case 212: return "BULGARIA"
        case 213: return "SAINT MARTIN"
        case 214: return "CORSICA"
        case 215: return "CYPRUS"
        case 216: return "SAN ANDRES & PROVIDENCIA"
        case 217: return "SAN FELIX & SAN AMBROSIO"
        case 218: return "CZECHOSLOVAKIA"
        case 219: return "SAO TOME & PRINCIPE"
        case 220: return "SARAWAK"
        case 221: return "DENMARK"
        case 222: return "FAROE IS."
        case 223: return "ENGLAND"
        case 224: return "FINLAND"
        case 225: return "SARDINIA"
        case 226: return "SAUDI ARABIA/IRAQ NEUTRAL ZONE"
        case 227: return "FRANCE"
        case 228: return "SERRANA BANK & RONCADOR CAY"
        case 229: return "GERMAN DEMOCRATIC REPUBLIC"
        case 230: return "FEDERAL REPUBLIC OF GERMANY"
        case 231: return "SIKKIM"
        case 232: return "SOMALIA"
        case 233: return "GIBRALTAR"
        case 234: return "SOUTH COOK IS."
        case 235: return "SOUTH GEORGIA I."
        case 236: return "GREECE"
        case 237: return "GREENLAND"
        case 238: return "SOUTH ORKNEY IS."
        case 239: return "HUNGARY"
        case 240: return "SOUTH SANDWICH IS."
        case 241: return "SOUTH SHETLAND IS."
        case 242: return "ICELAND"
        case 243: return "PEOPLE'S DEMOCRATIC REP. OF YEMEN"
        case 244: return "SOUTHERN SUDAN"
        case 245: return "IRELAND"
        case 246: return "SOVEREIGN MILITARY ORDER OF MALTA"
        case 247: return "SPRATLY IS."
        case 248: return "ITALY"
        case 249: return "ST. KITTS & NEVIS"
        case 250: return "ST. HELENA"
        case 251: return "LIECHTENSTEIN"
        case 252: return "ST. PAUL I."
        case 253: return "ST. PETER & ST. PAUL ROCKS"
        case 254: return "LUXEMBOURG"
        case 255: return "ST. MAARTEN, SABA, ST. EUSTATIUS"
        case 256: return "MADEIRA IS."
        case 257: return "MALTA"
        case 258: return "SUMATRA"
        case 259: return "SVALBARD"
        case 260: return "MONACO"
        case 261: return "SWAN IS."
        case 262: return "TAJIKISTAN"
        case 263: return "NETHERLANDS"
        case 264: return "TANGIER"
        case 265: return "NORTHERN IRELAND"
        case 266: return "NORWAY"
        case 267: return "TERRITORY OF NEW GUINEA"
        case 268: return "TIBET"
        case 269: return "POLAND"
        case 270: return "TOKELAU IS."
        case 271: return "TRIESTE"
        case 272: return "PORTUGAL"
        case 273: return "TRINDADE & MARTIM VAZ IS."
        case 274: return "TRISTAN DA CUNHA & GOUGH I."
        case 275: return "ROMANIA"
        case 276: return "TROMELIN I."
        case 277: return "ST. PIERRE & MIQUELON"
        case 278: return "SAN MARINO"
        case 279: return "SCOTLAND"
        case 280: return "TURKMENISTAN"
        case 281: return "SPAIN"
        case 282: return "TUVALU"
        case 283: return "UK SOVEREIGN BASE AREAS ON CYPRUS"
        case 284: return "SWEDEN"
        case 285: return "VIRGIN IS."
        case 286: return "UGANDA"
        case 287: return "SWITZERLAND"
        case 288: return "UKRAINE"
        case 289: return "UNITED NATIONS HQ"
        case 291: return "UNITED STATES OF AMERICA"
        case 292: return "UZBEKISTAN"
        case 293: return "VIET NAM"
        case 294: return "WALES"
        case 295: return "VATICAN"
        case 296: return "SERBIA"
        case 297: return "WAKE I."
        case 298: return "WALLIS & FUTUNA IS."
        case 299: return "WEST MALAYSIA"
        case 301: return "W. KIRIBATI (GILBERT IS. )"
        case 302: return "WESTERN SAHARA"
        case 303: return "WILLIS I."
        case 304: return "BAHRAIN"
        case 305: return "BANGLADESH"
        case 306: return "BHUTAN"
        case 307: return "ZANZIBAR"
        case 308: return "COSTA RICA"
        case 309: return "MYANMAR"
        case 312: return "CAMBODIA"
        case 315: return "SRI LANKA"
        case 318: return "CHINA"
        case 321: return "HONG KONG"
        case 324: return "INDIA"
        case 327: return "INDONESIA"
        case 330: return "IRAN"
        case 333: return "IRAQ"
        case 336: return "ISRAEL"
        case 339: return "JAPAN"
        case 342: return "JORDAN"
        case 344: return "DEMOCRATIC PEOPLE'S REP. OF KOREA"
        case 345: return "BRUNEI DARUSSALAM"
        case 348: return "KUWAIT"
        case 354: return "LEBANON"
        case 363: return "MONGOLIA"
        case 369: return "NEPAL"
        case 370: return "OMAN"
        case 372: return "PAKISTAN"
        case 375: return "PHILIPPINES"
        case 376: return "QATAR"
        case 378: return "SAUDI ARABIA"
        case 379: return "SEYCHELLES"
        case 381: return "SINGAPORE"
        case 382: return "DJIBOUTI"
        case 384: return "SYRIA"
        case 386: return "TAIWAN"
        case 387: return "THAILAND"
        case 390: return "TURKEY"
        case 391: return "UNITED ARAB EMIRATES"
        case 400: return "ALGERIA"
        case 401: return "ANGOLA"
        case 402: return "BOTSWANA"
        case 404: return "BURUNDI"
        case 406: return "CAMEROON"
        case 408: return "CENTRAL AFRICA"
        case 409: return "CAPE VERDE"
        case 410: return "CHAD"
        case 411: return "COMOROS"
        case 412: return "REPUBLIC OF THE CONGO"
        case 414: return "DEMOCRATIC REPUBLIC OF THE CONGO"
        case 416: return "BENIN"
        case 420: return "GABON"
        case 422: return "THE GAMBIA"
        case 424: return "GHANA"
        case 428: return "COTE D'IVOIRE"
        case 430: return "KENYA"
        case 432: return "LESOTHO"
        case 434: return "LIBERIA"
        case 436: return "LIBYA"
        case 438: return "MADAGASCAR"
        case 440: return "MALAWI"
        case 442: return "MALI"
        case 444: return "MAURITANIA"
        case 446: return "MOROCCO"
        case 450: return "NIGERIA"
        case 452: return "ZIMBABWE"
        case 453: return "REUNION I."
        case 454: return "RWANDA"
        case 456: return "SENEGAL"
        case 458: return "SIERRA LEONE"
        case 460: return "ROTUMA I."
        case 462: return "SOUTH AFRICA"
        case 464: return "NAMIBIA"
        case 466: return "SUDAN"
        case 468: return "SWAZILAND"
        case 470: return "TANZANIA"
        case 474: return "TUNISIA"
        case 478: return "EGYPT"
        case 480: return "BURKINA FASO"
        case 482: return "ZAMBIA"
        case 483: return "TOGO"
        case 488: return "WALVIS BAY"
        case 489: return "CONWAY REEF"
        case 490: return "BANABA I. (OCEAN I.)"
        case 492: return "YEMEN"
        case 493: return "PENGUIN IS."
        case 497: return "CROATIA"
        case 499: return "SLOVENIA"
        case 501: return "BOSNIA-HERZEGOVINA"
        case 502: return "MACEDONIA"
        case 503: return "CZECH REPUBLIC"
        case 504: return "SLOVAK REPUBLIC"
        case 505: return "PRATAS I."
        case 506: return "SCARBOROUGH REEF"
        case 507: return "TEMOTU PROVINCE"
        case 508: return "AUSTRAL I."
        case 509: return "MARQUESAS IS."
        case 510: return "PALESTINE"
        case 511: return "TIMOR-LESTE"
        case 512: return "CHESTERFIELD IS."
        case 513: return "DUCIE I."
        case 514: return "MONTENEGRO"
        case 515: return "SWAINS I."
        case 516: return "SAINT BARTHELEMY"
        case 517: return "CURACAO"
        case 518: return "ST MAARTEN"
        case 519: return "SABA & ST. EUSTATIUS"
        case 520: return "BONAIRE"
        case 521: return "SOUTH SUDAN (REPUBLIC OF)"
        case 522: return "REPUBLIC OF KOSOVO"
        default: return nil
        }
    }
    
    var deleted: Bool {
        switch self {
        case 2: return true
        case 8: return true
        case 19: return true
        case 23: return true
        case 25: return true
        case 26: return true
        case 28: return true
        case 30: return true
        case 39: return true
        case 42: return true
        case 44: return true
        case 57: return true
        case 58: return true
        case 59: return true
        case 67: return true
        case 68: return true
        case 81: return true
        case 85: return true
        case 93: return true
        case 101: return true
        case 102: return true
        case 113: return true
        case 115: return true
        case 119: return true
        case 127: return true
        case 128: return true
        case 134: return true
        case 139: return true
        case 151: return true
        case 154: return true
        case 155: return true
        case 164: return true
        case 178: return true
        case 183: return true
        case 184: return true
        case 186: return true
        case 193: return true
        case 194: return true
        case 196: return true
        case 198: return true
        case 200: return true
        case 208: return true
        case 210: return true
        case 218: return true
        case 220: return true
        case 226: return true
        case 228: return true
        case 229: return true
        case 231: return true
        case 243: return true
        case 244: return true
        case 255: return true
        case 258: return true
        case 261: return true
        case 264: return true
        case 267: return true
        case 268: return true
        case 271: return true
        case 307: return true
        case 488: return true
        case 493: return true
        default: return false
        }
    }
}
