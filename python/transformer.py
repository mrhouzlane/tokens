# List of hex numbers
hex_numbers = [
    "0x1296ee62",
    "0x4000aea0",
    "0xd8fbe994",
    "0xc1d34b89",
    "0x3177029f",
    "0xcae9ca51"
]

# Convert to integers and calculate XOR
result = 0
for num in hex_numbers:
    result ^= int(num, 16)  # Convert hex string to integer and XOR with the result

result_hex = hex(result)

print("The result of the XOR is:", result_hex)
