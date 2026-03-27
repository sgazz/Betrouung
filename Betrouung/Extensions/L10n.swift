import Foundation

enum L10n {
    static func t(_ key: String, languageCode: String) -> String {
        let resolvedLanguage = AppLanguage(rawValue: languageCode)?.rawValue ?? AppLanguage.english.rawValue

        guard
            let path = Bundle.main.path(forResource: resolvedLanguage, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(key, comment: "")
        }

        return NSLocalizedString(key, tableName: "Localizable", bundle: bundle, value: key, comment: "")
    }

    static func f(_ key: String, languageCode: String, _ args: CVarArg...) -> String {
        let format = t(key, languageCode: languageCode)
        return String(format: format, locale: Locale(identifier: languageCode), arguments: args)
    }
}
