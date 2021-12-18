print("start")

do {
    if #available(macOS 10.15, *) {
#if swift(>=5.5.2)
        runTaskWithAwait()
#else
        runTaskWithQueue()
#endif
    } else {
        print("current macOS version is too low, please upgrade!")
    }
}

print("end")
