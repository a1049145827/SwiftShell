print("start")

do {
    if #available(macOS 12, *) {
        runTaskWithAwait()
    } else if #available(macOS 10.15, *) {
        runTaskWithQueue()
    } else {
        print("current macOS version is too low, please upgrade!")
    }
}

print("end")
