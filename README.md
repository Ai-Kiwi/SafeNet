# SafeNet
safenet is a simple program for computercraft that aims to have full encrystion of messages. if you've got any feedback or suggestions please share.

# how to install
```
-- install ecc lib
pastebin get ZGJGBJdg ecc
-- install program wget <url> SafeNet
wget run https://raw.githubusercontent.com/Ai-Kiwi/SafeNet/main/SafeNet.lua
```

# how to use
```
-- binding file for use (also runs setup for everyting)
local SafeNet = require("SafeNet")

--creates the ip address for computer to use
SafeNet.CreateIpAddress()

--saves ip address to computer as file for later use
SafeNet.SaveIpAddress()

--loads ip address from file
SafeNet.LoadIpAddress()

--says ip address (in raw format)
print(SafeNet.publicKey)

--says hello to a sample computer (secand value is ip adddress in raw format)
SafeNet.SendMessage("hello",{238,106,242,150,181,37,45,174,6,36,232,96,233,128,11,21,153,223,14,128,164,1,})

```

# vulnerables
 1. ip addresses once creacked have all messages saved leaked
 2. level of encryption untested
