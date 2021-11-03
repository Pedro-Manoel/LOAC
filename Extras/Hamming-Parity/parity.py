# Código

def xorAll (bin: str):
    result = int(bin[0])
    
    for i in range(1, len(bin)):
        result ^= int(bin[i])
       
    return str(result)

def generateAndAddParity (bin: str): 
    return xorAll(bin) + bin
  
def verifyParityError (bin):
    return bool(int(xorAll(bin)))


# Testes

assert generateAndAddParity("10") == "110"
assert generateAndAddParity("01") == "101"
assert generateAndAddParity("1100") == "01100"
assert generateAndAddParity("1101") == "11101"
assert generateAndAddParity("000100") == "1000100"
assert generateAndAddParity("100100") == "0100100"

assert verifyParityError("110") == False
assert verifyParityError("101") == False
assert verifyParityError("01100") == False
assert verifyParityError("11101") == False
assert verifyParityError("1000100") == False
assert verifyParityError("0100100") == False

assert verifyParityError("111") == True
assert verifyParityError("1011") == True
assert verifyParityError("01101") == True
assert verifyParityError("11111") == True
assert verifyParityError("1100100") == True
assert verifyParityError("010010101010101") == True
