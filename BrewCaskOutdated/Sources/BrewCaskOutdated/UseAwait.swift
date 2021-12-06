import Foundation

@available(macOS 12, *)
actor Cask {
    var items = [String]()
    
    func addItem(_ item: String) {
        items.append(item)
    }
}

@available(macOS 12, *)
public func runTaskWithAwait() {
    print("runTaskWithAwait")
    
    let array = getInstalledList()
    
    let cask = Cask()
    
    Task {
        await withTaskGroup(of: Void.self, body: { group in
            for tmp_item in array {
                if tmp_item.count == 0 {
                    continue
                }
                let item = String(tmp_item)
                group.addTask {
                    let (code, output) = CommandRunner.sync(command: "/opt/homebrew/bin/brew info \(item)")
                    print(output)
                    if code != 0 {
                        return
                    }
                    
                    let resArr = output.split(separator: "\n")
                    if resArr.count < 3 {
                        return
                    }
                    
                    let lineOne = resArr[0]
                    let lineThree = resArr[2]
                    let newVersion = lineOne.split(separator: " ")[1]
                    let tmpStr = lineThree.split(separator: " ")[0]
                    let tmpArr = tmpStr.split(separator: "/")
                    let oldVersion = tmpArr[tmpArr.count-1]

                    if newVersion == oldVersion {
                        print("\(item) 当前为最新版本，不需要更新")
                    } else {
                        await cask.addItem(item)
                        print("\(item) 当前版本为：\(oldVersion), 最新版本为：\(newVersion)。请使用下面命令更新：\n brew upgrade \(item)\n")
                    }
                }
            }
        })
        
        // 前面的任务都执行完了再执行这个 await
        if await cask.items.count == 0 {
            print("\n恭喜您，当前所有 cask 均为最新版本")
        }
        
        print("")
        
        for item in await cask.items {
            print("brew upgrade \(item)")
        }
        
        print("\ndone!")
        
        exit(0)
    }
    
    
    // get our the `RunLoop` associated to our current thread
    let currentRL = RunLoop.current

    let port = Port()
    currentRL.add(port, forMode: .default)

    while true {
        // Run our current `RunLoop` on a specif mode
        currentRL.run(mode: .default, before: Date.distantFuture)
    }
}
