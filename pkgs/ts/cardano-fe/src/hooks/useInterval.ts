import { DependencyList, useEffect } from "react"

export const useInterval = (ms: number, cb: () => void, deps: DependencyList = []) => useEffect(() => {
    cb()
    const interval = setInterval(cb, ms)
    return () => {
        clearInterval(interval)
    }
}, deps)