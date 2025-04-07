type ContextType = "suite" | "test" | "run"

export type Status = "passed" | "failed" | nil

export type Test = {
    type: ContextType,
    items: { Context },
    labels: { string },
    time_taken: number,

    logs: { string },
    failed: boolean,
    status: Status,
}

export type Context = {
    type: ContextType,
    items: { Context },
    labels: { string },
    time_taken: number,
}

export type Expect = ((a: any) -> {
    to_be: (b: any) -> (),
}) & {
    error: (run: () -> ()) -> (),
    not_error: (run: () -> ()) -> (),
}

return nil