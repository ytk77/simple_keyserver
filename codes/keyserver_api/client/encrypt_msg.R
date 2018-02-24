library(sodium)


args = commandArgs(trailingOnly=TRUE)
if (length(args)!=1) {
    stop("Please input 1 argument")
}
msg = args[1]

## load public key
pub_key = readRDS("pub_key.rds")

## encrypt message
msg2 <- serialize(charToRaw(msg), NULL)
ciphertext <- simple_encrypt(msg2, pub_key)

## join hexdecimal string
res <- paste0(ciphertext, collapse = '')
cat(res)
