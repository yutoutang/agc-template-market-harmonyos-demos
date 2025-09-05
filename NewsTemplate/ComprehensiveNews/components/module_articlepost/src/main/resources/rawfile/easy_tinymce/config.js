function reduceConfig(config) {
    if (typeof config !== 'object') {
        return config;
    }
    Object.keys(config).forEach(key => {
        let value = config[key];
        if (typeof value === 'object') {
            let type = value.type
            let body = ''
            let reduced = false
            if (type === 'ref') {
                let name = value.name
                if (typeof name === 'string') {
                    name = removeLeadingEmptyLines(name)
                    body = `return window.${name}`
                    config[key] = compileTo(key, body)
                    reduced = true
                }
            } else if (type === 'defined') {
                let definedBody = value.definedBody
                if (typeof definedBody === 'string') {
                    definedBody = removeLeadingEmptyLines(definedBody)
                    body = `return ${definedBody}`
                    config[key] = compileTo(key, body)
                    reduced = true
                }
            }
            if (!reduced) {
                config[key] = reduceConfig(value)
            }
        }
    })
    return config;
}

function compileTo(key, body) {
    try {
        return Function(body)()
    } catch (e) {
        console.error(`compile callback for ${key} error : `, e.message || e)
        return undefined
    }
}

function removeLeadingEmptyLines(str) {
    return str.replace(/^\s*\n*/gm, '');
}
