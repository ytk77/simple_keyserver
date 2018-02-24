## Only need to be run once
## generate private and public key
library(sodium)

pri_key <- keygen()
pub_key <- pubkey(pri_key)

saveRDS(pri_key, "data/pri_key.rds")
saveRDS(pub_key, "data/pub_key.rds")

## TEST it
## encryption
msg <- serialize(charToRaw("Hello there."), NULL)
ciphertext <- simple_encrypt(msg, pub_key)

# Decrypt message with private key
out <- simple_decrypt(ciphertext, pri_key)
rawToChar( unserialize(out) )

