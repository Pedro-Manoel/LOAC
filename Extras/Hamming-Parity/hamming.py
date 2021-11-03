# Código

def strToIntList (s: str):
    return list(map(int, s))

def intListToStr (i: list):
    return ''.join([str(n) for n in i])

def generateListParityPositions (bin: list):
    x = 1
    result = []

    while(x <= len(bin)):
        result.append(x)
        x *= 2

    return result

def generateParity (bin: list, position: int):
    aux = 1
    sum = True
    parity = 0

    for i in range(position - 1, len(bin)):
        if aux <= position and sum:
            parity += bin[i]
            aux += 1
        else:
            aux -= 1
            sum = True if aux == 1 else False

    return 0 if parity % 2 == 0 else 1 

def generateHammingCode (bin: str):
    bin = strToIntList(bin)
    parityPositions = generateListParityPositions(bin)
    newBin = []

    indexBin = 0
    for i in range(len(bin) + len(parityPositions)):
        if i + 1 in parityPositions:
            newBin.insert(i, 0)
        else:
            newBin.insert(i, bin[indexBin])
            indexBin += 1
    
    for p in parityPositions:
        newBin[p - 1] = generateParity(newBin, p)
    
    return intListToStr(newBin)

def detectAndCorrectHammingCode (bin: str):
    bin = strToIntList(bin)
    errorBit = 0
    
    for p in generateListParityPositions(bin):
        currentParity = bin[p - 1] 
        binCopy = bin.copy()
        binCopy[p - 1] = 0
        parity = generateParity(binCopy, p)
        if currentParity != parity:
            errorBit += p
    
    if errorBit == 0:
        print("O código hamming está correto")
        return {"error": False, "errorBit": None, "correction": None}
    else:
        bin[errorBit - 1] = 0 if bin[errorBit - 1] == 1 else 1
        bin = intListToStr(bin) 
        print("O código hamming está errado")
        print(f'bit errado: {errorBit}')
        print(f'Correção do código hamming: {bin}')
        return {"error": True, "errorBit": errorBit, "correction": bin}


# Testes

assert generateHammingCode("1010") == "1011010"
assert generateHammingCode("1011") == "0110011"

assert generateHammingCode("0101") == "0100101"
assert detectAndCorrectHammingCode("0100101")["error"] == False
assert detectAndCorrectHammingCode("0100100") == {"error": True, "errorBit": 7, "correction": "0100101"}
assert detectAndCorrectHammingCode("0100111") == {"error": True, "errorBit": 6, "correction": "0100101"}
assert detectAndCorrectHammingCode("0100001") == {"error": True, "errorBit": 5, "correction": "0100101"}
assert detectAndCorrectHammingCode("0101101") == {"error": True, "errorBit": 4, "correction": "0100101"}
assert detectAndCorrectHammingCode("0110101") == {"error": True, "errorBit": 3, "correction": "0100101"}
assert detectAndCorrectHammingCode("0000101") == {"error": True, "errorBit": 2, "correction": "0100101"}
assert detectAndCorrectHammingCode("1100101") == {"error": True, "errorBit": 1, "correction": "0100101"}

assert generateHammingCode("11001110") == "011110011110"
assert detectAndCorrectHammingCode("011110011110")["error"] == False
assert detectAndCorrectHammingCode("011110011111") == {"error": True, "errorBit": 12, "correction": "011110011110"}
assert detectAndCorrectHammingCode("011110010110") == {"error": True, "errorBit": 9, "correction": "011110011110"}
assert detectAndCorrectHammingCode("011110111110") == {"error": True, "errorBit": 7, "correction": "011110011110"}
assert detectAndCorrectHammingCode("010110011110") == {"error": True, "errorBit": 3, "correction": "011110011110"}
assert detectAndCorrectHammingCode("111110011110") == {"error": True, "errorBit": 1, "correction": "011110011110"}
