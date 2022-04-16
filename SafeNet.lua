local SafeNet = {}
    --simple cc twaeked program that helps people just simplely send data

    SafeNet.ecc = require("ecc")
    --open modem port
    SafeNet.modem = peripheral.find("modem")

    SafeNet.UsedCodes = {}
    SafeNet.privateKey = nil
    SafeNet.publicKey = nil
    if not SafeNet.modem.isOpen(24725) then
        SafeNet.modem.open(24725)
    end

    --install latest verson from cloud
    CloudFile = http.get("https://raw.githubusercontent.com/Safenet/SafeNet/master/computer/0/SafeNet.lua" .. "cb=" .. math.random(1,999999))
    if CloudFile then
        local File = fs.open("SafeNet.lua", "w")
        File.write(CloudFile.readAll())
        File.close()
        print("SafeNet updated")
        CloudFile.close()
    end

    local function ConvertIpAddressToString(IpAddress)
        local IpAddressString = ""
        for i = 1, #IpAddress do
            IpAddressString = IpAddressString .. IpAddress[i] .. "."
        end
        --remove last letter because of ending .
        IpAddressString = string.sub(IpAddressString, 1, #IpAddressString-1)
        return IpAddressString
    end
    SafeNet.ConvertIpAddressToString = ConvertIpAddressToString

    local function ConvertStringToIpAddress(IpAddressString)
        local IpAddress = {}
        local LastDotPoint = 1
        for i = 1, #IpAddressString do
            if IpAddressString[i] == "." then
                table.insert(IpAddress, tonumber(string.sub(IpAddressString, LastDotPoint, i-1)))
                LastDotPoint = i+1
            end
        end
        return IpAddress
    end
    SafeNet.ConvertStringToIpAddress = ConvertStringToIpAddress

    --creates new ip address
    local function CreateIpAddress()
        
        SafeNet.privateKey, SafeNet.publicKey = SafeNet.ecc.keypair(SafeNet.ecc.random.random())


    end
    SafeNet.CreateNewIpAddress = CreateIpAddress

    --saves the ip address to the computer
    local function SaveIpAddress(KeyForEncryption)
        --saves ip address to file
        local file = fs.open("SafeNetIpAddress.txt", "w")
        local DataToSave = textutils.serialize({SafeNet.publicKey,SafeNet.privateKey})
        --perform encryption
        if KeyForEncryption == nil then
            file.write(DataToSave)
            
        else
            local privateKey, publicKey = SafeNet.ecc.keypair(KeyForEncryption) 
            local Code = SafeNet.ecc.exchange(privateKey, publicKey)
            local EncryptedData = SafeNet.ecc.encrypt(Code, DataToSave)
            file.write(EncryptedData)
        end
        file.close()
    end
    SafeNet.SaveIpAddress = SaveIpAddress

    --loads the ip address from the computer
    local function LoadIpAddress(KeyForEncryption)
        --loads ip address from file
        local file = fs.open("SafeNetIpAddress.txt", "r")
        local DataToLoad = file.readAll()
        file.close()
        --perform decryption
        if KeyForEncryption == nil then
            local OutputTable = textutils.unserialize(DataToLoad)
            SafeNet.publicKey = OutputTable[1]
            SafeNet.privateKey = OutputTable[2]
        else
            local privateKey, publicKey = SafeNet.ecc.keypair(KeyForEncryption) 
            local Code = SafeNet.ecc.exchange(privateKey, publicKey)
            local DecryptedData = SafeNet.ecc.decrypt(Code, DataToLoad)
            local OutputTable = textutils.unserialize(DecryptedData)
            SafeNet.publicKey = OutputTable[1]
            SafeNet.privateKey = OutputTable[2]
        end
    end
    SafeNet.LoadIpAddress = LoadIpAddress

    --send message
    local function SendMessage(Message, IpAddress)
        --format for messages
        -- {SafeNet_Message,IpAddressTo,IpAddressFrom.Encrypted>{Message,TimeSent}}
        local TunnelKey = SafeNet.ecc.exchange(SafeNet.privateKey, IpAddress)
        local EncryptedData = textutils.serialize({Message, os.epoch("utc")})
        EncryptedData = SafeNet.ecc.encrypt(EncryptedData, TunnelKey)
        local MessageText = textutils.serialize({"SafeNet_Message", IpAddress, SafeNet.publicKey, EncryptedData})
        --send message
        SafeNet.modem.transmit(24725, 24725, MessageText)


    end
    SafeNet.SendMessage = SendMessage

    --receive message
    local function HandleInput(MessageData)
        local Message = textutils.unserialize(MessageData)



        if Message[1] == "SafeNet_Message" then

            local TunnelKey = SafeNet.ecc.exchange(SafeNet.privateKey, Message[3])
            
            if textutils.serialize(Message[2]) == textutils.serialize(SafeNet.publicKey) then

                local DecryptedData = SafeNet.ecc.decrypt(Message[4], TunnelKey)
                
                DecryptedData = string.char(unpack(DecryptedData))
                DecryptedData = textutils.unserialize(DecryptedData)
                local Message = DecryptedData[1]
                local TimeSent = DecryptedData[2]  
                --replay attack test
                if TimeSent < (os.epoch("utc") - 100 )  then
                    return nil, "Message is too old (probs a replay attack)"
                end
                if SafeNet.UsedCodes[TunnelKey] == nil then
                    SafeNet.UsedCodes[TunnelKey] = {}
                end
                if SafeNet.UsedCodes[TunnelKey][TimeSent] == true then
                    return nil, "Message is a replay attack"
                end
                SafeNet.UsedCodes[TunnelKey][TimeSent] = true
                --returns data 
                return Message
            end
            return nil, "Message not ment for me"
        end
        return nil, "not SafeNet_Message"
    end
    SafeNet.HandleInput = HandleInput

    --things to add
    --automatic ip dealing with cheeks if one saved if not makes one
    --auto updating
    --program that trys to crack ip addresses to test security










return SafeNet  
