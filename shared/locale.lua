Locales = {}

function _U(str, ...)
    local lang = Config and Config.Locale or "en"
    local dict = Locales[lang] or Locales["en"] or {}
    local text = dict[str] or str
    if ... then
        return string.format(text, ...)
    end
    return text
end

function t(str, ...)
    return _U(str, ...)
end

function getLang()
    local lang = Config and Config.Locale or "en"
    return Locales[lang] or Locales["en"] or {}
end
