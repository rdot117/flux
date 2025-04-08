local package = script.Parent

local types = require(package.types)

type Test = types.Test
type Context = types.Context

local SECOND = 1
local MILLISECOND = SECOND / 1000
local MICROSECOND = MILLISECOND / 1000
local HEADER_LENGTH = 80
local RESULTS = {
    passed = "✓",
    failed = "×",
    skipped = "▸",
    errored = "×", --"🚫",
}

local function header(content: string?)
    if not content then
        return string.rep("=", HEADER_LENGTH)
    end

    local content_length = string.len(content)

    if content_length >= HEADER_LENGTH - 4 then
        error("[pretty]: unable to make header for %s; too long")
    end

    local real_length = content_length + 2
    local leftover = HEADER_LENGTH - real_length

    return string.format("%s %s %s", string.rep("=", math.floor(leftover/2)), content, string.rep("=", math.ceil(leftover/2)))
end

local function label(labels: { string })
    if #labels == 0 then
        return ""
    end

    return labels[#labels]
end

local function indent(indents: number)
    return string.rep("  ", indents)
end

local function indent_each(has_lines: string, indents: number)
    local lines = string.split(has_lines, "\n")
    
    for index, line in lines do
        lines[index] = indent(indents) .. line
    end

    local joint = lines[1]

    for i = 2, #lines do
        joint ..= "\n" .. lines[i]
    end

    return joint
end

local function time_taken(seconds: number)
	local suffix = {
		micro = "µ",
		milli = "m",
	}

	if seconds < 100 * MICROSECOND then
		return `{math.ceil(seconds / MICROSECOND * 100) / 100}{suffix.micro}s`
	elseif seconds < 100 * MILLISECOND then
		return `{math.ceil(seconds / MILLISECOND * 100) / 100}{suffix.milli}s`
	else
		return `{math.ceil(seconds * 100) / 100}s`
	end
end

local function log(
    context: types.Context,
    tally: { passed: number, failed: number }
)
    local content = header("tests")
    
    for _, item in context.items do

        -- case 1: suite
        if item.type == "suite" then
            local suite = item :: Context
            content ..= "\n" .. string.format("%s%s - %s", indent(#suite.labels - 1), label(suite.labels), time_taken(suite.time_taken))

        -- case 2: test
        elseif item.type == "test" then

            local test = item :: Test
            content ..= "\n" .. string.format("%s[%s] %s - %s", indent(#test.labels -1), RESULTS[test.status], label(test.labels), time_taken(test.time_taken))

            -- case 3: additional logs
            for _, line in test.logs do
                content ..= "\n" .. indent_each(line, #test.labels)
            end
        end
    end

    content ..= "\n" .. header(string.format("%s passed, %s failed", tostring(tally.passed), tostring(tally.failed)))
    content ..= "\n" .. string.format("time taken: %s", time_taken(context.time_taken))
    content ..= "\n" .. header()

    return content
end

return {
    log = log,
    header = header,
    label = label,

    indent = indent,
    indent_each = indent_each,
}